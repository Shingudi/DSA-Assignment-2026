import ballerina/grpc;

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: RENTAL_DESC}
service "RentalService" on ep {

        remote function add_property(AddPropertyRequest value) returns AddPropertyResponse|error {
        // 1. Host must exist
        UserRecord? host = users[value.host_id];
        if host is () {
            return error grpc:NotFoundError("Host not found: " + value.host_id);
        }

        // 2. Price must be positive
        if value.price_per_night <= 0.0 {
            return error grpc:InvalidArgumentError("Price per night must be positive");
        }

        // 3. Generate a new property_id
        string propertyId = newId();

        // 4. Build the internal record — status forced to AVAILABLE,
        //    region inherited from the host.
        PropertyRecord newProp = {
            property_id:     propertyId,
            host_id:         value.host_id,
            name:            value.name,
            location:        value.location,
            region:          host.region,
            property_type:   value.property_type,
            price_per_night: <decimal>value.price_per_night,
            status:          AVAILABLE
        };

        // 5. Store it
        properties[propertyId] = newProp;

        // 6. Respond
        return {
            property_id: propertyId,
            message: "Property added successfully"
        };
    }
            remote function update_property(UpdatePropertyRequest value) returns UpdatePropertyResponse|error {
        // 1. Property must exist
        PropertyRecord? existing = properties[value.property_id];
        if existing is () {
            return error grpc:NotFoundError("Property not found: " + value.property_id);
        }

        // 2. Validate BEFORE mutating — all-or-nothing.
        float? newPrice = value.price_per_night;
        if newPrice is float && newPrice <= 0.0 {
            return error grpc:InvalidArgumentError("Price per night must be positive");
        }

        // 3. Apply updates — pull optionals into locals first so that
        //    Ballerina's type narrowing applies cleanly.
        string? newName = value.name;
        if newName is string {
            existing.name = newName;
        }

        string? newLocation = value.location;
        if newLocation is string {
            existing.location = newLocation;
        }

        string? newType = value.property_type;
        if newType is string {
            existing.property_type = newType;
        }

        if newPrice is float {
            existing.price_per_night = <decimal>newPrice;
        }

        PropertyStatus? newStatus = value.status;
        if newStatus is PropertyStatus {
            existing.status = newStatus;
        }

        // 4. Respond
        return {
            property: toPropertyProto(existing),
            message:  "Property updated successfully"
        };
    }

        remote function remove_property(RemovePropertyRequest value) returns RemovePropertyResponse|error {
        // 1. Property must exist
        PropertyRecord? existing = properties[value.property_id];
        if existing is () {
            return error grpc:NotFoundError("Property not found: " + value.property_id);
        }

        // 2. Capture the region BEFORE deletion (for the remaining list)
        string region = existing.region;

        // 3. Remove it
        PropertyRecord _ = properties.remove(value.property_id);

        // 4. Find all remaining properties in the same region
        PropertyRecord[] remaining = propertiesInRegion(region);

        // 5. Convert each to a proto Property message
        Property[] remainingProtos = from PropertyRecord p in remaining
                                     select toPropertyProto(p);

        // 6. Respond
                int remainingCount = remainingProtos.length();
        return {
            removed_property_id: value.property_id,
            remaining_properties: remainingProtos,
            message: "Property removed successfully. Remaining in region '" +
                     region + "': " + remainingCount.toString()
        };
    }

                remote function search_property(SearchPropertyRequest value) returns SearchPropertyResponse|error {
        // 1. Look up the property
        PropertyRecord? found = properties[value.property_id];

        // 2a. Not found — Option B: return a normal response, not an error
        if found is () {
            return {
                found:          false,
                property:       {},
                status_message: "Not Found"
            };
        }

        // 2b. Found — decide the status message via a match statement
        string statusMsg = "Unknown";   // will be overwritten below
        match found.status {
            AVAILABLE => {
                statusMsg = "Available";
            }
            UNAVAILABLE => {
                statusMsg = "Not available";
            }
            UNDER_RENOVATION => {
                statusMsg = "Under renovation";
            }
            OCCUPIED => {
                statusMsg = "Currently occupied";
            }
        }

        // 3. Respond with full details
        return {
            found:          true,
            property:       toPropertyProto(found),
            status_message: statusMsg
        };
    }
        remote function book_property(BookPropertyRequest value) returns BookPropertyResponse|error {
        // 1. Guest must exist
        UserRecord? guest = users[value.guest_id];
        if guest is () {
            return error grpc:NotFoundError("Guest not found: " + value.guest_id);
        }

        // 2. Property must exist
        PropertyRecord? prop = properties[value.property_id];
        if prop is () {
            return error grpc:NotFoundError("Property not found: " + value.property_id);
        }

        // 3. Property must be AVAILABLE
        if prop.status != AVAILABLE {
            return error grpc:FailedPreconditionError(
                "Property is not available for booking (current status: " +
                prop.status.toString() + ")");
        }

        // 4. Dates must be valid
        if !isValidDate(value.check_in) {
            return error grpc:InvalidArgumentError(
                "Invalid check-in date (expected YYYY-MM-DD): " + value.check_in);
        }
        if !isValidDate(value.check_out) {
            return error grpc:InvalidArgumentError(
                "Invalid check-out date (expected YYYY-MM-DD): " + value.check_out);
        }

        // 5. check_out must be strictly after check_in
        if value.check_out <= value.check_in {
            return error grpc:InvalidArgumentError(
                "Check-out date must be after check-in date");
        }

        // 6. Create the cart entry (PENDING, cost 0 for now)
        string bookingId = newId();
        BookingRecord cartEntry = {
            booking_id:  bookingId,
            guest_id:    value.guest_id,
            property_id: value.property_id,
            check_in:    value.check_in,
            check_out:   value.check_out,
            total_cost:  0d,
            status:      PENDING
        };

        // 7. Add to cart
        bookingCart[bookingId] = cartEntry;

        // 8. Respond
        return {
            booking_id: bookingId,
            message:    "Booking added to cart. Call confirm_booking to finalize."
        };
    }

        remote function confirm_booking(ConfirmBookingRequest value) returns ConfirmBookingResponse|error {
        // 1. Booking must exist in the cart
        BookingRecord? cartEntry = bookingCart[value.booking_id];
        if cartEntry is () {
            return error grpc:NotFoundError(
                "Booking not found in cart: " + value.booking_id);
        }

        // 2-9. Critical section: check + commit must be atomic.
        //      Without this lock, two concurrent confirm_booking calls for
        //      overlapping date ranges could both pass the availability
        //      check and both commit — a double-booking race condition.
        BookingRecord confirmed;
        lock {
            // 3. Property must still exist
            PropertyRecord? prop = properties[cartEntry.property_id];
            if prop is () {
                return error grpc:NotFoundError(
                    "Property no longer exists: " + cartEntry.property_id);
            }

            // 4. Property must still be AVAILABLE
            if prop.status != AVAILABLE {
                return error grpc:FailedPreconditionError(
                    "Property is no longer available for booking");
            }

            // 5. No overlap with any confirmed booking for this property
            if !isPropertyFree(cartEntry.property_id,
                               cartEntry.check_in,
                               cartEntry.check_out) {
                return error grpc:FailedPreconditionError(
                    "Property not available for these dates");
            }

            // 6. Compute total cost = price × nights
            int nights = nightsBetween(cartEntry.check_in, cartEntry.check_out);
            decimal totalCost = prop.price_per_night * <decimal>nights;

            // 7. Mark booking CONFIRMED with the total
            confirmed = {
                booking_id:  cartEntry.booking_id,
                guest_id:    cartEntry.guest_id,
                property_id: cartEntry.property_id,
                check_in:    cartEntry.check_in,
                check_out:   cartEntry.check_out,
                total_cost:  totalCost,
                status:      CONFIRMED
            };

            // 8. Move from cart to confirmed store
            _ = bookingCart.remove(value.booking_id);
            confirmedBookings[confirmed.booking_id] = confirmed;
        }

        // 10. Respond
        return {
            booking: toBookingProto(confirmed),
            message: "Booking confirmed. Total cost: " + confirmed.total_cost.toString()
        };
    }

           remote function create_users(stream<CreateUserRequest, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        string[] createdIds = [];

        // Manually pull messages from the client stream one at a time
        // using next(). The return type of next() is a union:
        //   - {| CreateUserRequest value; |}  → one message
        //   - grpc:Error                       → stream failed
        //   - ()                               → stream ended normally
        while true {
            record {| CreateUserRequest value; |}|grpc:Error? next = clientStream.next();

            if next is grpc:Error {
                return next;
            }
            if next is () {
                break;
            }

            // next is now narrowed to {| CreateUserRequest value; |}
            CreateUserRequest req = next.value;

            // 1. Validate email uniqueness (transactional — abort on dup)
            foreach UserRecord existing in users {
                if existing.email == req.email {
                    return error grpc:AlreadyExistsError(
                        "Email already registered: " + req.email);
                }
            }

            // 2. Generate a user_id
            string userId = newId();

            // 3. Build and store the record
            UserRecord newUser = {
                user_id: userId,
                name:    req.name,
                email:   req.email,
                role:    req.role,
                region:  req.region
            };
            users[userId] = newUser;

            // 4. Track the id
            createdIds.push(userId);
        }

        // 5. Respond once, after the stream ends
        return {
            user_ids: createdIds,
            count:    createdIds.length(),
            message:  "Successfully registered " + createdIds.length().toString() + " user(s)."
        };
    }

        remote function list_available_properties(ListAvailableRequest value) returns stream<Property, error?>|error {
        // Pull optional filters into locals so that narrowing works
        string? locationFilter  = value.location;
        float?  maxPriceFilter  = value.max_price;

        // Build the stream with a query over the properties map.
        // The where-clauses implement the *optional* filtering logic:
        //   - if the client didn't set a location, that filter is skipped
        //   - if the client didn't set max_price, that filter is skipped
        //   - otherwise, apply each filter that was provided
        stream<Property, error?> resultStream = from PropertyRecord p in properties
            where p.status == AVAILABLE
            where locationFilter is () || p.location == locationFilter
            where maxPriceFilter is () || p.price_per_night <= <decimal>maxPriceFilter
            select toPropertyProto(p);

        return resultStream;
    }
}

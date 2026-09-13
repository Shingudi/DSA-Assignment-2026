
//  main.bal  (client package)
//  End-to-end demo of the RentalService.
//  This script exercises all 8 RPCs in a logical order:
//
//    1. create_users               (client streaming) — register a host + guest
//    2. add_property               — host adds two properties
//    3. search_property            — guest looks up a property
//    4. update_property            — host updates a property's price
//    5. list_available_properties  (server streaming) — guest streams all available
//    6. book_property              — guest books a date range
//    7. confirm_booking            — guest confirms the booking
//    8. remove_property            — host removes one property
import ballerina/io;

// The gRPC server endpoint
final RentalServiceClient rentalClient = check new ("http://localhost:9090");

public function main() returns error? {
    io:println("================ RentalService Client Demo ================");

    // Step 1 — create_users (client streaming)
    // Register 1 HOST and 1 GUEST. Capture their assigned user_ids.
    io:println("\n[1] create_users (client streaming)");

    Create_usersStreamingClient userStream = check rentalClient->create_users();

    // Host
    check userStream->sendCreateUserRequest({
        name:   "Alice Host",
        email:  "alice@example.com",
        role:   HOST,
        region: "Western Province"
    });

    // Guest
    check userStream->sendCreateUserRequest({
        name:   "Bob Guest",
        email:  "bob@example.com",
        role:   GUEST,
        region: ""
    });

    // Signal end of stream, then receive the single response
    check userStream->complete();
    CreateUsersResponse? usersResp = check userStream->receiveCreateUsersResponse();

    if usersResp is () {
        return error("create_users returned no response");
    }

    string hostId  = usersResp.user_ids[0];
    string guestId = usersResp.user_ids[1];
    io:println("    Registered ", usersResp.count, " users.");
    io:println("    hostId  = ", hostId);
    io:println("    guestId = ", guestId);

    // Step 2 — add_property (unary, called twice)
    io:println("\n[2] add_property (twice)");

    AddPropertyResponse add1 = check rentalClient->add_property({
        host_id:         hostId,
        name:            "Sea View Apartment",
        location:        "Colombo 03",
        property_type:   "Apartment",
        price_per_night: 8500.0
    });
    io:println("    Added property #1: ", add1.property_id, " — ", add1.message);

    AddPropertyResponse add2 = check rentalClient->add_property({
        host_id:         hostId,
        name:            "Hilltop Villa",
        location:        "Kandy",
        property_type:   "Villa",
        price_per_night: 15000.0
    });
    io:println("    Added property #2: ", add2.property_id, " — ", add2.message);

    string propId1 = add1.property_id;
    string propId2 = add2.property_id;

    // Step 3 — search_property (unary)
    io:println("\n[3] search_property");

    SearchPropertyResponse search = check rentalClient->search_property({
        property_id: propId1
    });
    io:println("    Found: ", search.found, " — status: ", search.status_message);
    io:println("    Property name: ", search.property.name);

    // Also search for a non-existent property to demonstrate the "Not Found" path
    SearchPropertyResponse notFound = check rentalClient->search_property({
        property_id: "nonexistent-id"
    });
    io:println("    Not-found case: ", notFound.found, " — ", notFound.status_message);

    // Step 4 — update_property (unary, partial)
    // Change the price of property #1
    io:println("\n[4] update_property (partial update)");

    UpdatePropertyResponse upd = check rentalClient->update_property({
        property_id:     propId1,
        price_per_night: 9500.0
    });
    io:println("    Updated: ", upd.property.name, " — new price: ",
               upd.property.price_per_night);

    // Step 5 — list_available_properties (server streaming)
    io:println("\n[5] list_available_properties (server streaming)");

    stream<Property, error?> propStream = check rentalClient->list_available_properties({});
    int propCount = 0;
    check propStream.forEach(function(Property p) {
        propCount += 1;
        io:println("    [", propCount, "] ", p.name, " @ ", p.location,
                   " — ", p.price_per_night, " / night — ", p.status);
    });
    io:println("    Total streamed: ", propCount);

    // Step 6 — book_property (unary)
    // Guest books property #1 for a 3-night stay
    io:println("\n[6] book_property");

    BookPropertyResponse book = check rentalClient->book_property({
        guest_id:    guestId,
        property_id: propId1,
        check_in:    "2026-12-01",
        check_out:   "2026-12-04"
    });
    io:println("    Booking id: ", book.booking_id, " — ", book.message);

    string bookingId = book.booking_id;

    // Step 7 — confirm_booking (unary)
    io:println("\n[7] confirm_booking");

    ConfirmBookingResponse confirm = check rentalClient->confirm_booking({
        booking_id: bookingId
    });
    io:println("    Status:   ", confirm.booking.status);
    io:println("    Nights:   ", confirm.booking.check_in, " → ", confirm.booking.check_out);
    io:println("    Total:    ", confirm.booking.total_cost);
    io:println("    Message:  ", confirm.message);

    // Step 8 — remove_property (unary)
    // Host removes the second property
    io:println("\n[8] remove_property");

    RemovePropertyResponse rem = check rentalClient->remove_property({
        property_id: propId2
    });
    io:println("    Removed: ", rem.removed_property_id);
    io:println("    Remaining in region: ", rem.remaining_properties.length());
    foreach Property p in rem.remaining_properties {
        io:println("        - ", p.name, " (", p.location, ")");
    }

    io:println("\n================ Demo complete ================");
}

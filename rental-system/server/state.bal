// =============================================================================
//  state.bal
//
//  In-memory data store for the Rental Accommodation System.
//
//  This file declares:
//    - The internal record types (our domain model)
//    - The module-level maps that hold all runtime state
//
//  NOTE:
//    - Internal records are DELIBERATELY separate from the proto-generated
//      records (Property, User, Booking in rental_pb.bal). This keeps the
//      storage model decoupled from the wire format.
//    - Enums (PropertyStatus, UserRole, BookingStatus) are reused directly
//      from the proto-generated code because they are simple value types
//      with no behaviour — duplicating them would be pointless.
// =============================================================================

// -----------------------------------------------------------------------------
//  Internal record types
// -----------------------------------------------------------------------------

# Represents a property listing stored on the server.
# + property_id     - Unique identifier (UUID) for the property
# + host_id         - UUID of the host who owns the property
# + name            - Human-readable name of the listing
# + location        - Fine-grained location (e.g. "Colombo 03")
# + region          - Coarse region (e.g. "Western Province"), copied from host
# + property_type   - Type of property (e.g. "Apartment", "Villa")
# + price_per_night - Cost per night in the local currency
# + status          - Current availability status (see PropertyStatus enum)
type PropertyRecord record {|
    string         property_id;
    string         host_id;
    string         name;
    string         location;
    string         region;
    string         property_type;
    decimal        price_per_night;
    PropertyStatus status;
|};

# Represents a registered user (Host or Guest).
# + user_id - Unique identifier (UUID) for the user
# + name    - Full name of the user
# + email   - Contact email address
# + role    - Whether the user is a HOST or GUEST
# + region  - The user's region (meaningful for HOSTs; may be empty for GUESTs)
type UserRecord record {|
    string   user_id;
    string   name;
    string   email;
    UserRole role;
    string   region;
|};

# Represents a booking — used for both cart entries and confirmed bookings.
# + booking_id   - Unique identifier (UUID) for the booking
# + guest_id     - UUID of the guest making the booking
# + property_id  - UUID of the property being booked
# + check_in     - Check-in date in ISO format ("YYYY-MM-DD")
# + check_out    - Check-out date in ISO format ("YYYY-MM-DD")
# + total_cost   - Total cost (0 until the booking is confirmed)
# + status       - Current booking status (see BookingStatus enum)
type BookingRecord record {|
    string        booking_id;
    string        guest_id;
    string        property_id;
    string        check_in;
    string        check_out;
    decimal       total_cost;
    BookingStatus status;
|};

// -----------------------------------------------------------------------------
//  Module-level state
//
//  These maps live for the lifetime of the server process. They are the
//  "database". Concurrent access is safe for reads; the only critical
//  section we protect is the confirm_booking path (see the lock statement
//  in rentalservice_service.bal).
// -----------------------------------------------------------------------------

# All property listings, keyed by property_id.
map<PropertyRecord> properties = {};

# All registered users, keyed by user_id.
map<UserRecord> users = {};

# All confirmed bookings, keyed by booking_id.
map<BookingRecord> confirmedBookings = {};

# Temporary booking cart — bookings awaiting confirmation, keyed by booking_id.
map<BookingRecord> bookingCart = {};
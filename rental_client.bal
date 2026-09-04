// ============================================================================
// NUST DSA612S - Assignment 1 Q2: Rental Accommodation gRPC Client
// Ballerina gRPC Client (rental_client.bal)
// ============================================================================

import ballerina/io;
import ballerina/lang.runtime;

function connectToRentalService() returns RentalServiceClient|error {
    error? lastError = ();
    foreach int attempt in 1 ... 10 {
        var clientResult = new RentalServiceClient("http://localhost:9091");
        if clientResult is RentalServiceClient {
            var probe = clientResult->SearchProperty({property_id: "PROP-101"});
            if probe is SearchPropertyResponse {
                return clientResult;
            }
            lastError = probe;
        } else {
            lastError = clientResult;
        }
        runtime:sleep(1.0);
    }
    return lastError ?: error("Unable to connect to rental service on port 9091");
}

function runClient() returns error? {
    // Connect to gRPC service on port 9091
    RentalServiceClient rentalClient = check connectToRentalService();

    // 1. Add Property
    AddPropertyResponse addRes = check rentalClient->AddProperty({
        host_id: "HOST-003",
        property_name: "Kalahari Desert Lodge",
        location: "Hardap, Mariental",
        property_type: "Lodge",
        price_per_night: 2200.0,
        status: "AVAILABLE"
    });
    io:println("1. Add Property Response: ", addRes.message, " ID: ", addRes.property_id);

    // 2. Search Property
    SearchPropertyResponse searchRes = check rentalClient->SearchProperty({ property_id: "PROP-101" });
    io:println("2. Search Property: ", searchRes.property.property_name, " Available: ", searchRes.available);

    // 3. Book Property
    BookPropertyResponse bookRes = check rentalClient->BookProperty({
        guest_id: "GUEST-501",
        property_id: "PROP-101",
        check_in_date: "2026-08-01",
        check_out_date: "2026-08-04"
    });
    io:println("3. Booked Property Cart ID: ", bookRes.cart_item_id, " Total Cost: N$", bookRes.estimated_total_cost);

    // 4. Confirm Booking
    ConfirmBookingResponse confirmRes = check rentalClient->ConfirmBooking({
        guest_id: "GUEST-501",
        cart_item_id: bookRes.cart_item_id
    });
    io:println("4. Confirmed Booking ID: ", confirmRes.booking_id, " Message: ", confirmRes.confirmation_message);
}

public function main() returns error? {
    future<error?> clientTask = start runClient();
    _ = clientTask;
}

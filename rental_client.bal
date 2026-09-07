// ============================================================================
// NUST DSA612S - Assignment 1 Q2: Rental Accommodation gRPC Client
// Ballerina gRPC Client (rental_client.bal)
// ============================================================================

import ballerina/io;
import ballerina/lang.runtime;
import ballerina/grpc;

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

    // 2. Create Users (client-side streaming)
    CreateUsersStreamingClient usersStream = check rentalClient->CreateUsers();
    check usersStream->sendUserProfile({
        user_id: "HOST-003",
        name: "Kalahari Host",
        email: "host003@example.com",
        role: HOST,
        region: "Hardap"
    });
    check usersStream->sendUserProfile({
        user_id: "GUEST-501",
        name: "Rental Guest",
        email: "guest501@example.com",
        role: GUEST,
        region: "Khomas"
    });
    check usersStream->complete();
    var usersResult = usersStream->receiveCreateUsersResponse();
    if usersResult is grpc:Error {
        return usersResult;
    }
    if usersResult is () {
        return error("CreateUsers returned no response");
    }
    CreateUsersResponse usersRes = usersResult;
    io:println("2. Create Users: ", usersRes.status_message,
        " Count: ", usersRes.total_users_registered);

    // 3. Update Property
    UpdatePropertyResponse updateRes = check rentalClient->UpdateProperty({
        property_id: "PROP-101",
        new_price_per_night: 900.0,
        new_status: "AVAILABLE"
    });
    io:println("3. Update Property: ", updateRes.success);

    // 4. Remove Property
    RemovePropertyResponse removeRes = check rentalClient->RemoveProperty({
        property_id: "PROP-999",
        host_region: "Khomas"
    });
    io:println("4. Remove Property: ", removeRes.success,
        " Remaining: ", removeRes.remaining_available_properties.length());

    // 5. Search Property
    SearchPropertyResponse searchRes = check rentalClient->SearchProperty({ property_id: "PROP-101" });
    io:println("5. Search Property: ", searchRes.property.property_name,
        " Available: ", searchRes.available);

    // 6. Book Property
    BookPropertyResponse bookRes = check rentalClient->BookProperty({
        guest_id: "GUEST-501",
        property_id: "PROP-101",
        check_in_date: "2026-08-01",
        check_out_date: "2026-08-04"
    });
    io:println("6. Booked Property Cart ID: ", bookRes.cart_item_id,
        " Total Cost: N$", bookRes.estimated_total_cost);

    // 7. Confirm Booking
    ConfirmBookingResponse confirmRes = check rentalClient->ConfirmBooking({
        guest_id: "GUEST-501",
        cart_item_id: bookRes.cart_item_id
    });
    io:println("7. Confirmed Booking ID: ", confirmRes.booking_id,
        " Message: ", confirmRes.confirmation_message);

    // 8. List Available Properties (server-side streaming)
    var propertyStreamResult = rentalClient->ListAvailableProperties({
        location_filter: "Windhoek",
        max_price_filter: 2000.0
    });
    if propertyStreamResult is grpc:Error {
        return propertyStreamResult;
    }
    stream<Property, grpc:Error?> propertyStream = propertyStreamResult;

    check from var property in propertyStream
        do {
            io:println("8. Available property: ", property.property_name);
        };
}

public function main() returns error? {
    future<error?> clientTask = start runClient();
    _ = clientTask;
}

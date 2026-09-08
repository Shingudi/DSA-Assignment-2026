import ballerina/http;
import ballerina/io;

function runClient() returns error? {
    http:Client rentalService = check new ("http://localhost:9091");

    http:Response propertiesResponse = check rentalService->get("/properties");
    json properties = check propertiesResponse.getJsonPayload();
    io:println("Available assets: ", properties);

    http:Response updateResponse = check rentalService->put("/properties/PROP-101",
        {pricePerNight: 900, status: "AVAILABLE"});
    json updatedAsset = check updateResponse.getJsonPayload();
    io:println("Updated asset: ", updatedAsset);

    UserProfile user = {
        userId: "GUEST-501",
        name: "Rental Guest",
        email: "guest501@example.com",
        role: "GUEST",
        region: "Khomas"
    };
    http:Response userResponse = check rentalService->post("/users", user);
    _ = userResponse;

    http:Response bookingResponse = check rentalService->post("/bookings", {
        guestId: "GUEST-501",
        assetTag: "PROP-101",
        checkInDate: "2026-08-01",
        checkOutDate: "2026-08-04"
    });
    json booking = check bookingResponse.getJsonPayload();
    io:println("Booking created: ", booking);
}

public function main() returns error? {
    check runClient();
}

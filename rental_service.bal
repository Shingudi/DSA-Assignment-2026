// ============================================================================
// NUST DSA612S - Assignment 1 Question 2: REST Rental Accommodation Server
// Ballerina HTTP/REST Service Implementation (rental_service.bal)
// ============================================================================

import ballerina/http;
import ballerina/time;

type Asset record {| 
    string assetTag
    string hostId;
    string propertyName;
    string location;
    string propertyType;
    decimal pricePerNight;
    string status;
    int maxGuests;
|};

type AddAssetRequest record {| 
    string assetTag;
    string hostId;
    string propertyName;
    string location;
    string propertyType;
    decimal pricePerNight;
    string status;
    int maxGuests;
|};

type UpdateAssetRequest record {| 
    decimal pricePerNight;
    string status;
|};

type BookingRequest record {| 
    string guestId;
    string assetTag;
    string checkInDate;
    string checkOutDate;
|};

type Booking record {| 
    string bookingId;
    string guestId;
    string assetTag;
    string checkInDate;
    string checkOutDate;
    decimal totalCost;
|};

type UserProfile record {| 
    string userId;
    string name;
    string email;
    string role;
    string region;
|};

// Helper to create empty Property struct for error responses
function getEmptyAsset() returns Asset {
    return {
        assetTag: "",
        hostId: "",
        propertyName: "",
        location: "",
        propertyType: "",
        pricePerNight: 0,
        status: "",
        maxGuests: 0
    };
}

map<Asset> assets = {
    "PROP-101": {
        assetTag: "PROP-101",
        hostId: "HOST-001",
        propertyName: "Windhoek Luxury Heights Studio",
        location: "Khomas, Windhoek",
        propertyType: "Studio",
        pricePerNight: 850,
        status: "AVAILABLE",
        maxGuests: 2
    },
    "PROP-102": {
        assetTag: "PROP-102",
        hostId: "HOST-002",
        propertyName: "Swakopmund Ocean View Villa",
        location: "Erongo, Swakopmund",
        propertyType: "Villa",
        pricePerNight: 1850,
        status: "AVAILABLE",
        maxGuests: 6
    }
};

map<UserProfile> users = {};
map<Booking> bookings = {};

function parseUtcDate(string dateString) returns time:Utc|error {
    return check time:utcFromString(dateString + "T00:00:00Z");
}

function isValidBookingWindow(string checkInDate, string checkOutDate) returns boolean|error {
    time:Utc checkInUtc = check parseUtcDate(checkInDate);
    time:Utc checkOutUtc = check parseUtcDate(checkOutDate);
    return checkOutUtc[0] > checkInUtc[0];
}

function calculateNights(string checkInDate, string checkOutDate) returns int|error {
    time:Utc checkInUtc = check parseUtcDate(checkInDate);
    time:Utc checkOutUtc = check parseUtcDate(checkOutDate);
    int secondsDifference = <int>(checkOutUtc[0] - checkInUtc[0]);
    return <int>(secondsDifference / 86400);
}

function hasDateOverlap(string firstCheckInDate, string firstCheckOutDate,
        string secondCheckInDate, string secondCheckOutDate) returns boolean|error {
    time:Utc firstCheckInUtc = check parseUtcDate(firstCheckInDate);
    time:Utc firstCheckOutUtc = check parseUtcDate(firstCheckOutDate);
    time:Utc secondCheckInUtc = check parseUtcDate(secondCheckInDate);
    time:Utc secondCheckOutUtc = check parseUtcDate(secondCheckOutDate);

    return firstCheckInUtc[0] < secondCheckOutUtc[0] && secondCheckInUtc[0] < firstCheckOutUtc[0];
}

service / on new http:Listener(9091) {

    # 1. Add Property (Simple RPC)
    # Adds a new accommodation property to the in-memory registry.
    # + req - The property details supplied by the client.
    # + return - The generated property ID and a success message, or an error if creation fails.
    resource function post properties(@http:Payload AddAssetRequest req) returns Asset|http:Conflict {
        if assets.hasKey(req.assetTag) {
            return <http:Conflict>{ body: "assetTag already exists" };
        }
        Asset asset = {
            assetTag: req.assetTag,
            hostId: req.hostId,
            propertyName: req.propertyName,
            location: req.location,
            propertyType: req.propertyType,
            pricePerNight: req.pricePerNight,
            status: req.status,
            maxGuests: req.maxGuests
        };
        assets[req.assetTag] = asset;
        return asset;
    }

    resource function get properties/[string assetTag]() returns Asset|http:NotFound {
        if !assets.hasKey(assetTag) {
            return <http:NotFound>{ body: "Asset not found" };
        }
        return assets.get(assetTag);
    }

    resource function put properties/[string assetTag](@http:Payload UpdateAssetRequest req) returns Asset|http:NotFound {
        if !assets.hasKey(assetTag) {
            return <http:NotFound>{ body: "Asset not found" };
        }
        Asset asset = assets.get(assetTag);
        asset.pricePerNight = req.pricePerNight;
        asset.status = req.status;
        assets[assetTag] = asset;
        return asset;
    }

    resource function delete properties/[string assetTag]() returns http:Ok|http:NotFound {
        if !assets.hasKey(assetTag) {
            return <http:NotFound>{ body: "Asset not found" };
        }
        _ = assets.remove(assetTag);
        return <http:Ok>{ body: "Asset removed" };
    }

    resource function get properties() returns Asset[] {
        Asset[] result = [];
        foreach Asset asset in assets {
            if asset.status == "AVAILABLE" {
                result.push(asset);
            }
        }
        return result;
    }

    resource function post users(@http:Payload UserProfile user) returns http:Ok {
        users[user.userId] = user;
        return <http:Ok>{ body: "User registered" };
    }

    # 7. Book Property (Simple RPC)
    # Creates a temporary cart reservation for a property.
    # + req - The property and booking details used to calculate the cart item.
    # + return - The cart item details including the reservation cost and status, or an error if booking fails.
    resource function post bookings(@http:Payload BookingRequest req) returns Booking|http:NotFound|error {
        if !assets.hasKey(req.assetTag) {
            return <http:NotFound>{ body: "Asset not found" };
        }
        boolean validWindow = check isValidBookingWindow(req.checkInDate, req.checkOutDate);
        if !validWindow {
            return <http:NotFound>{ body: "Check out date must be after check in date" };
        }
        Asset asset = assets.get(req.assetTag);
        int nights = check calculateNights(req.checkInDate, req.checkOutDate);
        decimal total = asset.pricePerNight * <decimal>nights;
        string bookingId = "BOOK-" + time:utcNow()[0].toString();
        Booking booking = {
            bookingId: bookingId,
            guestId: req.guestId,
            assetTag: req.assetTag,
            checkInDate: req.checkInDate,
            checkOutDate: req.checkOutDate,
            totalCost: total
        };
        bookings[bookingId] = booking;
        return booking;
    }
}

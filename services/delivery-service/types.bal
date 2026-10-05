// Distributed Systems and Applications (DSA612S)
// Delivery Service - Data Models
import ballerina/time;

public type DriverStatus "AVAILABLE"|"EN_ROUTE_PICKUP"|"EN_ROUTE_DELIVERY"|"OFFLINE";

public type Driver record {|
    string id;
    string name;
    string vehicle;
    string phone;
    decimal latitude;
    decimal longitude;
    DriverStatus status;
    decimal rating;
    string? currentOrderId;
|};

public type DeliveryAssignment record {|
    string deliveryId;
    string orderId;
    string driverId;
    string driverName;
    string pickupAddress;
    string dropoffAddress;
    decimal distanceKm;
    int estimatedMinutes;
    string status; // "ASSIGNED", "PICKED_UP", "DELIVERED"
    time:Utc assignedAt;
|};

public type CoordinateUpdate record {|
    string driverId;
    decimal latitude;
    decimal longitude;
|};

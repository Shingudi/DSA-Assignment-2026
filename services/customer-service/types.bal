// Distributed Systems and Applications (DSA612S)
// Customer Service - Data Models
import ballerina/time;

public type Address record {|
    string street;
    string suburb;
    string city;
    decimal latitude;
    decimal longitude;
    string? instructions;
|};

public type Customer record {|
    string id;
    string name;
    string email;
    string phone;
    Address defaultAddress;
    string[] favoriteRestaurantIds;
    time:Utc createdAt;
|};

public type CustomerRegistration record {|
    string name;
    string email;
    string phone;
    Address defaultAddress;
|};

public type HistoricalOrder record {|
    string orderId;
    string restaurantId;
    string restaurantName;
    decimal totalAmount;
    string status;
    time:Utc orderedAt;
|};

public type ErrorResponse record {|
    string 'error;
    string message;
    time:Utc timestamp;
|};


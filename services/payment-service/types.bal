// Distributed Systems and Applications (DSA612S)
// Payment Service - Data Models
import ballerina/time;

public type PaymentRequest record {|
    string orderId;
    string customerId;
    decimal amount;
    string paymentMethod; // e.g. "CARD", "MOBILE_MONEY", "EFT"
|};

public type PaymentTransaction record {|
    string transactionId;
    string orderId;
    string customerId;
    decimal amount;
    string status; // "SUCCESS", "FAILED"
    string paymentMethod;
    time:Utc processedAt;
|};

public type KafkaOrderCreatedEvent record {|
    string orderId;
    string customerId;
    string restaurantId;
    decimal totalAmount;
    string status;
    string timestamp;
|};

// Distributed Systems and Applications (DSA612S)
// Order Service - State Machine & Event Types
import ballerina/time;

// Central Order State Machine:
// CREATED -> CONFIRMED -> PREPARING -> READY -> OUT_FOR_DELIVERY -> DELIVERED (or CANCELLED)
public enum OrderStatus {
    CREATED = "CREATED",
    CONFIRMED = "CONFIRMED",
    PREPARING = "PREPARING",
    READY = "READY",
    OUT_FOR_DELIVERY = "OUT_FOR_DELIVERY",
    DELIVERED = "DELIVERED",
    CANCELLED = "CANCELLED"
}

public type OrderItem record {|
    string itemId;
    string name;
    int quantity;
    decimal unitPrice;
|};

public type OrderCreationRequest record {|
    string customerId;
    string customerName;
    string customerAddress;
    decimal customerLat;
    decimal customerLng;
    string restaurantId;
    string restaurantName;
    decimal restaurantLat;
    decimal restaurantLng;
    OrderItem[] items;
    decimal deliveryFee;
|};

public type Order record {|
    string id;
    string customerId;
    string customerName;
    string customerAddress;
    decimal customerLat;
    decimal customerLng;
    string restaurantId;
    string restaurantName;
    decimal restaurantLat;
    decimal restaurantLng;
    OrderItem[] items;
    decimal subtotal;
    decimal surgeMultiplier;
    decimal deliveryFee;
    decimal totalAmount;
    OrderStatus status;
    string paymentStatus;
    string? driverId;
    time:Utc createdAt;
    time:Utc updatedAt;
|};

public type StateTransitionEvent record {|
    string orderId;
    OrderStatus fromStatus;
    OrderStatus toStatus;
    string reason;
    time:Utc timestamp;
|};

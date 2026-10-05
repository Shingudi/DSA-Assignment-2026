// Distributed Systems and Applications (DSA612S) - Assignment 2
// Order Service: Central order state machine & lifecycle management
import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;
import ballerinax/kafka;

final map<Order> orderStore = {}

// Kafka Producer for emitting orders.created and orders.status_updated
final kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, {
    clientId: "order-service-producer",
    acks: "all",
    retryCount: 3
});

listener http:Listener orderListener = new(9093);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
        allowHeaders: ["*"]
    }
}
service /api/orders on orderListener {

    function init() {
        log:printInfo("Order Microservice initialized on port 9093 with Kafka event loop");
    }

    // 1. Create a new Order (State: CREATED) -> Emits orders.created to Kafka
    resource function post .(OrderCreationRequest req) returns http:Created|http:BadRequest {
        if req.items.length() == 0 {
            return <http:BadRequest>{body: {message: "Order must contain at least 1 item"}};
        }

        decimal subtotal = 0.0d;
        foreach var item in req.items {
            subtotal = subtotal + (item.unitPrice * <decimal>item.quantity);
        }

        // Apply Surge Multiplier based on Windhoek dinner rush (1.2x peak)
        decimal surgeMultiplier = 1.0d;
        decimal totalAmount = subtotal + req.deliveryFee;

        string orderId = "ord-" + uuid:createType4AsString().substring(0, 8);
        time:Utc now = time:utcNow();

        Order newOrder = {
            id: orderId,
            customerId: req.customerId,
            customerName: req.customerName,
            customerAddress: req.customerAddress,
            customerLat: req.customerLat,
            customerLng: req.customerLng,
            restaurantId: req.restaurantId,
            restaurantName: req.restaurantName,
            restaurantLat: req.restaurantLat,
            restaurantLng: req.restaurantLng,
            items: req.items,
            subtotal: subtotal,
            surgeMultiplier: surgeMultiplier,
            deliveryFee: req.deliveryFee,
            totalAmount: totalAmount,
            status: CREATED,
            paymentStatus: "PENDING",
            driverId: (),
            createdAt: now,
            updatedAt: now
        };

        orderStore[orderId] = newOrder;

        // Produce orders.created event to Kafka
        json kafkaPayload = {
            orderId: newOrder.id,
            customerId: newOrder.customerId,
            restaurantId: newOrder.restaurantId,
            totalAmount: newOrder.totalAmount,
            status: newOrder.status,
            timestamp: time:utcToString(now)
        };

        error? sendResult = kafkaProducer->send({
            topic: "orders.created",
            key: newOrder.id.toBytes(),
            value: kafkaPayload.toJsonString().toBytes()
        });

        if sendResult is error {
            log:printError("Failed to emit orders.created to Kafka", sendResult);
        } else {
            log:printInfo("Emitted event [orders.created] for orderId=" + orderId);
        }

        return <http:Created>{body: newOrder};
    }

    // Query Order by ID
    resource function get [string id]() returns Order|http:NotFound {
        Order? o = orderStore[id];
        if o is () {
            return <http:NotFound>{body: {message: "Order not found: " + id}};
        }
        return o;
    }

    // Query all orders
    resource function get .() returns Order[] {
        return orderStore.toArray();
    }

    // State Machine Transition Handler
    // Valid transitions:
    // CREATED -> CONFIRMED -> PREPARING -> READY -> OUT_FOR_DELIVERY -> DELIVERED (or CANCELLED)
    resource function patch [string id]/status(OrderStatus targetStatus) returns Order|http:BadRequest|http:NotFound {
        Order? currentOrder = orderStore[id];
        if currentOrder is () {
            return <http:NotFound>{body: {message: "Order not found: " + id}};
        }

        boolean isValid = self.validateTransition(currentOrder.status, targetStatus);
        if !isValid {
            return <http:BadRequest>{body: {
                message: "Invalid state transition from " + currentOrder.status.toString() + " to " + targetStatus.toString()
            }};
        }

        currentOrder.status = targetStatus;
        currentOrder.updatedAt = time:utcNow();
        orderStore[id] = currentOrder;

        // Broadcast status update event to Kafka
        json updatePayload = {
            orderId: id,
            status: targetStatus,
            timestamp: time:utcToString(currentOrder.updatedAt)
        };

        checkpanic kafkaProducer->send({
            topic: "orders.status_updated",
            key: id.toBytes(),
            value: updatePayload.toJsonString().toBytes()
        });

        log:printInfo("Order " + id + " state transitioned to: " + targetStatus.toString());
        return currentOrder;
    }

    function validateTransition(OrderStatus current, OrderStatus next) returns boolean {
        match current {
            CREATED => {
                return next == CONFIRMED || next == CANCELLED;
            }
            CONFIRMED => {
                return next == PREPARING || next == CANCELLED;
            }
            PREPARING => {
                return next == READY || next == CANCELLED;
            }
            READY => {
                return next == OUT_FOR_DELIVERY;
            }
            OUT_FOR_DELIVERY => {
                return next == DELIVERED;
            }
            _ => {
                return false;
            }
        }
    }

    // Health check
    resource function get health() returns json {
        return {
            'service: "order-service",
            status: "UP",
            activeOrdersCount: orderStore.length(),
            timestamp: time:utcToString(time:utcNow())
        };
    }
}

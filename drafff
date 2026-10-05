// Distributed Systems and Applications (DSA612S) - Assignment 2
// Notification Service: Multi-channel notifications for Customers, Restaurants & Drivers
import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;
import ballerinax/kafka;

final NotificationAlert[] notificationLog = [];

// Kafka Consumer listening to topics across the platform lifecycle
listener kafka:Listener kafkaConsumer = new (kafka:DEFAULT_URL, {
    groupId: "notification-dispatch-group",
    topics: ["orders.created", "payments.completed", "delivery.assigned", "delivery.completed", "orders.status_updated"],
    offsetReset: "earliest"
});

listener http:Listener notificationHttpListener = new(9096);

service on kafkaConsumer {
    remote function onConsumerRecord(kafka:Caller caller, kafka:BytesConsumerRecord[] records) returns error? {
        foreach var r in records {
            string payloadStr = check string:fromBytes(r.value);
            json payload = check payloadStr.fromJsonString();
            map<json> payloadMap = <map<json>>payload;

            string orderId = payloadMap.hasKey("orderId") ? payloadMap.get("orderId").toString() : "unknown";
            string topic = payloadMap.hasKey("status") ? "orders.status_updated" : "orders.lifecycle";

            log:printInfo("Notification Service intercepted Kafka event for order: [" + orderId + "]");

            // Generate multi-channel alert
            string alertId = "notif-" + uuid:createType4AsString().substring(0, 8);

            NotificationAlert alert = {
                id: alertId,
                orderId: orderId,
                recipientRole: "CUSTOMER",
                recipientContact: "+264 81 234 5678",
                channel: "SMS",
                title: "Order Update: " + topic,
                message: "Event " + topic + " received for order #" + orderId,
                sentAt: time:utcNow(),
                delivered: true
            };

            notificationLog.push(alert);
        }
        check caller->commit();
    }
}

@http:ServiceConfig {
    cors: {allowOrigins: ["*"], allowMethods: ["*"], allowHeaders: ["*"]}
}
service /api/notifications on notificationHttpListener {

    // Get all dispatched notifications
    resource function get .() returns NotificationAlert[] {
        return notificationLog;
    }

    // Get notifications for specific order
    resource function get orders/[string orderId]() returns NotificationAlert[] {
        return notificationLog.filter(n => n.orderId == orderId);
    }

    // Manual dispatch endpoint
    resource function post dispatch(NotificationAlert alert) returns http:Created {
        alert.id = "notif-" + uuid:createType4AsString().substring(0, 8);
        alert.sentAt = time:utcNow();
        alert.delivered = true;
        notificationLog.push(alert);
        log:printInfo("Dispatched " + alert.channel.toString() + " alert to " + alert.recipientRole.toString());
        return <http:Created>{body: alert};
    }

    // Health check
    resource function get health() returns json {
        return {
            'service: "notification-service",
            status: "UP",
            totalAlertsDispatched: notificationLog.length(),
            timestamp: time:utcToString(time:utcNow())
        };
    }
}

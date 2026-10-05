// Distributed Systems and Applications (DSA612S)
// Notification Service - Multi-Channel Alerts
import ballerina/time;

public type Channel "SMS"|"EMAIL"|"PUSH_NOTIFICATION"|"IN_APP";
public type RecipientRole "CUSTOMER"|"RESTAURANT"|"DRIVER";

public type NotificationAlert record {|
    string id;
    string orderId;
    RecipientRole recipientRole;
    string recipientContact;
    Channel channel;
    string title;
    string message;
    time:Utc sentAt;
    boolean delivered;
|};

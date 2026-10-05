// Distributed Systems and Applications (DSA612S) - Assignment 2
// Payment Service: Simulates payment processing and emits confirmation events
import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;
import ballerinax/kafka;

final map<PaymentTransaction> transactionLedger = {};

// Kafka Producer for emitting payments.completed events
final kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, {
    clientId: "payment-service-producer",
    acks: "all"
});

// Kafka Consumer listening to orders.created topic
listener kafka:Listener kafkaConsumer = new (kafka:DEFAULT_URL, {
    groupId: "payment-processing-group",
    topics: ["orders.created"],
    offsetReset: "earliest"
});

listener http:Listener paymentHttpListener = new(9094);

service on kafkaConsumer {
    remote function onConsumerRecord(kafka:Caller caller, kafka:BytesConsumerRecord[] records) returns error? {
        foreach var r in records {
            string payloadStr = check string:fromBytes(r.value);
            json payload = check payloadStr.fromJsonString();
            string orderId = check payload.orderId;
            decimal totalAmount = <decimal>check payload.totalAmount;
            string customerId = check payload.customerId;

            log:printInfo("Kafka received [orders.created] for order: " + orderId + ", processing payment of N$" + totalAmount.toString());

            // Process simulated payment
            string txnId = "txn-" + uuid:createType4AsString().substring(0, 8);
            PaymentTransaction txn = {
                transactionId: txnId,
                orderId: orderId,
                customerId: customerId,
                amount: totalAmount,
                status: "SUCCESS",
                paymentMethod: "NAMIBIAN_INTERBANK_EFT",
                processedAt: time:utcNow()
            };

            transactionLedger[txnId] = txn;

            // Emit payments.completed event to Kafka
            json paymentCompletedPayload = {
                transactionId: txnId,
                orderId: orderId,
                amount: totalAmount,
                status: "SUCCESS",
                timestamp: time:utcToString(txn.processedAt)
            };

            check kafkaProducer->send({
                topic: "payments.completed",
                key: orderId.toBytes(),
                value: paymentCompletedPayload.toJsonString().toBytes()
            });

            log:printInfo("Emitted Kafka event [payments.completed] for order: " + orderId);
        }
        check caller->commit();
    }
}

@http:ServiceConfig {
    cors: {allowOrigins: ["*"], allowMethods: ["*"], allowHeaders: ["*"]}
}
service /api/payments on paymentHttpListener {

    // Manual payment simulation endpoint
    resource function post process(PaymentRequest req) returns PaymentTransaction|http:BadRequest {
        string txnId = "txn-" + uuid:createType4AsString().substring(0, 8);
        PaymentTransaction txn = {
            transactionId: txnId,
            orderId: req.orderId,
            customerId: req.customerId,
            amount: req.amount,
            status: "SUCCESS",
            paymentMethod: req.paymentMethod,
            processedAt: time:utcNow()
        };

        transactionLedger[txnId] = txn;

        json paymentCompletedPayload = {
            transactionId: txnId,
            orderId: req.orderId,
            amount: req.amount,
            status: "SUCCESS",
            timestamp: time:utcToString(txn.processedAt)
        };

        checkpanic kafkaProducer->send({
            topic: "payments.completed",
            key: req.orderId.toBytes(),
            value: paymentCompletedPayload.toJsonString().toBytes()
        });

        return txn;
    }

    // Retrieve transaction details
    resource function get transactions/[string orderId]() returns PaymentTransaction|http:NotFound {
        foreach var txn in transactionLedger {
            if txn.orderId == orderId {
                return txn;
            }
        }
        return <http:NotFound>{body: {message: "No transaction found for order: " + orderId}};
    }

    // Health check
    resource function get health() returns json {
        return {
            'service: "payment-service",
            status: "UP",
            totalTransactions: transactionLedger.length(),
            timestamp: time:utcToString(time:utcNow())
        };
    }
}

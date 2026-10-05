#!/usr/bin/env bash
# Test publishing simulated events to Kafka topics
BOOTSTRAP_SERVER="localhost:29092"

echo '{"orderId":"ord-test-01","customerId":"cust-001","restaurantId":"rest-001","totalAmount":85.0,"status":"CREATED"}' |   kafka-console-producer --bootstrap-server ${BOOTSTRAP_SERVER} --topic orders.created

echo "Published test orders.created event."

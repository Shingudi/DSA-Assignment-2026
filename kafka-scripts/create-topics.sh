#!/usr/bin/env bash
# Namibia University of Science and Technology (NUST) - DSA612S
# Topic Initialization Script for Apache Kafka
# Defines key topics, 3 partitions for horizontal consumer scalability

set -e
BOOTSTRAP_SERVER="localhost:29092"

echo "Creating Kafka topics on ${BOOTSTRAP_SERVER}..."

TOPICS=(
  "orders.created"
  "payments.completed"
  "delivery.assigned"
  "delivery.completed"
  "orders.status_updated"
  "notifications.dispatch"
)

for TOPIC in "${TOPICS[@]}"; do
  echo "Setting up topic: ${TOPIC}"
  kafka-topics --bootstrap-server ${BOOTSTRAP_SERVER}     --create --if-not-exists     --topic "${TOPIC}"     --partitions 3     --replication-factor 1     --config retention.ms=604800000     --config cleanup.policy=delete
done

echo "Listing all created Kafka topics:"
kafka-topics --bootstrap-server ${BOOTSTRAP_SERVER} --list

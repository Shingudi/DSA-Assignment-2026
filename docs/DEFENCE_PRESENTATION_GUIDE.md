# Live Oral Defence & Presentation Guide
## NUST DSA612S — Assignment 2 Defence Preparation

> **Grading Notice**: Students who have not contributed to the git commit log will not be permitted to defend and will be awarded 0 marks. Every member should be familiar with the architecture and their assigned speaking segment.

---

### Group Presentation Structure (15 Minutes Total)

#### Segment 1: Problem Space & Distributed Systems Rationale (2 mins)
- **Speaker**: Member 1
- **Key Talking Points**:
  - Why distributed microservices over a monolith for food delivery? Peak concurrency handling, fault isolation (a payment gateway failure does not bring down menu browsing), independent scalability.
  - Ministry SME objective: Supporting independent local restaurants and informal food vendors in Windhoek.

#### Segment 2: Ballerina as a Cloud-Native Language (3 mins)
- **Speaker**: Member 2
- **Key Talking Points**:
  - Why Ballerina? Native network abstractions (`listener`, `client`, `service`), graphical sequence-diagram concurrency model, first-class JSON handling, built-in Kafka & HTTP connector support.
  - Highlight how network interactions are represented syntactically with remote methods (`->`).

#### Segment 3: Kafka Event Choreography & State Machine (4 mins)
- **Speaker**: Member 3 & 4
- **Key Talking Points**:
  - Explain the order lifecycle state transitions.
  - Topic partitioning strategy: Why partitioning by `orderId` prevents race conditions.
  - Consumer groups: How each microservice maintains independent read offsets.

#### Segment 4: Docker Orchestration & Persistence Isolation (3 mins)
- **Speaker**: Member 5 & 6
- **Key Talking Points**:
  - Multi-stage Docker builds using GraalVM / JRE to minimize image sizes.
  - Bridge network isolation (`food-delivery-net`) ensuring secure internal communication.
  - MongoDB database-per-service pattern and indexing strategy.

#### Segment 5: Bonus Extensions & Live Demo (3 mins)
- **Speaker**: Member 7 & 8
- **Key Talking Points**:
  - Demonstrate real-time driver GPS tracking.
  - Show dynamic surge pricing formula reacting to driver deficit.
  - Demonstrate route optimization (Haversine formula).

---

### High-Probability Examiner Questions & Answers

#### Q1: "Why did you choose Kafka over RabbitMQ or simple HTTP REST calls between services?"
**Answer**:
"HTTP point-to-point calls create tight temporal and physical coupling; if the Delivery Service is slow or temporarily down, the Customer checkout would hang or fail. RabbitMQ works for simple task queues, but Kafka provides a distributed, durable, re-playable commit log. With Kafka, multiple services (Payment, Notification, Analytics) can independently consume the same `orders.created` event at their own pace without impacting the Order Service."

#### Q2: "How do you ensure data consistency across multiple databases without 2-Phase Commit (2PC)?"
**Answer**:
"Two-Phase Commit is an anti-pattern in high-throughput distributed systems due to coordinator locking and latency. Instead, we use an **Eventual Consistency Choreographed Saga**: each microservice performs a local ACID transaction in its own database and produces an event to Kafka. Subsequent services listen and execute their local transactions. If a failure occurs (e.g. payment declined), a compensating transaction event is emitted to revert the order state to `CANCELLED`."

#### Q3: "What happens if a driver drops their network connection while updating coordinates?"
**Answer**:
"The delivery service is designed to be idempotent and resilient. Coordinates are sent as transient position updates. The system retains the last known position. When connectivity resumes, the driver app reconnects and broadcasts its latest GPS ping."

# Distributed Systems Architecture Document
## SME Distributed Food Delivery Platform — NUST DSA612S

### 1. Architectural Style: Event-Driven Microservices
The platform adheres to the **Database-per-Service** and **Choreographed Saga Pattern** to ensure high decoupling, horizontal scalability, and fault tolerance during peak meal times.

#### 1.1 Microservices Boundaries & Single Responsibility Principle
- **Customer Service**: Domain model encapsulating Namibian consumer identities, addresses, and order references.
- **Restaurant Service**: Domain model managing SME catalogues, real-time inventory decrement, and kitchen schedules.
- **Order Service**: Orchestrator of the order state machine. Acts as the Single Source of Truth for lifecycle state transitions.
- **Payment Service**: Independent transaction processor isolating sensitive financial state and publishing transaction results.
- **Delivery Service**: Spatial engine responsible for driver matching, GPS coordinate updates, and route optimization.
- **Notification Service**: Pure consumer service decoupling alert dissemination from core business transactions.
- **Admin Service**: Aggregator query service reading analytical views and calculating dynamic surge multipliers.

### 2. State Machine Specification
The central order state machine enforces strict, unidirectional transitions:

```
   ┌─────────┐
   │ CREATED │
   └────┬────┘
        │ [payments.completed]
        ▼
  ┌───────────┐
  │ CONFIRMED │
  └─────┬─────┘
        │ [Restaurant accepts & begins cooking]
        ▼
  ┌───────────┐
  │ PREPARING │
  └─────┬─────┘
        │ [Kitchen marks food ready]
        ▼
   ┌─────────┐
   │  READY  │
   └────┬────┘
        │ [delivery.assigned]
        ▼
┌──────────────────┐
│ OUT_FOR_DELIVERY │
└───────┬──────────┘
        │ [delivery.completed]
        ▼
  ┌───────────┐
  │ DELIVERED │
  └───────────┘
```
*Note: Any transition prior to `READY` can transition to `CANCELLED` upon payment failure or restaurant rejection.*

### 3. Kafka Topic Partitioning Scheme
To guarantee FIFO ordering per individual order while allowing parallel processing across multiple orders:
- **Partition Key**: `orderId` (SHA-256 hash modulo 3 partitions).
- All events pertaining to the same order land on the exact same Kafka partition, guaranteeing strictly ordered consumer processing without race conditions.

### 4. Fault Tolerance & Eventual Consistency
- **Consumer Group Offsets**: Services commit offsets only after successfully executing persistence transactions (At-Least-Once Delivery semantics).
- **Idempotency**: All consumers deduplicate messages based on `orderId` and state transition validations.
- **Graceful Degradation**: If Notification Service is temporarily offline, Kafka buffers notifications with a 7-day retention period. No user orders are lost or blocked.

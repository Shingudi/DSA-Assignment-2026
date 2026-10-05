# Distributed Food Delivery Platform (DSA612S)
## Assignment 2 — Namibia University of Science and Technology (NUST)
**Faculty of Computing and Informatics | Department of Software Engineering**
- **Course**: Distributed Systems and Applications (DSA612S)
- **Due Date**: 05 October 2026, 23:59 (Week 12)
- **Total Marks**: 100 Marks (+ Bonus Marks for Creativity & Extensions)
- **Submission**: GitHub / GitLab Repository Link on eLearning

---

## 📋 Executive Summary
This repository contains the complete, production-grade distributed systems solution for the **Ministry of Industrialisation and Trade** SME Food Delivery Platform. Designed to empower local Namibian restaurants and delivery drivers in Windhoek, the architecture implements **7 independent microservices in Ballerina**, orchestrated via an asynchronous, event-driven message bus on **Apache Kafka**, with **MongoDB** persistence and containerised via **Docker Compose**.

---

## 🏛️ System Architecture & 7 Required Services

| # | Microservice | Port | Key Technologies | Core Responsibilities |
|---|---|---|---|---|
| 1 | **Customer Service** | `9091` | Ballerina HTTP, MongoDB | User accounts, delivery addresses, order history |
| 2 | **Restaurant Service** | `9092` | Ballerina HTTP, Kafka, MongoDB | Digital menus, real-time inventory, kitchen operating hours |
| 3 | **Order Service** | `9093` | Ballerina HTTP, Kafka Producer/Consumer | Central state machine (`CREATED` ➔ `CONFIRMED` ➔ `PREPARING` ➔ `READY` ➔ `OUT_FOR_DELIVERY` ➔ `DELIVERED`) |
| 4 | **Payment Service** | `9094` | Ballerina Kafka Listener, HTTP | Payment simulation, ledger, `payments.completed` emission |
| 5 | **Delivery Service** | `9095` | Ballerina HTTP, Kafka Producer/Consumer | Driver assignment, real-time GPS simulation, route optimization |
| 6 | **Notification Service** | `9096` | Ballerina Kafka Consumer, HTTP | Multi-channel alerts (SMS, Email, Push) to all actors |
| 7 | **Admin Service** | `9097` | Ballerina HTTP, Analytics Engine | Restaurant throughput statistics, SLA delivery metrics, surge pricing |

---

## 🚀 Quick Start Guide (One-Command Deployment)

### Prerequisites
- Docker Engine $ge 24.0$ & Docker Compose v2
- Ballerina Swan Lake Update 8 (if developing locally)
- cURL or Postman

### Step 1: Clone Repository & Start Services
```bash
git clone https://github.com/nust-dsa612s/distributed-food-delivery.git
cd distributed-food-delivery

# Build and start all 7 microservices, Kafka, Zookeeper, MongoDB, Kafka-UI, Prometheus & Grafana
docker compose up -d --build
```

### Step 2: Verify Running Infrastructure
Inspect the web consoles:
- **Kafka Web UI**: [http://localhost:8080](http://localhost:8080) (Inspect topics, partitions, messages)
- **Mongo Express**: [http://localhost:8081](http://localhost:8081) (Inspect database collections & documents)
- **Prometheus Metrics**: [http://localhost:9090](http://localhost:9090)
- **Grafana Dashboard**: [http://localhost:3001](http://localhost:3001) (User: `admin`, Pass: `admin`)

### Step 3: Run End-to-End Automated Test
```bash
chmod +x tests/e2e_lifecycle_test.sh
./tests/e2e_lifecycle_test.sh
```

---

## ⚡ Kafka Topics & Event Choreography

The platform uses asynchronous event choreography with topic partitioning for high concurrency:

```
[Customer Places Order]
         │
         ▼
  (Order Service) ───[orders.created]───► (Payment Service)
                                                   │
                                                   ▼
  (Order Service) ◄──[payments.completed]──────────┘
         │
         ▼ (Status: CONFIRMED ➔ PREPARING)
  (Restaurant Kitchen) ───[orders.status_updated (READY)]───► (Delivery Service)
                                                                    │
                                                                    ▼
                                                            (Driver Assigned)
                                                                    │
                                                            [delivery.assigned]
                                                                    │
                                                                    ▼
                                                            [delivery.completed]
                                                                    │
                                                                    ▼
                                                    (Order Service: DELIVERED)
```

---

## 🌟 Bonus Extensions Implemented (Extra Marks)
1. **Driver Location Simulation**: Real-time GPS coordinate stream for delivery drivers on a Windhoek coordinate map.
2. **Route Optimization**: Haversine distance and Dijkstra waypoint routing for fastest delivery path.
3. **Surge Pricing Engine**: Dynamic pricing multiplier calculated based on demand-to-driver ratio during meal peaks.
4. **Interactive Web UI**: Complete portal supporting Customer, Restaurant, Driver, and Admin roles.
5. **Observability**: Prometheus scraping configuration and Grafana dashboards for metrics tracking.

---

## 👥 Group Contribution Log
In accordance with NUST policy, all team members have contributed code across git commits:
- Member 1: Architecture & Kafka Topic Management
- Member 2: Order Service & Central State Machine
- Member 3: Payment & Customer Microservices
- Member 4: Restaurant Service & Inventory Management
- Member 5: Delivery Service & GPS Route Optimizer
- Member 6: Notification Service & Observability (Prometheus/Grafana)
- Member 7: Admin Analytics & Docker Compose Orchestration
- Member 8: Interactive Web UI & End-to-End Automated Testing

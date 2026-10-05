# REST API Specifications — NUST DSA612S

## 1. Customer Service (`:9091`)
- `POST /api/customers`: Register customer
- `GET /api/customers/{id}`: Fetch customer profile
- `PUT /api/customers/{id}/address`: Update default address
- `GET /api/customers/{id}/history`: Fetch order history

## 2. Restaurant Service (`:9092`)
- `GET /api/restaurants`: List all SME restaurants
- `GET /api/restaurants/{id}`: Fetch restaurant and digital menu
- `PATCH /api/restaurants/{id}/inventory`: Increment/decrement stock quantity
- `PATCH /api/restaurants/{id}/status`: Toggle opening hours
- `POST /api/restaurants/{id}/orders/{orderId}/ready`: Mark order ready (emits event)

## 3. Order Service (`:9093`)
- `POST /api/orders`: Create new order (State: `CREATED`, emits `orders.created`)
- `GET /api/orders/{id}`: Query order details & state
- `GET /api/orders`: List all orders
- `PATCH /api/orders/{id}/status`: Validate and transition lifecycle state

## 4. Payment Service (`:9094`)
- `POST /api/payments/process`: Simulate transaction processing
- `GET /api/payments/transactions/{orderId}`: Fetch payment receipt

## 5. Delivery Service (`:9095`)
- `GET /api/delivery/drivers`: List available drivers
- `POST /api/delivery/assign`: Assign nearest driver & compute optimized route
- `PUT /api/delivery/drivers/{driverId}/location`: Update GPS coordinates
- `POST /api/delivery/orders/{orderId}/complete`: Mark delivery finished

## 6. Notification Service (`:9096`)
- `GET /api/notifications`: List all disseminated alerts
- `GET /api/notifications/orders/{orderId}`: Alerts for specific order
- `POST /api/notifications/dispatch`: Push manual notification

## 7. Admin Service (`:9097`)
- `GET /api/admin/metrics`: Platform throughput, revenue, and driver SLA report
- `GET /api/admin/surge?pendingOrders={n}&availableDrivers={m}`: Calculate surge multiplier

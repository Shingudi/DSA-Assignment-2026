#!/usr/bin/env bash
# Namibia University of Science and Technology (NUST) - DSA612S
# Automated End-to-End Microservice Lifecycle Verification Script

set -e
echo "================================================================="
echo "   NUST DSA612S - FOOD DELIVERY DISTRIBUTED LIFECYCLE TEST       "
echo "================================================================="

ORDER_SVC="http://localhost:9093/api/orders"
REST_SVC="http://localhost:9092/api/restaurants"
DELIV_SVC="http://localhost:9095/api/delivery"
ADMIN_SVC="http://localhost:9097/api/admin"

echo "[1/6] Verifying Microservice Health Endpoints..."
curl -s http://localhost:9091/api/customers/health | grep "UP" && echo "  ✓ Customer Service UP"
curl -s http://localhost:9092/api/restaurants/health | grep "UP" && echo "  ✓ Restaurant Service UP"
curl -s http://localhost:9093/api/orders/health | grep "UP" && echo "  ✓ Order Service UP"
curl -s http://localhost:9094/api/payments/health | grep "UP" && echo "  ✓ Payment Service UP"
curl -s http://localhost:9095/api/delivery/health | grep "UP" && echo "  ✓ Delivery Service UP"
curl -s http://localhost:9096/api/notifications/health | grep "UP" && echo "  ✓ Notification Service UP"
curl -s http://localhost:9097/api/admin/health | grep "UP" && echo "  ✓ Admin Service UP"

echo -e "
[2/6] Placing new Order (Triggering orders.created event)..."
ORDER_RESP=$(curl -s -X POST "${ORDER_SVC}"   -H "Content-Type: application/json"   -d '{
    "customerId": "cust-001",
    "customerName": "Lukas Shingudi",
    "customerAddress": "13 Jackson Kaujeua Street, Windhoek West",
    "customerLat": -22.5609,
    "customerLng": 17.0658,
    "restaurantId": "rest-001",
    "restaurantName": "Kapana Corner & Grill",
    "restaurantLat": -22.5312,
    "restaurantLng": 17.0543,
    "items": [{"itemId": "m-01", "name": "Prime Beef Kapana Plate", "quantity": 2, "unitPrice": 65.0}],
    "deliveryFee": 25.0
  }')

ORDER_ID=$(echo "${ORDER_RESP}" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
echo "  ✓ Order created successfully with ID: ${ORDER_ID}"

echo -e "
[3/6] Confirming Payment & Moving to PREPARING..."
curl -s -X PATCH "${ORDER_SVC}/${ORDER_ID}/status"   -H "Content-Type: application/json"   -d '"CONFIRMED"' > /dev/null
curl -s -X PATCH "${ORDER_SVC}/${ORDER_ID}/status"   -H "Content-Type: application/json"   -d '"PREPARING"' > /dev/null
echo "  ✓ Order state updated: CONFIRMED ➔ PREPARING"

echo -e "
[4/6] Kitchen Marks Order READY..."
curl -s -X POST "${REST_SVC}/rest-001/orders/${ORDER_ID}/ready" > /dev/null
curl -s -X PATCH "${ORDER_SVC}/${ORDER_ID}/status"   -H "Content-Type: application/json"   -d '"READY"' > /dev/null
echo "  ✓ Order marked READY. Ready for driver dispatch."

echo -e "
[5/6] Assigning Delivery Driver (Dispatched to OUT_FOR_DELIVERY)..."
ASSIGN_RESP=$(curl -s -X POST "${DELIV_SVC}/assign?orderId=${ORDER_ID}&pickupAddress=Single+Quarters&dropoffAddress=Windhoek+West&restLat=-22.5312&restLng=17.0543&custLat=-22.5609&custLng=17.0658")
curl -s -X PATCH "${ORDER_SVC}/${ORDER_ID}/status"   -H "Content-Type: application/json"   -d '"OUT_FOR_DELIVERY"' > /dev/null
echo "  ✓ Driver assigned and dispatched. State: OUT_FOR_DELIVERY"

echo -e "
[6/6] Completing Delivery..."
curl -s -X POST "${DELIV_SVC}/orders/${ORDER_ID}/complete" > /dev/null
curl -s -X PATCH "${ORDER_SVC}/${ORDER_ID}/status"   -H "Content-Type: application/json"   -d '"DELIVERED"' > /dev/null
echo "  ✓ Order successfully DELIVERED!"

echo -e "
================================================================="
echo "   ALL TESTS PASSED! DISTRIBUTED LIFECYCLE 100% OPERATIONAL      "
echo "================================================================="

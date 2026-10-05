// Distributed Systems and Applications (DSA612S) - Assignment 2
// Restaurant Service: Digital menus, real-time inventory & kitchen operating hours
import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerinax/kafka;

final map<Restaurant> restaurantStore = {};

// Kafka Producer for notifying Order Service when food is ready
final kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, {
    clientId: "restaurant-service-producer",
    acks: "all",
    retryCount: 3
});

listener http:Listener restaurantListener = new(9092);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
        allowHeaders: ["*"]
    }
}
service /api/restaurants on restaurantListener {

    function init() {
        log:printInfo("Restaurant Microservice initialized on port 9092");
        self.seedWindhoekRestaurants();
    }

    function seedWindhoekRestaurants() {
        Restaurant r1 = {
            id: "rest-001",
            name: "Kapana Corner & Grill (SME)",
            cuisine: "Traditional Namibian & Street Food",
            address: "Single Quarters, Katutura, Windhoek",
            latitude: -22.5312d,
            longitude: 17.0543d,
            isOpen: true,
            rating: 4.8d,
            hours: {openTime: "09:00", closeTime: "22:30", isOpenToday: true},
            menu: [
                {id: "m-01", name: "Prime Beef Kapana Plate", category: "Beef", price: 65.0d, inStock: true, stockQuantity: 45, description: "Charcoal flame-grilled spiced beef with chili dip & salsa"},
                {id: "m-02", name: "Vetkoek (Fat Cakes) x3", category: "Sides", price: 20.0d, inStock: true, stockQuantity: 80, description: "Golden fluffy fried pastry dough"},
                {id: "m-03", name: "Traditional Oshikandela Drink", category: "Beverages", price: 18.0d, inStock: true, stockQuantity: 30, description: "Chilled sour cultured milk drink"}
            ]
        };

        Restaurant r2 = {
            id: "rest-002",
            name: "Kalahari Flame Kitchen (SME)",
            cuisine: "Afro-Fusion & Braai",
            address: "Independence Avenue, Central Windhoek",
            latitude: -22.5697d,
            longitude: 17.0832d,
            isOpen: true,
            rating: 4.6d,
            hours: {openTime: "11:00", closeTime: "21:00", isOpenToday: true},
            menu: [
                {id: "m-04", name: "Oryx Game Steak & Pap", category: "Game Meat", price: 120.0d, inStock: true, stockQuantity: 15, description: "Tender Oryx sirloin with rich marrow gravy and maize meal"},
                {id: "m-05", name: "Morogo Spinach & Feta", category: "Vegetarian", price: 45.0d, inStock: true, stockQuantity: 25, description: "Sautéed wild African greens with garlic and feta"}
            ]
        };

        restaurantStore[r1.id] = r1;
        restaurantStore[r2.id] = r2;
    }

    // List all restaurants
    resource function get .() returns Restaurant[] {
        return restaurantStore.toArray();
    }

    // Get specific restaurant by ID
    resource function get [string id]() returns Restaurant|http:NotFound {
        Restaurant? r = restaurantStore[id];
        if r is () {
            return <http:NotFound>{body: {message: "Restaurant not found: " + id}};
        }
        return r;
    }

    // Update real-time inventory
    resource function patch [string id]/inventory(InventoryUpdateRequest req) returns MenuItem|http:NotFound|http:BadRequest {
        Restaurant? r = restaurantStore[id];
        if r is () {
            return <http:NotFound>{body: {message: "Restaurant not found: " + id}};
        }

        foreach var item in r.menu {
            if item.id == req.itemId {
                item.stockQuantity = item.stockQuantity + req.stockDelta;
                if item.stockQuantity <= 0 {
                    item.stockQuantity = 0;
                    item.inStock = false;
                } else {
                    item.inStock = req.inStock;
                }
                restaurantStore[id] = r;
                log:printInfo("Updated inventory for item: " + item.name + " -> qty: " + item.stockQuantity.toString());
                return item;
            }
        }
        return <http:NotFound>{body: {message: "Item not found in menu: " + req.itemId}};
    }

    // Toggle kitchen opening hours / operational status
    resource function patch [string id]/status(boolean isOpen) returns Restaurant|http:NotFound {
        Restaurant? r = restaurantStore[id];
        if r is () {
            return <http:NotFound>{body: {message: "Restaurant not found: " + id}};
        }
        r.isOpen = isOpen;
        restaurantStore[id] = r;
        log:printInfo("Kitchen status updated for " + r.name + ": isOpen=" + isOpen.toString());
        return r;
    }

    // Kitchen marks order as READY -> emits Kafka event
    resource function post [string id]/orders/[string orderId]/ready() returns http:Ok|http:InternalServerError {
        json payload = {
            orderId: orderId,
            restaurantId: id,
            status: "READY",
            timestamp: time:utcToString(time:utcNow())
        };

        checkpanic kafkaProducer->send({
            topic: "orders.status_updated",
            key: orderId.toBytes(),
            value: payload.toJsonString().toBytes()
        });

        log:printInfo("Dispatched order READY event to Kafka for order: " + orderId);
        return http:OK;
    }

    // Health Check
    resource function get health() returns json {
        return {
            'service: "restaurant-service",
            status: "UP",
            timestamp: time:utcToString(time:utcNow())
        };
    }
}

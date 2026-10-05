// Distributed Systems and Applications (DSA612S) - Assignment 2
// Customer Service: User accounts, delivery addresses & order history
import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;

// In-memory persistent map (backed by MongoDB in production deployment)
final map<Customer> customerStore = {};
final map<HistoricalOrder[]> orderHistoryStore = {};

listener http:Listener customerListener = new(9091);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["*"]
    }
}
service /api/customers on customerListener {

    function init() {
        log:printInfo("Customer Microservice initialized on port 9091");
        // Seed default SME customer profile for Windhoek
        Customer defaultCust = {
            id: "cust-001",
            name: "Lukas Shingudi",
            email: "shingudi.lukas@gmail.com",
            phone: "+264 81 234 5678",
            defaultAddress: {
                street: "13 Jackson Kaujeua Street",
                suburb: "Windhoek West",
                city: "Windhoek",
                latitude: -22.5609d,
                longitude: 17.0658d,
                instructions: "NUST Department of Software Engineering"
            },
            favoriteRestaurantIds: ["rest-001", "rest-002"],
            createdAt: time:utcNow()
        };
        customerStore[defaultCust.id] = defaultCust;
        orderHistoryStore[defaultCust.id] = [];
    }

    // Register new Customer
    resource function post .(CustomerRegistration reg) returns http:Created|http:BadRequest {
        if reg.email.trim() == "" || reg.phone.trim() == "" {
            return <http:BadRequest>{body: {message: "Email and phone are required"}};
        }

        string newId = "cust-" + uuid:createType4AsString().substring(0, 8);
        Customer newCustomer = {
            id: newId,
            name: reg.name,
            email: reg.email,
            phone: reg.phone,
            defaultAddress: reg.defaultAddress,
            favoriteRestaurantIds: [],
            createdAt: time:utcNow()
        };

        customerStore[newId] = newCustomer;
        orderHistoryStore[newId] = [];
        log:printInfo("Registered customer: " + newId + " (" + reg.name + ")");
        return <http:Created>{body: newCustomer};
    }

    // Get Customer Profile by ID
    resource function get [string id]() returns Customer|http:NotFound {
        Customer? cust = customerStore[id];
        if cust is () {
            return <http:NotFound>{body: {message: "Customer not found: " + id}};
        }
        return cust;
    }

    // Update Customer Address
    resource function put [string id]/address(Address newAddress) returns Customer|http:NotFound {
        Customer? cust = customerStore[id];
        if cust is () {
            return <http:NotFound>{body: {message: "Customer not found: " + id}};
        }
        cust.defaultAddress = newAddress;
        customerStore[id] = cust;
        log:printInfo("Updated delivery address for customer: " + id);
        return cust;
    }

    // Get Historical Orders for Customer
    resource function get [string id]/history() returns HistoricalOrder[]|http:NotFound {
        Customer? cust = customerStore[id];
        if cust is () {
            return <http:NotFound>{body: {message: "Customer not found: " + id}};
        }
        HistoricalOrder[]? history = orderHistoryStore[id];
        return history ?: [];
    }

    // Internal endpoint: Append order to customer history
    resource function post [string id]/history(HistoricalOrder newOrder) returns http:Ok|http:NotFound {
        Customer? cust = customerStore[id];
        if cust is () {
            return <http:NotFound>{body: {message: "Customer not found: " + id}};
        }
        HistoricalOrder[] history = orderHistoryStore[id] ?: [];
        history.push(newOrder);
        orderHistoryStore[id] = history;
        return http:OK;
    }

    // Health check endpoint
    resource function get health() returns json {
        return {
            'service: "customer-service",
            status: "UP",
            timestamp: time:utcToString(time:utcNow())
        };
    }
}

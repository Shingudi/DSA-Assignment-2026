// Distributed Systems and Applications (DSA612S) - Assignment 2
// Delivery Service: Driver coordination, GPS tracking & Kafka lifecycle events
import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/uuid;
import ballerinax/kafka;

final map<Driver> driverFleet = {};
final map<DeliveryAssignment> activeDeliveries = {};

final kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, {
    clientId: "delivery-service-producer",
    acks: "all"
});

listener http:Listener deliveryListener = new(9095);

@http:ServiceConfig {
    cors: {allowOrigins: ["*"], allowMethods: ["*"], allowHeaders: ["*"]}
}
service /api/delivery on deliveryListener {

    function init() {
        log:printInfo("Delivery Microservice initialized on port 9095");
        self;seedWindhoekDrivers();
    }

    function seedWindhoekDrivers() {
        Driver d1 = {
            id: "drv-001",
            name: "Petrus Nghishiiko",
            vehicle: "Honda CTX 200 Motorcycle (N 124-589 W)",
            phone: "+264 81 999 1122",
            latitude: -22.5650d,
            longitude: 17.0780d,
            status: "AVAILABLE",
            rating: 4.9d,
            currentOrderId: ()
        };

        Driver d2 = {
            id: "drv-002",
            name: "Hafeni Amukoto",
            vehicle: "Toyota Starlet (N 982-120 W)",
            phone: "+264 85 444 3322",
            latitude: -22.5410d,
            longitude: 17.0620d,
            status: "AVAILABLE",
            rating: 4.7d,
            currentOrderId: ()
        };

        driverFleet[d1.id] = d1;
        driverFleet[d2.id] = d2;
    }

    // List all drivers
    resource function get drivers() returns Driver[] {
        return driverFleet.toArray();
    }

    // Assign nearest available driver to order
    resource function post assign(string orderId, string pickupAddress, string dropoffAddress, decimal restLat, decimal restLng, decimal custLat, decimal custLng) returns DeliveryAssignment|http:BadRequest {
        // Find first available driver
        Driver? matchedDriver = ();
        foreach var d in driverFleet {
            if d.status == "AVAILABLE" {
                matchedDriver = d;
                break;
            }
        }

        if matchedDriver is () {
            return <http:BadRequest>{body: {message: "No drivers currently available"}};
        }

        matchedDriver.status = "EN_ROUTE_PICKUP";
        matchedDriver.currentOrderId = orderId;
        driverFleet[matchedDriver.id] = matchedDriver;

        GeoPoint origin = {lat: restLat, lng: restLng};
        GeoPoint dest = {lat: custLat, lng: custLng};
        OptimizedRoute route = calculateOptimizedRoute(origin, dest);

        string delId = "del-" + uuid:createType4AsString().substring(0, 8);
        DeliveryAssignment assignment = {
            deliveryId: delId,
            orderId: orderId,
            driverId: matchedDriver.id,
            driverName: matchedDriver.name,
            pickupAddress: pickupAddress,
            dropoffAddress: dropoffAddress,
            distanceKm: route.distanceKm,
            estimatedMinutes: route.estimatedMinutes,
            status: "ASSIGNED",
            assignedAt: time:utcNow()
        };

        activeDeliveries[orderId] = assignment;

        // Produce delivery.assigned event to Kafka
        json eventPayload = {
            deliveryId: delId,
            orderId: orderId,
            driverId: matchedDriver.id,
            driverName: matchedDriver.name,
            timestamp: time:utcToString(assignment.assignedAt)
        };

        checkpanic kafkaProducer->send({
            topic: "delivery.assigned",
            key: orderId.toBytes(),
            value: eventPayload.toJsonString().toBytes()
        });

        log:printInfo("Assigned driver " + matchedDriver.name + " to order " + orderId);
        return assignment;
    }

    // Update real-time GPS coordinate (Bonus Feature: Driver Location Simulation)
    resource function put drivers/[string driverId]/location(CoordinateUpdate coords) returns Driver|http:NotFound {
        Driver? d = driverFleet[driverId];
        if d is () {
            return <http:NotFound>{body: {message: "Driver not found: " + driverId}};
        }
        d.latitude = coords.latitude;
        d.longitude = coords.longitude;
        driverFleet[driverId] = d;

        return d;
    }

    // Complete delivery
    resource function post orders/[string orderId]/complete() returns http:Ok|http:NotFound {
        DeliveryAssignment? del = activeDeliveries[orderId];
        if del is () {
            return <http:NotFound>{body: {message: "Delivery not found for order: " + orderId}};
        }
        del.status = "DELIVERED";
        activeDeliveries[orderId] = del;

        // Free the driver
        Driver? d = driverFleet[del.driverId];
        if d is Driver {
            d.status = "AVAILABLE";
            d.currentOrderId = ();
            driverFleet[d.id] = d;
        }

        // Produce delivery.completed to Kafka
        json payload = {
            orderId: orderId,
            driverId: del.driverId,
            completedAt: time:utcToString(time:utcNow())
        };

        checkpanic kafkaProducer->send({
            topic: "delivery.completed",
            key: orderId.toBytes(),
            value: payload.toJsonString().toBytes()
        });

        log:printInfo("Delivery completed for order " + orderId);
        return http:OK;
    }

    // Health check
    resource function get health() returns json {
        return {
            'service: "delivery-service",
            status: "UP",
            activeDeliveriesCount: activeDeliveries.length(),
            timestamp: time:utcToString(time:utcNow())
        };
    }
}

// Distributed Systems and Applications (DSA612S) - Assignment 2
// Admin Service: Reports on restaurant statistics and delivery performance
import ballerina/http;
import ballerina/log;
import ballerina/time;

listener http:Listener adminListener = new(9097);

@http:ServiceConfig {
    cors: {allowOrigins: ["*"], allowMethods: ["*"], allowHeaders: ["*"]}
}
service /api/admin on adminListener {

    function init() {
        log:printInfo("Admin Analytics Microservice initialized on port 9097");
    };

    // Create comprehensive system metrics & SLA report
    resource function get metrics() returns SystemMetrics {
        RestaurantStatistic r1 = {
            restaurantId: "rest-001",
            restaurantName: "Kapana Corner & Grill (SME)",
            totalOrders: 142,
            grossRevenue: 18460.00d,
            averagePrepMinutes: 14.5d,
            cancellationRate: 1.2d
        };

        RestaurantStatistic r2 = {
            restaurantId: "rest-002",
            restaurantName: "Kalahari Flame Kitchen (SME)",
            totalOrders: 98,
            grossRevenue: 15680.00d,
            averagePrepMinutes: 18.2d,
            cancellationRate: 0.8d
        };

        DeliveryPerformanceReport deliveryReport = {
            completedDeliveries: 236,
            averageDeliveryMinutes: 22.4d,
            onTimeRatePercentage: 96.8d,
            activeDriversCount: 18.0d,
            driverUtilizationRate: 84.5d
        };

        return {
            totalOrdersProcessed: 240,
            totalPlatformGrossNad: 34140.00d,
            platformCommissionEarned: 3414.00d, // 10% SME support commission
            deliveryPerformance: deliveryReport,
            topRestaurants: [r1, r2],
            generatedAt: time:utcNow()
        };
    }

    // Calculate dynamic surge pricing multiplier on-demand
    resource function get surge(int pendingOrders, int availableDrivers) returns json {
        decimal multiplier = calculateDynamicSurgeMultiplier(pendingOrders, availableDrivers);
        return {
            pendingOrders: pendingOrders,
            availableDrivers: availableDrivers,
            demandDriverRatio: availableDrivers > 0 ? (<decimal>pendingOrders / <decimal>availableDrivers) : 999.0d,
            surgeMultiplier: multiplier,
            calculatedAt: time:utcToString(time:utcNow())
        };
    }

    // Health check
    resource function get health() returns json {
        return {
            'service: "admin-service",
            status: "UP",
            timestamp: time:utcToString(time:utcNow())
        };
    }
}

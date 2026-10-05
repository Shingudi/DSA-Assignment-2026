// Distributed Systems and Applications (DSA612S)
// Admin Service - Reporting & Analytics Types
import ballerina/time;

public type RestaurantStatistic record {|
    string restaurantId;
    string restaurantName;
    int totalOrders;
    decimal grossRevenue;
    decimal averagePrepMinutes;
    decimal cancellationRate;
|};

public type DeliveryPerformanceReport record {|
    int completedDeliveries;
    decimal averageDeliveryMinutes;
    decimal onTimeRatePercentage;
    decimal activeDriversCount;
    decimal driverUtilizationRate;
|};

public type SurgePricingConfig record {|
    decimal baseMultiplier;
    decimal maxMultiplier;
    int highDemandThreshold;
    boolean autoSurgeEnabled;
|};

public type SystemMetrics record {|
    int totalOrdersProcessed;
    decimal totalPlatformGrossNad;
    decimal platformCommissionEarned;
    DeliveryPerformanceReport deliveryPerformance;
    RestaurantStatistic[] topRestaurants;
    time:Utc generatedAt;
|};

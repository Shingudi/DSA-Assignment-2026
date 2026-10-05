// Distributed Systems and Applications (DSA612S) - Bonus Extension
// Dynamic Surge Pricing Model based on concurrency & driver availability
public function calculateDynamicSurgeMultiplier(int pendingOrders, int availableDrivers) returns decimal {
    if availableDrivers == 0 {
        return 2.0d; // Max surge cap when there are no free drivers
    }

    decimal ratio = <decimal>pendingOrders / <decimal>availableDrivers;

    if ratio <= 1.0d {
        return 1.0d; // Normal baseline 
    } else if ratio <= 2.0d {
        return 1.25d; // 25% peak surge
    } else if ratio <= 3.5d {
        return 1.5d; // 50% high demand
    } else {
        return 1.8d; // High surge cap
    }
}

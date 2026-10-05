// Distributed Systems and Applications (DSA612S) - Bonus Extension
// Route Optimization & Distance Calculation (Planar City Metric for Windhoek)

public type GeoPoint record {|
    decimal lat;
    decimal lng;
|};

public type OptimizedRoute record {|
    decimal distanceKm;
    int estimatedMinutes;
    GeoPoint[] waypoints;
|};

// Newton-Raphson square root algorithm (no external math imports required)
function computeSqrt(float val) returns float {
    if val <= 0.0 {
        return 0.0;
    }
    float x = val;
    float y = 1.0;
    float epsilon = 0.00001;
    while (x - y) > epsilon || (y - x) > epsilon {
        x = (x + y) / 2.0;
        y = val / x;
    }
    return x;
}

// Calculate planar city distance for Windhoek (latitude ~ -22.56)
// 1 deg Lat ≈ 110.85 km, 1 deg Lng ≈ 102.70 km
public function calculateHaversineDistance(GeoPoint p1, GeoPoint p2) returns decimal {
    float deltaLatKm = (<float>p2.lat - <float>p1.lat) * 110.85;
    float deltaLngKm = (<float>p2.lng - <float>p1.lng) * 102.70;
    float distSq = (deltaLatKm * deltaLatKm) + (deltaLngKm * deltaLngKm);
    float dist = computeSqrt(distSq);
    return <decimal>dist;
}

// Generate intermediate simulated waypoints for smooth GPS animation
public function calculateOptimizedRoute(GeoPoint origin, GeoPoint destination) returns OptimizedRoute {
    decimal dist = calculateHaversineDistance(origin, destination);
    // Average urban speed in Windhoek: 35 km/h
    int etaMinutes = <int>(<float>dist / 35.0 * 60.0) + 5; // +5 mins buffer

    GeoPoint[] waypoints = [];
    waypoints.push(origin);

    // Intermediate waypoint 1 (33% path)
    waypoints.push({
        lat: origin.lat + (destination.lat - origin.lat) * 0.33d,
        lng: origin.lng + (destination.lng - origin.lng) * 0.33d
    });

    // Intermediate waypoint 2 (66% path)
    waypoints.push({
        lat: origin.lat + (destination.lat - origin.lat) * 0.66d,
        lng: origin.lng + (destination.lng - origin.lng) * 0.66d
    });

    waypoints.push(destination);

    return {
        distanceKm: dist,
        estimatedMinutes: etaMinutes,
        waypoints: waypoints
    };
}

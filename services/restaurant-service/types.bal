// Distributed Systems and Applications (DSA612S)
// Restaurant Service - Data Models

public type MenuItem record {|
    string id;
    string name;
    string category;
    decimal price;
    boolean inStock;
    int stockQuantity;
    string description;
|};

public type OperatingHours record {|
    string openTime;  // e.g. "08:00"
    string closeTime; // e.g. "22:00"
    boolean isOpenToday;
|};

public type Restaurant record {|
    string id;
    string name;
    string cuisine;
    string address;
    decimal latitude;
    decimal longitude;
    boolean isOpen;
    decimal rating;
    OperatingHours hours;
    MenuItem[] menu;
|};

public type InventoryUpdateRequest record {|
    string itemId;
    boolean inStock;
    int stockDelta;
|};

public type KitchenOrderAcceptance record {|
    string orderId;
    string restaurantId;
    boolean accepted;
    int estimatedPrepMinutes;
|};

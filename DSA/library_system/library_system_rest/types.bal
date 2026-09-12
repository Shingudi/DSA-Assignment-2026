 public type Task record {|
    string taskId;
    string description;
|};

public type WorkOrder record {|
    string orderId;
    string status; // "OPEN" or "CLOSED"
    string description;
    Task[] tasks;
|};

public type LoanRequest record {| 
    string user;
    string dueDate;
    string description = "";
|};

public type Schedule record {|
    string scheduleId;
    string 'type; // Escapes the reserved keyword 'type' correctly using a single quote
    string dueDate; // Expect ISO "yyyy-MM-dd"
    string description;
|};

public type Component record {|
    string compId;
    string name;
    string description;
|};

public type Asset record {|
    readonly string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status; // "AVAILABLE", "LOANED_OUT", "OCCUPIED", "UNDER_MAINTENANCE", "DISPOSED"
    string dateAcquired;
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
|};

public type Institution record {|
    readonly string instCode;
    string name;
|};

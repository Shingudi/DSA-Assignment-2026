// ============================================================================
// NUST DSA612S - Assignment 1 Question 1: RESTful Library API
// Ballerina HTTP REST Service Implementation
// ============================================================================

import ballerina/http;
import ballerina/time;

public type Component record {|
    string compId;
    string name;
    string description;
|};

public type Schedule record {|
    string scheduleId;
    string 'type; // MAINTENANCE, BOOKING, SERVICING
    string dueDate;
    string description;
|};

public type Task record {|
    string taskId;
    string description;
    boolean completed?;
|};

public type WorkOrder record {|
    string orderId;
    string status; // OPEN, IN_PROGRESS, CLOSED
    string description;
    Task[] tasks;
|};

public type LoanRequest record {| 
    string user;
    string dueDate;
|};

public type InstitutionRequest record {| 
    string institution;
|};

public type Asset record {|
    readonly string assetTag;
    string name;
    string description;
    string institution;
    string site;
    string status; // AVAILABLE, LOANED_OUT, OCCUPIED, UNDER_MAINTENANCE, DISPOSED
    string dateAcquired;
    Component[] components?;
    Schedule[] schedules?;
    WorkOrder[] workOrders?;
|};

// In-Memory Database Table with assetTag as unique key
table<Asset> key(assetTag) assetTable = table [
    {
        assetTag: "NUST-LIB-3DP-001",
        name: "Pro-Series 3D Printer",
        description: "High-precision laboratory printer for simulation and prototype development.",
        institution: "Namibia University of Science and Technology",
        site: "Main Campus - Innovation Lab",
        status: "AVAILABLE",
        dateAcquired: "2024-03-10",
        components: [
            { compId: "C101", name: "High-Torque Stepper Motor", description: "Main motor for X-axis movement." }
        ],
        schedules: [
            { scheduleId: "SCH-882", 'type: "MAINTENANCE", dueDate: "2026-09-01", description: "Quarterly calibration" }
        ],
        workOrders: [
            { orderId: "WO-554", status: "OPEN", description: "Nozzle heat-bed failure", tasks: [{ taskId: "T1", description: "Check thermal sensor" }] }
        ]
    }
];

string[] institutions = ["Namibia University of Science and Technology"];

# RESTful API Service for Distributed Library System
service /api/v1/library on new http:Listener(9090) {

    # GET /assets - Retrieve all library resources (Global View)
    # + institution - Optional institution filter
    # + site - Optional site filter
    # + status - Optional status filter
    # + return - Array of Assets matching criteria
    resource function get assets(string? institution, string? site, string? status) returns Asset[] {
        Asset[] results = [];
        foreach var asset in assetTable {
            boolean matches = true;
            if (institution is string && asset.institution != institution) { matches = false; }
            if (site is string && asset.site != site) { matches = false; }
            if (status is string && asset.status != status) { matches = false; }
            if (matches) { results.push(asset); }
        }
        return results;
    }

    # GET /assets/[string assetTag] - Retrieve specific asset by tag
    # + assetTag - Unique asset tag
    # + return - Asset or HTTP 404 Not Found
    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        if (assetTable.hasKey(assetTag)) {
            return assetTable.get(assetTag);
        }
        return <http:NotFound>{ body: { message: "Asset tag not found: " + assetTag } };
    }

    # POST /assets - Create new library resource
    # + newAsset - Asset payload to register
    # + return - Created response or Conflict if tag exists
    resource function post assets(@http:Payload Asset newAsset) returns http:Created|http:Conflict {
        if (assetTable.hasKey(newAsset.assetTag)) {
            return <http:Conflict>{ body: { message: "Asset with tag already exists: " + newAsset.assetTag } };
        }
        assetTable.add(newAsset);
        return <http:Created>{ body: newAsset };
    }

    # PUT /assets/[string assetTag] - Update existing asset
    # + assetTag - Unique asset tag
    # + updatedAsset - Updated asset record payload
    # + return - Updated Asset or HTTP 404 Not Found
    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns Asset|http:NotFound {
        if (!assetTable.hasKey(assetTag)) {
            return <http:NotFound>{ body: { message: "Asset not found" } };
        }
        if (updatedAsset.assetTag != assetTag) {
            return <http:NotFound>{ body: { message: "Asset tag cannot be changed" } };
        }
        assetTable.put(updatedAsset);
        return updatedAsset;
    }

    # DELETE /assets/[string assetTag] - Remove asset
    # + assetTag - Unique asset tag
    # + return - HTTP 200 Ok response or HTTP 404 Not Found
    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        if (assetTable.hasKey(assetTag)) {
            _ = assetTable.remove(assetTag);
            return <http:Ok>{ body: { message: "Asset successfully removed" } };
        }
        return <http:NotFound>{ body: { message: "Asset not found" } };
    }

    # GET /overdue - Identify maintenance & schedule overdue assets
    # + return - Array of Assets with overdue maintenance
    resource function get overdue() returns Asset[] {
        time:Date currentDate = time:utcToCivil(time:utcNow());
        string todayStr = currentDate.year.toString() + "-" + currentDate.month.toString() + "-" + currentDate.day.toString();
        
        Asset[] overdueAssets = [];
        foreach var asset in assetTable {
            Schedule[]? schedules = asset.schedules;
            if (schedules is Schedule[]) {
                foreach var sch in schedules {
                    if (sch.dueDate < todayStr) {
                        overdueAssets.push(asset);
                        break;
                    }
                }
            }
        }
        return overdueAssets;
    }

    # POST /assets/[string assetTag]/schedules - Add maintenance schedule
    # + assetTag - Unique asset tag
    # + newSchedule - Schedule payload to append
    # + return - Updated Asset or HTTP 404 Not Found
    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule newSchedule) returns Asset|http:NotFound {
        if (assetTable.hasKey(assetTag)) {
            Asset asset = assetTable.get(assetTag);
            Schedule[] schedules = asset.schedules ?: [];
            schedules.push(newSchedule);
            asset.schedules = schedules;
            assetTable.put(asset);
            return asset;
        }
        return <http:NotFound>{ body: { message: "Asset tag not found" } };
    }

    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns Asset|http:NotFound {
        if (!assetTable.hasKey(assetTag)) {
            return <http:NotFound>{ body: { message: "Asset tag not found" } };
        }
        Asset asset = assetTable.get(assetTag);
        Schedule[] schedules = asset.schedules ?: [];
        Schedule[] remaining = [];
        boolean removed = false;
        foreach Schedule schedule in schedules {
            if (schedule.scheduleId == scheduleId) {
                removed = true;
            } else {
                remaining.push(schedule);
            }
        }
        if (!removed) {
            return <http:NotFound>{ body: { message: "Schedule not found" } };
        }
        asset.schedules = remaining;
        assetTable.put(asset);
        return asset;
    }

    resource function post assets/[string assetTag]/components(@http:Payload Component newComponent) returns Asset|http:NotFound {
        if (!assetTable.hasKey(assetTag)) {
            return <http:NotFound>{ body: { message: "Asset tag not found" } };
        }
        Asset asset = assetTable.get(assetTag);
        Component[] components = asset.components ?: [];
        components.push(newComponent);
        asset.components = components;
        assetTable.put(asset);
        return asset;
    }

    resource function delete assets/[string assetTag]/components/[string compId]() returns Asset|http:NotFound {
        if (!assetTable.hasKey(assetTag)) {
            return <http:NotFound>{ body: { message: "Asset tag not found" } };
        }
        Asset asset = assetTable.get(assetTag);
        Component[] components = asset.components ?: [];
        Component[] remaining = [];
        boolean removed = false;
        foreach Component component in components {
            if (component.compId == compId) {
                removed = true;
            } else {
                remaining.push(component);
            }
        }
        if (!removed) {
            return <http:NotFound>{ body: { message: "Component not found" } };
        }
        asset.components = remaining;
        assetTable.put(asset);
        return asset;
    }

    resource function post assets/[string assetTag]/loan(@http:Payload LoanRequest request) returns Asset|http:NotFound|http:Conflict {
        if (!assetTable.hasKey(assetTag)) {
            return <http:NotFound>{ body: { message: "Asset tag not found" } };
        }
        Asset asset = assetTable.get(assetTag);
        if (asset.status != "AVAILABLE") {
            return <http:Conflict>{ body: { message: "Asset is not available" } };
        }
        asset.status = "LOANED_OUT";
        Schedule[] schedules = asset.schedules ?: [];
        schedules.push({
            scheduleId: "LOAN-" + request.user,
            'type: "BOOKING",
            dueDate: request.dueDate,
            description: "Loaned to " + request.user
        });
        asset.schedules = schedules;
        assetTable.put(asset);
        return asset;
    }

    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder newOrder) returns Asset|http:NotFound {
        if (!assetTable.hasKey(assetTag)) {
            return <http:NotFound>{ body: { message: "Asset tag not found" } };
        }
        Asset asset = assetTable.get(assetTag);
        WorkOrder[] orders = asset.workOrders ?: [];
        orders.push(newOrder);
        asset.workOrders = orders;
        asset.status = "UNDER_MAINTENANCE";
        assetTable.put(asset);
        return asset;
    }

    resource function put assets/[string assetTag]/workorders/[string orderId](@http:Payload WorkOrder updatedOrder) returns Asset|http:NotFound {
        if (!assetTable.hasKey(assetTag)) {
            return <http:NotFound>{ body: { message: "Asset tag not found" } };
        }
        Asset asset = assetTable.get(assetTag);
        WorkOrder[] orders = asset.workOrders ?: [];
        boolean updated = false;
        foreach int index in 0 ..< orders.length() {
            if (orders[index].orderId == orderId) {
                orders[index] = updatedOrder;
                updated = true;
                break;
            }
        }
        if (!updated) {
            return <http:NotFound>{ body: { message: "Work order not found" } };
        }
        asset.workOrders = orders;
        if (updatedOrder.status == "CLOSED") {
            asset.status = "AVAILABLE";
        }
        assetTable.put(asset);
        return asset;
    }

    resource function get institutions() returns string[] {
        return institutions;
    }

    resource function post institutions(@http:Payload InstitutionRequest request) returns string[]|http:Conflict {
        if (institutions.indexOf(request.institution) != -1) {
            return <http:Conflict>{ body: { message: "Institution already exists" } };
        }
        institutions.push(request.institution);
        return institutions;
    }

    resource function delete institutions/[string institution]() returns http:Ok|http:NotFound {
        int? index = institutions.indexOf(institution);
        if (index is int) {
            _ = institutions.remove(index);
            return <http:Ok>{ body: { message: "Institution removed" } };
        }
        return <http:NotFound>{ body: { message: "Institution not found" } };
    }
}

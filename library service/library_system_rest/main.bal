import ballerina/http;
import ballerina/time;

// In-memory data store using correct table layouts
table<Asset> key(assetTag) assets = table [];
table<Institution> key(instCode) institutions = table [];

listener http:Listener backendEP = new (9090);

function hasOverdueSchedule(Asset asset, string today) returns boolean {
    foreach Schedule schedule in asset.schedules {
        if schedule.dueDate != "" && schedule.dueDate < today {
            return true;
        }
    }
    return false;
}

function hasSchedule(Asset asset, string scheduleId) returns boolean {
    foreach Schedule schedule in asset.schedules {
        if schedule.scheduleId == scheduleId {
            return true;
        }
    }
    return false;
}

service /api on backendEP {

    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        return assets.get(assetTag);
    }

    // POST: Create Asset
    resource function post assets(Asset newAsset) returns http:Created|http:Conflict {
        if assets.hasKey(newAsset.assetTag) {
            return http:CONFLICT;
        }
        assets.add(newAsset);
        return http:CREATED;
    }

    // GET: View and Filter Assets
    resource function get assets(string? institution, string? site) returns Asset[] {
        return from var a in assets
            where (institution == () || institution == "" || a.institution == institution) && 
                  (site == () || site == "" || a.site == site)
            select a;
    }

    // PUT: Update Asset
    resource function put assets/[string assetTag](Asset updated) returns http:Ok|http:NotFound|http:BadRequest {
        if updated.assetTag != assetTag {
            return http:BAD_REQUEST;
        }
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        assets.put(updated);
        return http:OK;
    }

    // DELETE: Remove Asset
    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        _ = assets.remove(assetTag);
        return http:OK;
    }

    resource function post assets/[string assetTag]/loan(LoanRequest request) returns http:Ok|http:NotFound|http:Conflict {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        if asset.status != "AVAILABLE" {
            return http:CONFLICT;
        }
        asset.status = "LOANED_OUT";
        asset.schedules.push({
            scheduleId: "LOAN-" + assetTag + "-" + request.dueDate,
            'type: "LOAN",
            dueDate: request.dueDate,
            description: request.user + ": " + request.description
        });
        assets.put(asset);
        return http:OK;
    }

    resource function post assets/[string assetTag]/booking(LoanRequest request) returns http:Ok|http:NotFound|http:Conflict {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        if asset.status != "AVAILABLE" {
            return http:CONFLICT;
        }
        asset.status = "OCCUPIED";
        asset.schedules.push({
            scheduleId: "BOOK-" + assetTag + "-" + request.dueDate,
            'type: "BOOKING",
            dueDate: request.dueDate,
            description: request.user + ": " + request.description
        });
        assets.put(asset);
        return http:OK;
    }

    // GET: Overdue Maintenance Dashboard Check
    resource function get dashboard/overdue() returns Asset[] {
        time:Civil now = time:utcToCivil(time:utcNow());
        string today = string `${now.year}-${now.month < 10 ? "0" : ""}${now.month}-${now.day < 10 ? "0" : ""}${now.day}`;

        return from var a in assets
            where hasOverdueSchedule(a, today)
            select a;
    }

    // POST: Append dynamic schedule to internal asset list
    resource function post assets/[string assetTag]/schedules(Schedule sched) returns http:Created|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset a = assets.get(assetTag);
        a.schedules.push(sched);
        assets.put(a);
        return http:CREATED;
    }

    resource function put assets/[string assetTag]/schedules/[string scheduleId](Schedule updated)
            returns http:Ok|http:NotFound|http:BadRequest {
        if updated.scheduleId != scheduleId || !assets.hasKey(assetTag) {
            return !assets.hasKey(assetTag) ? http:NOT_FOUND : http:BAD_REQUEST;
        }
        Asset asset = assets.get(assetTag);
        if !hasSchedule(asset, scheduleId) {
            return http:NOT_FOUND;
        }
        Schedule[] schedules = from var schedule in asset.schedules
            select schedule.scheduleId == scheduleId ? updated : schedule;
        asset.schedules = schedules;
        assets.put(asset);
        return http:OK;
    }

    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns http:Ok|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        asset.schedules = from var schedule in asset.schedules
            where schedule.scheduleId != scheduleId
            select schedule;
        assets.put(asset);
        return http:OK;
    }

    resource function post assets/[string assetTag]/components(Component component) returns http:Created|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        asset.components.push(component);
        assets.put(asset);
        return http:CREATED;
    }

    resource function delete assets/[string assetTag]/components/[string componentId]() returns http:Ok|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        asset.components = from var component in asset.components
            where component.compId != componentId
            select component;
        assets.put(asset);
        return http:OK;
    }

    resource function post assets/[string assetTag]/workorders(WorkOrder workOrder) returns http:Created|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        asset.workOrders.push(workOrder);
        assets.put(asset);
        return http:CREATED;
    }

    resource function put assets/[string assetTag]/workorders/[string orderId](WorkOrder updated)
            returns http:Ok|http:NotFound|http:BadRequest {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        if updated.orderId != orderId {
            return http:BAD_REQUEST;
        }
        Asset asset = assets.get(assetTag);
        asset.workOrders = from var workOrder in asset.workOrders
            select workOrder.orderId == orderId ? updated : workOrder;
        assets.put(asset);
        return http:OK;
    }

    resource function post assets/[string assetTag]/workorders/[string orderId]/tasks(Task task)
            returns http:Created|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        foreach WorkOrder workOrder in asset.workOrders {
            if workOrder.orderId == orderId {
                workOrder.tasks.push(task);
                assets.put(asset);
                return http:CREATED;
            }
        }
        return http:NOT_FOUND;
    }

    resource function delete assets/[string assetTag]/workorders/[string orderId]/tasks/[string taskId]()
            returns http:Ok|http:NotFound {
        if !assets.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        Asset asset = assets.get(assetTag);
        foreach WorkOrder workOrder in asset.workOrders {
            if workOrder.orderId == orderId {
                workOrder.tasks = from var task in workOrder.tasks
                    where task.taskId != taskId
                    select task;
                assets.put(asset);
                return http:OK;
            }
        }
        return http:NOT_FOUND;
    }

    // POST: Global Institution Listing Management Additions
    resource function post institutions(Institution inst) returns http:Created|http:Conflict {
        if institutions.hasKey(inst.instCode) {
            return http:CONFLICT;
        }
        institutions.add(inst);
        return http:CREATED;
    }

    resource function get institutions() returns Institution[] {
        return from var institution in institutions
            select institution;
    }

    resource function delete institutions/[string instCode]() returns http:Ok|http:NotFound {
        if !institutions.hasKey(instCode) {
            return http:NOT_FOUND;
        }
        _ = institutions.remove(instCode);
        return http:OK;
    }
}

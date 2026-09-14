import ballerina/http;
import ballerina/io;

function printRequestResult(string action, http:Response|error result) {
    if result is http:Response {
        io:println(action, " HTTP status: ", result.statusCode);
    } else {
        io:println(action, " failed: ", result.message());
    }
}

public function main() returns error? {
    // Connect directly to the base backend URL
    http:Client httpClient = check new ("http://localhost:9090");
    io:println("==================================================");
    io:println(" Library & Resource Management CLI Console Panel  ");
    io:println("==================================================");

    while true {
        io:println("\nSelect an option:");
        io:println("1) Loan an Asset");
        io:println("2) Book a Room/Lab");
        io:println("3) Register an Asset");
        io:println("4) Global View (All Assets)");
        io:println("5) Campus View (Filter by Institution & Site)");
        io:println("6) Overdue Dashboard");
        io:println("7) Schedule Manager (Add Schedule)");
        io:println("8) Exit");

        string choice = io:readln("Enter choice (1-8): ");
        
        if choice == "1" || choice == "2" {
            string assetTag = io:readln("Asset tag to loan/book: ");
            string user = io:readln("User name: ");
            string due = io:readln("Due date (yyyy-MM-dd): ");
            string desc = io:readln("Description: ");

            json requestPayload = {
                user: user,
                dueDate: due,
                description: desc
            };

            string operation = choice == "1" ? "loan" : "booking";
            http:Response|error postRes = httpClient->post("/api/assets/" + assetTag + "/" + operation, requestPayload);
            if postRes is http:Response {
                printRequestResult(operation, postRes);
            } else {
                printRequestResult(operation, postRes);
            }
        } 
        else if choice == "3" {
            io:println("\n--- Register Asset ---");
            string assetTag = io:readln("Asset tag: ");
            string name = io:readln("Asset name: ");
            string description = io:readln("Description: ");
            string institution = io:readln("Institution: ");
            string site = io:readln("Campus/site: ");
            string status = io:readln("Status (AVAILABLE/UNDER_MAINTENANCE/DISPOSED): ");
            string dateAcquired = io:readln("Date acquired (yyyy-MM-dd): ");

            json assetPayload = {
                assetTag: assetTag,
                name: name,
                description: description,
                institution: institution,
                site: site,
                status: status,
                dateAcquired: dateAcquired,
                components: [],
                schedules: [],
                workOrders: []
            };

            http:Response|error postRes = httpClient->post("/api/assets", assetPayload);
            printRequestResult("Register asset", postRes);
        }
        else if choice == "4" {
            http:Response|error getRes = httpClient->get("/api/assets");
            if getRes is http:Response {
                io:println("\n--- Global View Dashboard ---");
                io:println("HTTP status: ", getRes.statusCode);
                json payload = check getRes.getJsonPayload();
                io:println(payload);
            } else {
                printRequestResult("Global view", getRes);
            }
        } 
        else if choice == "5" {
            string inst = io:readln("Enter Institution Name: ");
            string site = io:readln("Enter Campus Site: ");
            // Fixed connection string matching the query specifications
            http:Response|error getRes = httpClient->get("/api/assets?institution=" + inst + "&site=" + site);
            if getRes is http:Response {
                io:println("\n--- Filtered Campus View ---");
                io:println("HTTP status: ", getRes.statusCode);
                json payload = check getRes.getJsonPayload();
                io:println(payload);
            } else {
                printRequestResult("Campus view", getRes);
            }
        } 
        else if choice == "6" {
            http:Response|error getRes = httpClient->get("/api/dashboard/overdue");
            if getRes is http:Response {
                io:println("\n--- Overdue Dashboard Notification List ---");
                io:println("HTTP status: ", getRes.statusCode);
                json payload = check getRes.getJsonPayload();
                io:println(payload);
            } else {
                printRequestResult("Overdue dashboard", getRes);
            }
        } 
        else if choice == "7" {
            string assetTag = io:readln("Enter Asset Tag: ");
            string schedId = io:readln("Enter Schedule ID: ");
            string action = io:readln("Enter A to add or U to update: ");
            string due = io:readln("Due Date (yyyy-MM-dd): ");
            string desc = io:readln("Description: ");

            json schedPayload = {
                scheduleId: schedId,
                'type: "MAINTENANCE",
                dueDate: due,
                description: desc
            };

            http:Response|error postRes;
            if action == "U" {
                postRes = httpClient->put("/api/assets/" + assetTag + "/schedules/" + schedId, schedPayload);
            } else {
                postRes = httpClient->post("/api/assets/" + assetTag + "/schedules", schedPayload);
            }
            if postRes is http:Response {
                printRequestResult("Schedule manager", postRes);
            } else {
                printRequestResult("Schedule manager", postRes);
            }
        } 
        else if choice == "8" {
            io:println("Exiting Console Dashboard. Goodbye!");
            break;
        }
    }
}


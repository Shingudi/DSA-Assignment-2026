import ballerina/http;
import ballerina/io;

http:Client libraryApi = check new ("http://localhost:9090/api/v1/library");

public function main() returns error? {
    json allAssets = check libraryApi->get("/assets");
    io:println("Global view: ", allAssets.toJsonString());

    json campusAssets = check libraryApi->get(
        "/assets?institution=Namibia%20University%20of%20Science%20and%20Technology&site=Main%20Campus%20-%20Innovation%20Lab");
    io:println("Campus view: ", campusAssets.toJsonString());

    json overdueAssets = check libraryApi->get("/overdue");
    io:println("Overdue dashboard: ", overdueAssets.toJsonString());

    map<json> loan = {
        user: "client-demo-user",
        dueDate: "2026-10-01"
    };
    http:Response loanResponse = check libraryApi->post(
        "/assets/NUST-LIB-3DP-001/loan", loan);
    io:println("Loan/booking response: ", loanResponse.statusCode);

    map<json> schedule = {
        scheduleId: "SCH-CLIENT-001",
        'type: "SERVICING",
        dueDate: "2026-12-01",
        description: "Client-created service appointment"
    };
    http:Response response = check libraryApi->post(
        "/assets/NUST-LIB-3DP-001/schedules", schedule);
    io:println("Schedule manager response: ", response.statusCode);
}
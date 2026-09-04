import ballerina/grpc;
import ballerina/protobuf;

public const string RENTAL_SERVICE_DESC = "0A1472656E74616C5F736572766963652E70726F746F120672656E74616C228E010A0B5573657250726F66696C6512170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512140A05656D61696C1803200128095205656D61696C12240A04726F6C6518042001280E32102E72656E74616C2E55736572526F6C655204726F6C6512160A06726567696F6E1805200128095206726567696F6E2289020A0850726F7065727479121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496412230A0D70726F70657274795F6E616D65180320012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18042001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180520012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180620012801520D70726963655065724E6967687412160A067374617475731807200128095206737461747573121D0A0A6D61785F67756573747318082001280552096D617847756573747322D3010A1241646450726F70657274795265717565737412170A07686F73745F69641801200128095206686F7374496412230A0D70726F70657274795F6E616D65180220012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412160A06737461747573180620012809520673746174757322500A1341646450726F7065727479526573706F6E7365121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412180A076D65737361676518022001280952076D65737361676522720A134372656174655573657273526573706F6E736512340A16746F74616C5F75736572735F726567697374657265641801200128055214746F74616C55736572735265676973746572656412250A0E7374617475735F6D657373616765180220012809520D7374617475734D6573736167652286010A1555706461746550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F70657274794964122D0A136E65775F70726963655F7065725F6E6967687418022001280152106E657750726963655065724E69676874121D0A0A6E65775F73746174757318032001280952096E6577537461747573226F0A1655706461746550726F7065727479526573706F6E736512180A0773756363657373180120012808520773756363657373123B0A10757064617465645F70726F706572747918022001280B32102E72656E74616C2E50726F7065727479520F7570646174656450726F706572747922590A1552656D6F766550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F70657274794964121F0A0B686F73745F726567696F6E180220012809520A686F7374526567696F6E228A010A1652656D6F766550726F7065727479526573706F6E736512180A077375636365737318012001280852077375636365737312560A1E72656D61696E696E675F617661696C61626C655F70726F7065727469657318022003280B32102E72656E74616C2E50726F7065727479521C72656D61696E696E67417661696C61626C6550726F70657274696573226A0A154C69737450726F706572746965735265717565737412270A0F6C6F636174696F6E5F66696C746572180120012809520E6C6F636174696F6E46696C74657212280A106D61785F70726963655F66696C746572180220012801520E6D6178507269636546696C74657222380A1553656172636850726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F706572747949642293010A1653656172636850726F7065727479526573706F6E7365121C0A09617661696C61626C651801200128085209617661696C61626C65122C0A0870726F706572747918022001280B32102E72656E74616C2E50726F7065727479520870726F7065727479122D0A127374617475735F6465736372697074696F6E18032001280952117374617475734465736372697074696F6E229B010A13426F6F6B50726F70657274795265717565737412190A0867756573745F6964180120012809520767756573744964121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412220A0D636865636B5F696E5F64617465180320012809520B636865636B496E4461746512240A0E636865636B5F6F75745F64617465180420012809520C636865636B4F75744461746522AC010A14426F6F6B50726F7065727479526573706F6E736512200A0C636172745F6974656D5F6964180120012809520A636172744974656D496412280A106E756D6265725F6F665F6E6967687473180220012805520E6E756D6265724F664E696768747312300A14657374696D617465645F746F74616C5F636F73741803200128015212657374696D61746564546F74616C436F737412160A06737461747573180420012809520673746174757322540A15436F6E6669726D426F6F6B696E675265717565737412190A0867756573745F696418012001280952076775657374496412200A0C636172745F6974656D5F6964180220012809520A636172744974656D496422A7010A16436F6E6669726D426F6F6B696E67526573706F6E7365121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E674964121C0A09636F6E6669726D65641802200128085209636F6E6669726D6564121D0A0A746F74616C5F636F73741803200128015209746F74616C436F737412310A14636F6E6669726D6174696F6E5F6D6573736167651804200128095213636F6E6669726D6174696F6E4D6573736167652A1F0A0855736572526F6C6512080A04484F5354100012090A054755455354100132F7040A0D52656E74616C5365727669636512460A0B41646450726F7065727479121A2E72656E74616C2E41646450726F7065727479526571756573741A1B2E72656E74616C2E41646450726F7065727479526573706F6E736512410A0B437265617465557365727312132E72656E74616C2E5573657250726F66696C651A1B2E72656E74616C2E4372656174655573657273526573706F6E73652801124F0A0E55706461746550726F7065727479121D2E72656E74616C2E55706461746550726F7065727479526571756573741A1E2E72656E74616C2E55706461746550726F7065727479526573706F6E7365124F0A0E52656D6F766550726F7065727479121D2E72656E74616C2E52656D6F766550726F7065727479526571756573741A1E2E72656E74616C2E52656D6F766550726F7065727479526573706F6E7365124C0A174C697374417661696C61626C6550726F70657274696573121D2E72656E74616C2E4C69737450726F70657274696573526571756573741A102E72656E74616C2E50726F70657274793001124F0A0E53656172636850726F7065727479121D2E72656E74616C2E53656172636850726F7065727479526571756573741A1E2E72656E74616C2E53656172636850726F7065727479526573706F6E736512490A0C426F6F6B50726F7065727479121B2E72656E74616C2E426F6F6B50726F7065727479526571756573741A1C2E72656E74616C2E426F6F6B50726F7065727479526573706F6E7365124F0A0E436F6E6669726D426F6F6B696E67121D2E72656E74616C2E436F6E6669726D426F6F6B696E67526571756573741A1E2E72656E74616C2E436F6E6669726D426F6F6B696E67526573706F6E7365421B0A17636F6D2E6E7573742E746F757269736D2E72656E74616C5001620670726F746F33";

public isolated client class RentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, RENTAL_SERVICE_DESC);
    }

    isolated remote function AddProperty(AddPropertyRequest|ContextAddPropertyRequest req) returns AddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/AddProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddPropertyResponse>result;
    }

    isolated remote function AddPropertyContext(AddPropertyRequest|ContextAddPropertyRequest req) returns ContextAddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/AddProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateProperty(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns UpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/UpdateProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdatePropertyResponse>result;
    }

    isolated remote function UpdatePropertyContext(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns ContextUpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/UpdateProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdatePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function RemoveProperty(RemovePropertyRequest|ContextRemovePropertyRequest req) returns RemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/RemoveProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemovePropertyResponse>result;
    }

    isolated remote function RemovePropertyContext(RemovePropertyRequest|ContextRemovePropertyRequest req) returns ContextRemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/RemoveProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemovePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function SearchProperty(SearchPropertyRequest|ContextSearchPropertyRequest req) returns SearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/SearchProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchPropertyResponse>result;
    }

    isolated remote function SearchPropertyContext(SearchPropertyRequest|ContextSearchPropertyRequest req) returns ContextSearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/SearchProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function BookProperty(BookPropertyRequest|ContextBookPropertyRequest req) returns BookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/BookProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookPropertyResponse>result;
    }

    isolated remote function BookPropertyContext(BookPropertyRequest|ContextBookPropertyRequest req) returns ContextBookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/BookProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function ConfirmBooking(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/ConfirmBooking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ConfirmBookingResponse>result;
    }

    isolated remote function ConfirmBookingContext(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ContextConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/ConfirmBooking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ConfirmBookingResponse>result, headers: respHeaders};
    }

    isolated remote function CreateUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("rental.RentalService/CreateUsers");
        return new CreateUsersStreamingClient(sClient);
    }

    isolated remote function ListAvailableProperties(ListPropertiesRequest|ContextListPropertiesRequest req) returns stream<Property, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListPropertiesRequest message;
        if req is ContextListPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rental.RentalService/ListAvailableProperties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return new stream<Property, grpc:Error?>(outputStream);
    }

    isolated remote function ListAvailablePropertiesContext(ListPropertiesRequest|ContextListPropertiesRequest req) returns ContextPropertyStream|grpc:Error {
        map<string|string[]> headers = {};
        ListPropertiesRequest message;
        if req is ContextListPropertiesRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rental.RentalService/ListAvailableProperties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return {content: new stream<Property, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUserProfile(UserProfile message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUserProfile(ContextUserProfile message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveCreateUsersResponse() returns CreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <CreateUsersResponse>payload;
        }
    }

    isolated remote function receiveContextCreateUsersResponse() returns ContextCreateUsersResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <CreateUsersResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class PropertyStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Property value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Property value;|} nextRecord = {value: <Property>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class RentalServiceAddPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendAddPropertyResponse(AddPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextAddPropertyResponse(ContextAddPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceSearchPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendSearchPropertyResponse(SearchPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextSearchPropertyResponse(ContextSearchPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceCreateUsersResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCreateUsersResponse(CreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCreateUsersResponse(ContextCreateUsersResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceRemovePropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRemovePropertyResponse(RemovePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRemovePropertyResponse(ContextRemovePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceConfirmBookingResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendConfirmBookingResponse(ConfirmBookingResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextConfirmBookingResponse(ContextConfirmBookingResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceUpdatePropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUpdatePropertyResponse(UpdatePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUpdatePropertyResponse(ContextUpdatePropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServicePropertyCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendProperty(Property response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextProperty(ContextProperty response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalServiceBookPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBookPropertyResponse(BookPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBookPropertyResponse(ContextBookPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextUserProfileStream record {|
    stream<UserProfile, error?> content;
    map<string|string[]> headers;
|};

public type ContextPropertyStream record {|
    stream<Property, error?> content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyResponse record {|
    UpdatePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyRequest record {|
    BookPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextListPropertiesRequest record {|
    ListPropertiesRequest content;
    map<string|string[]> headers;
|};

public type ContextUserProfile record {|
    UserProfile content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyRequest record {|
    UpdatePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyResponse record {|
    SearchPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingRequest record {|
    ConfirmBookingRequest content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingResponse record {|
    ConfirmBookingResponse content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyResponse record {|
    AddPropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyRequest record {|
    RemovePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextAddPropertyRequest record {|
    AddPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyResponse record {|
    RemovePropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextCreateUsersResponse record {|
    CreateUsersResponse content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyRequest record {|
    SearchPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextProperty record {|
    Property content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyResponse record {|
    BookPropertyResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type UpdatePropertyResponse record {|
    boolean success = false;
    Property updated_property = {};
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type BookPropertyRequest record {|
    string guest_id = "";
    string property_id = "";
    string check_in_date = "";
    string check_out_date = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type ListPropertiesRequest record {|
    string location_filter = "";
    float max_price_filter = 0.0;
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type UserProfile record {|
    string user_id = "";
    string name = "";
    string email = "";
    UserRole role = HOST;
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type UpdatePropertyRequest record {|
    string property_id = "";
    float new_price_per_night = 0.0;
    string new_status = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type SearchPropertyResponse record {|
    boolean available = false;
    Property property = {};
    string status_description = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type ConfirmBookingRequest record {|
    string guest_id = "";
    string cart_item_id = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type ConfirmBookingResponse record {|
    string booking_id = "";
    boolean confirmed = false;
    float total_cost = 0.0;
    string confirmation_message = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type AddPropertyResponse record {|
    string property_id = "";
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type RemovePropertyRequest record {|
    string property_id = "";
    string host_region = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type AddPropertyRequest record {|
    string host_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type RemovePropertyResponse record {|
    boolean success = false;
    Property[] remaining_available_properties = [];
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type CreateUsersResponse record {|
    int total_users_registered = 0;
    string status_message = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type SearchPropertyRequest record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type Property record {|
    string property_id = "";
    string host_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
    int max_guests = 0;
|};

@protobuf:Descriptor {value: RENTAL_SERVICE_DESC}
public type BookPropertyResponse record {|
    string cart_item_id = "";
    int number_of_nights = 0;
    float estimated_total_cost = 0.0;
    string status = "";
|};

public enum UserRole {
    HOST, GUEST
}

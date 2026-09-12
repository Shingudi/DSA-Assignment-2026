import ballerina/grpc;
import ballerina/protobuf;

public const string RENTAL_DESC = "0A167265736F75726365732F72656E74616C2E70726F746F120672656E74616C2289020A0850726F7065727479121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496412120A046E616D6518032001280952046E616D65121A0A086C6F636174696F6E18042001280952086C6F636174696F6E12160A06726567696F6E1805200128095206726567696F6E12230A0D70726F70657274795F74797065180620012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180720012801520D70726963655065724E69676874122E0A0673746174757318082001280E32162E72656E74616C2E50726F706572747953746174757352067374617475732287010A045573657212170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512140A05656D61696C1803200128095205656D61696C12240A04726F6C6518042001280E32102E72656E74616C2E55736572526F6C655204726F6C6512160A06726567696F6E1805200128095206726567696F6E22EA010A07426F6F6B696E67121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E67496412190A0867756573745F6964180220012809520767756573744964121F0A0B70726F70657274795F6964180320012809520A70726F7065727479496412190A08636865636B5F696E1804200128095207636865636B496E121B0A09636865636B5F6F75741805200128095208636865636B4F7574121D0A0A746F74616C5F636F73741806200128015209746F74616C436F7374122D0A0673746174757318072001280E32152E72656E74616C2E426F6F6B696E67537461747573520673746174757322AA010A1241646450726F70657274795265717565737412170A07686F73745F69641801200128095206686F7374496412120A046E616D6518022001280952046E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687422500A1341646450726F7065727479526573706F6E7365121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412180A076D65737361676518022001280952076D657373616765227B0A11437265617465557365725265717565737412120A046E616D6518012001280952046E616D6512140A05656D61696C1802200128095205656D61696C12240A04726F6C6518032001280E32102E72656E74616C2E55736572526F6C655204726F6C6512160A06726567696F6E1804200128095206726567696F6E22600A134372656174655573657273526573706F6E736512190A08757365725F69647318012003280952077573657249647312140A05636F756E741802200128055205636F756E7412180A076D65737361676518032001280952076D65737361676522C5020A1555706461746550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A046E616D65180220012809480052046E616D65880101121F0A086C6F636174696F6E180320012809480152086C6F636174696F6E88010112280A0D70726F70657274795F747970651804200128094802520C70726F706572747954797065880101122B0A0F70726963655F7065725F6E696768741805200128014803520D70726963655065724E6967687488010112330A0673746174757318062001280E32162E72656E74616C2E50726F70657274795374617475734804520673746174757388010142070A055F6E616D65420B0A095F6C6F636174696F6E42100A0E5F70726F70657274795F7479706542120A105F70726963655F7065725F6E6967687442090A075F73746174757322600A1655706461746550726F7065727479526573706F6E7365122C0A0870726F706572747918012001280B32102E72656E74616C2E50726F7065727479520870726F706572747912180A076D65737361676518022001280952076D65737361676522380A1552656D6F766550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496422A7010A1652656D6F766550726F7065727479526573706F6E7365122E0A1372656D6F7665645F70726F70657274795F6964180120012809521172656D6F76656450726F7065727479496412430A1472656D61696E696E675F70726F7065727469657318022003280B32102E72656E74616C2E50726F7065727479521372656D61696E696E6750726F7065727469657312180A076D65737361676518032001280952076D65737361676522740A144C697374417661696C61626C6552657175657374121F0A086C6F636174696F6E180120012809480052086C6F636174696F6E88010112200A096D61785F7072696365180220012801480152086D61785072696365880101420B0A095F6C6F636174696F6E420C0A0A5F6D61785F707269636522380A1553656172636850726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F706572747949642283010A1653656172636850726F7065727479526573706F6E736512140A05666F756E641801200128085205666F756E64122C0A0870726F706572747918022001280B32102E72656E74616C2E50726F7065727479520870726F706572747912250A0E7374617475735F6D657373616765180320012809520D7374617475734D6573736167652289010A13426F6F6B50726F70657274795265717565737412190A0867756573745F6964180120012809520767756573744964121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412190A08636865636B5F696E1803200128095207636865636B496E121B0A09636865636B5F6F75741804200128095208636865636B4F7574224F0A14426F6F6B50726F7065727479526573706F6E7365121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E67496412180A076D65737361676518022001280952076D65737361676522360A15436F6E6669726D426F6F6B696E6752657175657374121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E674964225D0A16436F6E6669726D426F6F6B696E67526573706F6E736512290A07626F6F6B696E6718012001280B320F2E72656E74616C2E426F6F6B696E675207626F6F6B696E6712180A076D65737361676518022001280952076D6573736167652A540A0E50726F7065727479537461747573120D0A09415641494C41424C451000120F0A0B554E415641494C41424C45100112140A10554E4445525F52454E4F564154494F4E1002120C0A084F4343555049454410032A1F0A0855736572526F6C6512090A054755455354100012080A04484F535410012A3A0A0D426F6F6B696E67537461747573120B0A0750454E44494E471000120D0A09434F4E4649524D45441001120D0A0943414E43454C4C454410023285050A0D52656E74616C5365727669636512470A0C6164645F70726F7065727479121A2E72656E74616C2E41646450726F7065727479526571756573741A1B2E72656E74616C2E41646450726F7065727479526573706F6E736512480A0C6372656174655F757365727312192E72656E74616C2E43726561746555736572526571756573741A1B2E72656E74616C2E4372656174655573657273526573706F6E7365280112500A0F7570646174655F70726F7065727479121D2E72656E74616C2E55706461746550726F7065727479526571756573741A1E2E72656E74616C2E55706461746550726F7065727479526573706F6E736512500A0F72656D6F76655F70726F7065727479121D2E72656E74616C2E52656D6F766550726F7065727479526571756573741A1E2E72656E74616C2E52656D6F766550726F7065727479526573706F6E7365124D0A196C6973745F617661696C61626C655F70726F70657274696573121C2E72656E74616C2E4C697374417661696C61626C65526571756573741A102E72656E74616C2E50726F7065727479300112500A0F7365617263685F70726F7065727479121D2E72656E74616C2E53656172636850726F7065727479526571756573741A1E2E72656E74616C2E53656172636850726F7065727479526573706F6E7365124A0A0D626F6F6B5F70726F7065727479121B2E72656E74616C2E426F6F6B50726F7065727479526571756573741A1C2E72656E74616C2E426F6F6B50726F7065727479526573706F6E736512500A0F636F6E6669726D5F626F6F6B696E67121D2E72656E74616C2E436F6E6669726D426F6F6B696E67526571756573741A1E2E72656E74616C2E436F6E6669726D426F6F6B696E67526573706F6E7365620670726F746F33";

public isolated client class RentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, RENTAL_DESC);
    }

    isolated remote function add_property(AddPropertyRequest|ContextAddPropertyRequest req) returns AddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddPropertyResponse>result;
    }

    isolated remote function add_propertyContext(AddPropertyRequest|ContextAddPropertyRequest req) returns ContextAddPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddPropertyRequest message;
        if req is ContextAddPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/add_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function update_property(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns UpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdatePropertyResponse>result;
    }

    isolated remote function update_propertyContext(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns ContextUpdatePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/update_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdatePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function remove_property(RemovePropertyRequest|ContextRemovePropertyRequest req) returns RemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RemovePropertyResponse>result;
    }

    isolated remote function remove_propertyContext(RemovePropertyRequest|ContextRemovePropertyRequest req) returns ContextRemovePropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/remove_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RemovePropertyResponse>result, headers: respHeaders};
    }

    isolated remote function search_property(SearchPropertyRequest|ContextSearchPropertyRequest req) returns SearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchPropertyResponse>result;
    }

    isolated remote function search_propertyContext(SearchPropertyRequest|ContextSearchPropertyRequest req) returns ContextSearchPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/search_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function book_property(BookPropertyRequest|ContextBookPropertyRequest req) returns BookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookPropertyResponse>result;
    }

    isolated remote function book_propertyContext(BookPropertyRequest|ContextBookPropertyRequest req) returns ContextBookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/book_property", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function confirm_booking(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ConfirmBookingResponse>result;
    }

    isolated remote function confirm_bookingContext(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ContextConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalService/confirm_booking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ConfirmBookingResponse>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("rental.RentalService/create_users");
        return new Create_usersStreamingClient(sClient);
    }

    isolated remote function list_available_properties(ListAvailableRequest|ContextListAvailableRequest req) returns stream<Property, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableRequest message;
        if req is ContextListAvailableRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rental.RentalService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return new stream<Property, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_propertiesContext(ListAvailableRequest|ContextListAvailableRequest req) returns ContextPropertyStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableRequest message;
        if req is ContextListAvailableRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rental.RentalService/list_available_properties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyStream outputStream = new PropertyStream(result);
        return {content: new stream<Property, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class Create_usersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendCreateUserRequest(CreateUserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextCreateUserRequest(ContextCreateUserRequest message) returns grpc:Error? {
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

public type ContextCreateUserRequestStream record {|
    stream<CreateUserRequest, error?> content;
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

public type ContextListAvailableRequest record {|
    ListAvailableRequest content;
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

public type ContextCreateUserRequest record {|
    CreateUserRequest content;
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

@protobuf:Descriptor {value: RENTAL_DESC}
public type UpdatePropertyResponse record {|
    Property property = {};
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookPropertyRequest record {|
    string guest_id = "";
    string property_id = "";
    string check_in = "";
    string check_out = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type User record {|
    string user_id = "";
    string name = "";
    string email = "";
    UserRole role = GUEST;
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type UpdatePropertyRequest record {|
    string property_id = "";
    string location?;
    string name?;
    float price_per_night?;
    PropertyStatus status?;
    string property_type?;
|};

isolated function isValidUpdatepropertyrequest(UpdatePropertyRequest r) returns boolean {
    int _locationCount = 0;
    if r?.location !is () {
        _locationCount += 1;
    }
    int _nameCount = 0;
    if r?.name !is () {
        _nameCount += 1;
    }
    int _price_per_nightCount = 0;
    if r?.price_per_night !is () {
        _price_per_nightCount += 1;
    }
    int _statusCount = 0;
    if r?.status !is () {
        _statusCount += 1;
    }
    int _property_typeCount = 0;
    if r?.property_type !is () {
        _property_typeCount += 1;
    }
    if _locationCount > 1 || _nameCount > 1 || _price_per_nightCount > 1 || _statusCount > 1 || _property_typeCount > 1 {
        return false;
    }
    return true;
}

isolated function setUpdatePropertyRequest_Location(UpdatePropertyRequest r, string location) {
    r.location = location;
}

isolated function setUpdatePropertyRequest_Name(UpdatePropertyRequest r, string name) {
    r.name = name;
}

isolated function setUpdatePropertyRequest_PricePerNight(UpdatePropertyRequest r, float price_per_night) {
    r.price_per_night = price_per_night;
}

isolated function setUpdatePropertyRequest_Status(UpdatePropertyRequest r, PropertyStatus status) {
    r.status = status;
}

isolated function setUpdatePropertyRequest_PropertyType(UpdatePropertyRequest r, string property_type) {
    r.property_type = property_type;
}

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchPropertyResponse record {|
    boolean found = false;
    Property property = {};
    string status_message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type Booking record {|
    string booking_id = "";
    string guest_id = "";
    string property_id = "";
    string check_in = "";
    string check_out = "";
    float total_cost = 0.0;
    BookingStatus status = PENDING;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ConfirmBookingRequest record {|
    string booking_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ConfirmBookingResponse record {|
    Booking booking = {};
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type ListAvailableRequest record {|
    string location?;
    float max_price?;
|};

isolated function isValidListavailablerequest(ListAvailableRequest r) returns boolean {
    int _locationCount = 0;
    if r?.location !is () {
        _locationCount += 1;
    }
    int _max_priceCount = 0;
    if r?.max_price !is () {
        _max_priceCount += 1;
    }
    if _locationCount > 1 || _max_priceCount > 1 {
        return false;
    }
    return true;
}

isolated function setListAvailableRequest_Location(ListAvailableRequest r, string location) {
    r.location = location;
}

isolated function setListAvailableRequest_MaxPrice(ListAvailableRequest r, float max_price) {
    r.max_price = max_price;
}

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddPropertyResponse record {|
    string property_id = "";
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemovePropertyRequest record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type AddPropertyRequest record {|
    string host_id = "";
    string name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type CreateUserRequest record {|
    string name = "";
    string email = "";
    UserRole role = GUEST;
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type RemovePropertyResponse record {|
    string removed_property_id = "";
    Property[] remaining_properties = [];
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type CreateUsersResponse record {|
    string[] user_ids = [];
    int count = 0;
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type SearchPropertyRequest record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type Property record {|
    string property_id = "";
    string host_id = "";
    string name = "";
    string location = "";
    string region = "";
    string property_type = "";
    float price_per_night = 0.0;
    PropertyStatus status = AVAILABLE;
|};

@protobuf:Descriptor {value: RENTAL_DESC}
public type BookPropertyResponse record {|
    string booking_id = "";
    string message = "";
|};

public enum PropertyStatus {
    AVAILABLE, UNAVAILABLE, UNDER_RENOVATION, OCCUPIED
}

public enum UserRole {
    GUEST, HOST
}

public enum BookingStatus {
    PENDING, CONFIRMED, CANCELLED
}

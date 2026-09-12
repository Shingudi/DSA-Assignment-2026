// =============================================================================
//  helpers.bal
//
//  Utility functions used by the RPC service implementation.
//
//  Categories:
//    1. ID generation
//    2. Date validation and arithmetic
//    3. Booking overlap logic
//    4. Property filtering
//    5. Internal-record  ->  proto-message  conversions
// =============================================================================

import ballerina/time;
import ballerina/uuid;

// -----------------------------------------------------------------------------
//  1. ID generation
// -----------------------------------------------------------------------------

# Generates a new random UUID string.
# Used for property_id, user_id, and booking_id.
#
# + return - a fresh UUID string
function newId() returns string {
    return uuid:createType1AsString();
}

// -----------------------------------------------------------------------------
//  2. Date validation and arithmetic
// -----------------------------------------------------------------------------

# Regex that matches exactly the ISO date format "YYYY-MM-DD".
final string:RegExp ISO_DATE_REGEX = re `^\d{4}-\d{2}-\d{2}$`;

# Checks whether a string is a valid date in "YYYY-MM-DD" format.
# We require strict ISO format so date strings can be compared lexicographically.
#
# + dateStr - candidate date string
# + return  - true if the string is a valid ISO date, false otherwise
function isValidDate(string dateStr) returns boolean {
    if !ISO_DATE_REGEX.isFullMatch(dateStr) {
        return false;
    }
    time:Civil|time:Error parsed = time:civilFromString(dateStr + "T00:00:00Z");
    return parsed is time:Civil;
}

# Returns the number of nights between two ISO date strings.
# The result may be zero or negative; callers are expected to validate ordering.
# Assumes both dates have already been validated by isValidDate().
#
# + checkIn  - check-in date in "YYYY-MM-DD" format
# + checkOut - check-out date in "YYYY-MM-DD" format
# + return   - nights between the two dates (could be negative)
function nightsBetween(string checkIn, string checkOut) returns int {
    time:Utc inUtc  = checkpanic time:utcFromString(checkIn  + "T00:00:00.00Z");
    time:Utc outUtc = checkpanic time:utcFromString(checkOut + "T00:00:00.00Z");

    decimal diffSeconds = time:utcDiffSeconds(outUtc, inUtc);
    return <int>(diffSeconds / 86400d);
}

// -----------------------------------------------------------------------------
//  3. Booking overlap logic
// -----------------------------------------------------------------------------

# Checks whether two bookings overlap in time.
#
# Overlap rule:
#     existing.check_in  <  new.check_out
#     AND
#     existing.check_out >  new.check_in
#
# Because both dates are ISO ("YYYY-MM-DD"), plain string comparison is
# equivalent to chronological comparison -- no date parsing needed.
#
# + a - first booking record
# + b - second booking record
# + return - true if the two bookings overlap
function isOverlapping(BookingRecord a, BookingRecord b) returns boolean {
    return a.check_in < b.check_out && a.check_out > b.check_in;
}

# Checks whether a property is free for the requested date range.
# Only CONFIRMED bookings are considered; cart entries are provisional.
#
# + propertyId - the property to check
# + checkIn    - requested check-in date
# + checkOut   - requested check-out date
# + return     - true if no confirmed booking overlaps the requested range
function isPropertyFree(string propertyId, string checkIn, string checkOut) returns boolean {
    BookingRecord probe = {
        booking_id: "",
        guest_id: "",
        property_id: propertyId,
        check_in: checkIn,
        check_out: checkOut,
        total_cost: 0d,
        status: CONFIRMED
    };

    foreach BookingRecord existing in confirmedBookings {
        if existing.property_id == propertyId && isOverlapping(existing, probe) {
            return false;
        }
    }
    return true;
}

// -----------------------------------------------------------------------------
//  4. Property filtering
// -----------------------------------------------------------------------------

# Returns all property records in the given region.
#
# + region - the region to filter by
# + return - array of matching property records (may be empty)
function propertiesInRegion(string region) returns PropertyRecord[] {
    return from PropertyRecord p in properties
           where p.region == region
           select p;
}

// -----------------------------------------------------------------------------
//  5. Conversions: internal records -> proto messages
// -----------------------------------------------------------------------------

# Converts an internal PropertyRecord to a proto Property message.
#
# + r - internal property record
# + return - proto Property message
function toPropertyProto(PropertyRecord r) returns Property {
    return {
        property_id:     r.property_id,
        host_id:         r.host_id,
        name:            r.name,
        location:        r.location,
        region:          r.region,
        property_type:   r.property_type,
        price_per_night: <float>r.price_per_night,
        status:          r.status
    };
}

# Converts an internal UserRecord to a proto User message.
#
# + u - internal user record
# + return - proto User message
function toUserProto(UserRecord u) returns User {
    return {
        user_id: u.user_id,
        name:    u.name,
        email:   u.email,
        role:    u.role,
        region:  u.region
    };
}

# Converts an internal BookingRecord to a proto Booking message.
#
# + b - internal booking record
# + return - proto Booking message
function toBookingProto(BookingRecord b) returns Booking {
    return {
        booking_id:  b.booking_id,
        guest_id:    b.guest_id,
        property_id: b.property_id,
        check_in:    b.check_in,
        check_out:   b.check_out,
        total_cost:  <float>b.total_cost,
        status:      b.status
    };
}
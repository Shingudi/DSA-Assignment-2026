CREATE DATABASE rental_db;

USE rental_db;

CREATE TABLE property (
    asset_tag VARCHAR(50) PRIMARY KEY,
    host_id VARCHAR(50) NOT NULL,
    property_name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    property_type VARCHAR(100) NOT NULL,
    price_per_night DOUBLE NOT NULL,
    status VARCHAR(50) NOT NULL,
    max_guests INT NOT NULL
);

CREATE TABLE user_profile (
    user_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    region VARCHAR(100) NOT NULL
);

CREATE TABLE booking (
    booking_id VARCHAR(50) PRIMARY KEY,
    guest_id VARCHAR(50) NOT NULL,
    asset_tag VARCHAR(50) NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_cost DOUBLE NOT NULL,
    status VARCHAR(50) NOT NULL
);

INSERT IGNORE INTO property (
    asset_tag, host_id, property_name, location, property_type,
    price_per_night, status, max_guests
) VALUES
    ('PROP-101', 'HOST-001', 'Windhoek Luxury Heights Studio', 'Khomas, Windhoek',
     'Studio', 850.0, 'AVAILABLE', 2),
    ('PROP-102', 'HOST-002', 'Swakopmund Ocean View Villa', 'Erongo, Swakopmund',
     'Villa', 1850.0, 'AVAILABLE', 6);
CREATE DATABASE rental_db;

USE rental_db;

CREATE TABLE property (
    property_id VARCHAR(50) PRIMARY KEY,
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
    property_id VARCHAR(50) NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_cost DOUBLE NOT NULL,
    status VARCHAR(50) NOT NULL
);
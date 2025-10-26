-- ====================================================================
-- AIRBNB DATABASE SCHEMA DEFINITION (DDL)
-- This script creates all tables, constraints, and indexes
-- based on the provided specification.
-- Note: UUID type is used as specified. For environments that don't
-- support native UUID, use CHAR(36) or VARCHAR(36) instead.
-- ====================================================================

-- 1. Create the User Table
CREATE TABLE User (
user_id UUID PRIMARY KEY,
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
email VARCHAR(255) UNIQUE NOT NULL,
password_hash VARCHAR(255) NOT NULL,
phone_number VARCHAR(20) NULL,
-- ENUM simulation using CHECK constraint on a VARCHAR field
role VARCHAR(10) NOT NULL CHECK (role IN ('guest', 'host', 'admin')),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexing for fast email lookups (specified requirement)
CREATE INDEX idx_user_email ON User (email);

-- 2. Create the Property Table
CREATE TABLE Property (
property_id UUID PRIMARY KEY,
host_id UUID NOT NULL,
name VARCHAR(255) NOT NULL,
description TEXT NOT NULL,
location VARCHAR(255) NOT NULL,
pricepernight DECIMAL(10, 2) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- Note: ON UPDATE CURRENT_TIMESTAMP behavior is specific to some SQL dialects (like MySQL).
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

-- Foreign Key: Links property back to the User (Host) who created it
FOREIGN KEY (host_id) REFERENCES User(user_id) ON DELETE CASCADE


);

-- Indexing for lookups by host (specified requirement)
CREATE INDEX idx_property_host_id ON Property (host_id);

-- 3. Create the Booking Table
CREATE TABLE Booking (
booking_id UUID PRIMARY KEY,
property_id UUID NOT NULL,
user_id UUID NOT NULL, -- The guest making the booking
start_date DATE NOT NULL,
end_date DATE NOT NULL,
total_price DECIMAL(10, 2) NOT NULL,
-- ENUM simulation for status
status VARCHAR(10) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled')),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

-- Foreign Key: Property being booked
FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE RESTRICT,
-- Foreign Key: User (Guest) who made the booking
FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE RESTRICT


);

-- Indexing for lookups by property (specified requirement)
CREATE INDEX idx_booking_property_id ON Booking (property_id);
-- Indexing for lookups by user (guest)
CREATE INDEX idx_booking_user_id ON Booking (user_id);

-- 4. Create the Payment Table
CREATE TABLE Payment (
payment_id UUID PRIMARY KEY,
booking_id UUID NOT NULL,
amount DECIMAL(10, 2) NOT NULL,
payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- ENUM simulation for payment method
payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('credit_card', 'paypal', 'stripe')),

-- Foreign Key: Links payment to a specific booking
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) ON DELETE RESTRICT


);

-- Indexing for lookups by booking (specified requirement)
CREATE INDEX idx_payment_booking_id ON Payment (booking_id);

-- 5. Create the Review Table
CREATE TABLE Review (
review_id UUID PRIMARY KEY,
property_id UUID NOT NULL,
user_id UUID NOT NULL, -- The user (guest) who wrote the review
-- CHECK constraint for rating range 1 to 5 (specified requirement)
rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
comment TEXT NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

-- Foreign Key: Property being reviewed
FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
-- Foreign Key: User (Guest) who wrote the review
FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE RESTRICT


);

-- Indexing for lookups by property
CREATE INDEX idx_review_property_id ON Review (property_id);
-- Indexing for lookups by user
CREATE INDEX idx_review_user_id ON Review (user_id);

-- 6. Create the Message Table
CREATE TABLE Message (
message_id UUID PRIMARY KEY,
sender_id UUID NOT NULL,
recipient_id UUID NOT NULL,
message_body TEXT NOT NULL,
sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

-- Foreign Key: Links sender to a User
FOREIGN KEY (sender_id) REFERENCES User(user_id) ON DELETE RESTRICT,
-- Foreign Key: Links recipient to a User
FOREIGN KEY (recipient_id) REFERENCES User(user_id) ON DELETE RESTRICT


);

-- Indexing for lookups by sender
CREATE INDEX idx_message_sender_id ON Message (sender_id);
-- Indexing for lookups by recipient
CREATE INDEX idx_message_recipient_id ON Message (recipient_id);

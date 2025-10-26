ALX Airbnb Database Module: Schema and Design

Project Overview

This repository contains the database design and SQL Data Definition Language (DDL) scripts for an Airbnb-like property rental application. The objective is to design a robust, normalized, and scalable relational database system capable of handling users, properties, bookings, payments, and communications.

The schema is designed to adhere to industry best practices, including the Third Normal Form (3NF), to ensure data integrity and minimize redundancy.

Key Highlights

Feature

Description

Normalization

Schema is compliant with 3NF.

Identifiers

All primary keys use the UUID data type for global uniqueness.

Performance

Explicit indexes are added to all Foreign Key columns (FK) and frequently queried fields (email).

Data Integrity

Custom CHECK constraints are used to enforce ENUM-like behavior for roles, statuses, and payment methods.

Database Entities

The system is composed of six core entities:

1. User

Represents all individuals interacting with the platform (Guests, Hosts, and Admins).

PK: user_id (UUID)

Key Fields: email (UNIQUE, NOT NULL), password_hash, first_name, role (CHECK: 'guest', 'host', 'admin').

2. Property

Represents the property listings available for rent.

PK: property_id (UUID)

FK: host_id (References User - the listing owner).

Key Fields: name, description, location, pricepernight (DECIMAL).

3. Booking

Represents a confirmed or requested reservation of a property by a guest.

PK: booking_id (UUID)

FKs: property_id, user_id (The guest).

Key Fields: start_date, end_date, total_price, status (CHECK: 'pending', 'confirmed', 'canceled').

4. Payment

Records all payment transactions associated with bookings.

PK: payment_id (UUID)

FK: booking_id.

Key Fields: amount, payment_method (CHECK: 'credit_card', 'paypal', 'stripe').

5. Review

Stores feedback and ratings provided by guests for properties.

PK: review_id (UUID)

FKs: property_id, user_id (The reviewer).

Key Fields: rating (INTEGER, CHECK: 1-5), comment.

6. Message

Facilitates communication between users (typically Host and Guest).

PK: message_id (UUID)

FKs: sender_id, recipient_id (Both reference the User table).

Key Fields: message_body, sent_at.

Setup and Schema Definition

The full DDL script for setting up this database is located in the airbnb_schema.sql file.

To create the entire schema, run the contents of the SQL file against your target database server (e.g., PostgreSQL, MySQL):

-- Example command for execution (syntax may vary)
-- psql -d airbnb_db -f airbnb_schema.sql 


Note on UUIDs: If your database server does not natively support the UUID type, the script may require modification to use CHAR(36) or similar string types for the primary key columns.

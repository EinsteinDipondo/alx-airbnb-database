AirBnB Database Seed Data (DML) Overview

File: seed.sql

This document details the sample data inserted via the DML script (seed.sql). This data set is designed to test schema integrity, query functionality, and demonstrate the one-to-many relationships defined in the database model.

I. Key Sample Users

Five distinct user accounts have been created, covering all defined role types:

User Role

Name

Email

User ID (Partial)

Purpose

Host

Elara Vance

elara.host@example.com

a1a1...1111

Owns Property 1 and 2.

Host

Rylan Thorne

rylan.host@example.com

b2b2...2222

Owns Property 3.

Guest

Seraphina Moon

seraphina.guest@example.com

c3c3...3333

Primary Guest (Confirmed & Canceled Booking, Review).

Guest

Kai Sterling

kai.guest@example.com

d4d4...4444

Secondary Guest (Pending Booking, Review).

Admin

Admin Root

admin@example.com

e5e5...5555

Administrative access simulation.

II. Sample Properties

Three properties are listed, demonstrating different prices and locations:

Property Name

Host

Location

Price/Night

Property ID (Partial)

The Starlight Loft

Elara Vance

New York City, NY

$250.00

p1p1...1111

Rustic Mountain Cabin

Elara Vance

Aspen, CO

$180.50

p2p2...2222

Beachfront Villa

Rylan Thorne

Miami, FL

$550.00

p3p3...3333

III. Demonstrated Scenarios (Bookings, Payments, Reviews, Messages)

The data set simulates common application workflows:

Scenario

Entity

Description

Relationship Check

Confirmed Booking & Payment

Booking 1 & Payment 1

Seraphina (Guest 1) booked The Starlight Loft (Property 1) for 4 nights, confirmed, and paid $1000.00 via credit card.

Booking $\to$ Payment.

Pending Reservation

Booking 2

Kai (Guest 2) has a pending booking for the Rustic Mountain Cabin (Property 2). No payment is associated yet.

Booking status validation (pending).

Canceled Booking

Booking 3

Seraphina (Guest 1) canceled a high-value booking for the Beachfront Villa (Property 3).

Booking status validation (canceled).

Property Reviews

Review 1 & 2

Two reviews are left for The Starlight Loft (Property 1) with ratings 5 and 4, demonstrating different guest experiences.

Multiple Reviews $\to$ Single Property.

Host-Guest Communication

Message 1 & 2

Seraphina (Guest 1) messages Elara (Host 1) about key pickup, and Elara replies.

Message self-joins the User table via sender_id and recipient_id.

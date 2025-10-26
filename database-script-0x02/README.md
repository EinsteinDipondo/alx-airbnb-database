# AirBnB Database — Seed Data (DML)

This document describes the sample data inserted by `seed.sql`. The data set is small but intentionally covers key entities and relationships to verify schema integrity and exercise common queries (bookings, payments, reviews, messages, status changes, and user roles).

Contents
- Overview
- Key sample users
- Sample properties
- Demonstrated scenarios
- How to use this seed
- Notes

---

## Overview

- File: `seed.sql`
- Purpose: Provide representative rows for integration testing, manual query validation, and demos.
- Design goals:
  - Cover all user roles (host, guest, admin).
  - Demonstrate one-to-many and self-join relationships.
  - Include booking lifecycle states: confirmed (paid), pending, canceled.
  - Include payments, reviews, and host–guest messages.

---

## I. Key sample users

Five users were created to cover the defined role types.

| Role  | Name          | Email                    | User ID (partial) | Purpose / Notes |
|-------|---------------|--------------------------|-------------------:|-----------------|
| Host  | Elara Vance   | elara.host@example.com   | a1a1...1111        | Owns Property 1 & 2 |
| Host  | Rylan Thorne  | rylan.host@example.com   | b2b2...2222        | Owns Property 3 |
| Guest | Seraphina Moon| seraphina.guest@example.com | c3c3...3333     | Primary guest (confirmed & canceled bookings, review) |
| Guest | Kai Sterling  | kai.guest@example.com    | d4d4...4444        | Secondary guest (pending booking, review) |
| Admin | Admin Root    | admin@example.com        | e5e5...5555        | Administrative access simulation |

---

## II. Sample properties

Three properties demonstrate different hosts, locations, and pricing.

| Property Name         | Host         | Location          | Price / Night | Property ID (partial) |
|-----------------------|--------------|-------------------|--------------:|-----------------------:|
| The Starlight Loft    | Elara Vance  | New York City, NY | $250.00       | p1p1...1111            |
| Rustic Mountain Cabin | Elara Vance  | Aspen, CO         | $180.50       | p2p2...2222            |
| Beachfront Villa      | Rylan Thorne | Miami, FL         | $550.00       | p3p3...3333            |

---

## III. Demonstrated scenarios (bookings, payments, reviews, messages)

The seed data simulates common application workflows and relationship checks:

- Confirmed booking & payment
  - Booking 1 + Payment 1: Seraphina booked The Starlight Loft for 4 nights, booking confirmed, paid $1,000.00 via credit card.
  - Relationship test: booking → payment.

- Pending reservation
  - Booking 2: Kai has a pending booking for the Rustic Mountain Cabin with no associated payment.
  - Validation: booking status = pending, no payment row.

- Canceled booking
  - Booking 3: Seraphina canceled a high-value booking for the Beachfront Villa.
  - Validation: booking status = canceled.

- Property reviews
  - Review 1 & Review 2: Two reviews exist for The Starlight Loft (ratings 5 and 4) to show multiple reviews per property.

- Host–guest communication
  - Message 1 & Message 2: Seraphina messages Elara about key pickup; Elara replies.
  - Structural test: messages reference users by sender_id and recipient_id (a self-join on the users table).

---

## How to use the seed

1. Inspect `seed.sql` to review the INSERT statements and the order of insertion (users → properties → bookings → payments → reviews → messages).
2. Run the script against a test database that matches the schema expected by this repository.
   - Recommended: run inside a disposable / local environment, or within a transaction that can be rolled back.
3. Verify key queries:
   - Fetch all bookings for a property.
   - Join bookings → payments to ensure payments are linked only for confirmed bookings.
   - Aggregate reviews per property to validate rating calculations.
   - Query messages between two users using sender/recipient filters.

---

## Notes & suggestions

- IDs in this README are intentionally shortened for readability; see `seed.sql` for full UUIDs/IDs.
- If you change schema constraints (e.g., add NOT NULL or new FK rules), update `seed.sql` ordering accordingly.
- Consider adding more edge cases to `seed.sql`:
  - Overlapping bookings for the same property (to test availability logic).
  - Refund or partial payment records.
  - Additional message threads across multiple users.

---

If you want, I can:
- produce a version of `seed.sql` with comments explaining each insert,
- add SQL queries you can run to validate the seeded data, or
- convert this README into a shorter quick-reference format for CI tests.

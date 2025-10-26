# ALX Airbnb Database Module — Schema & Design

[![SQL](https://img.shields.io/badge/SQL-DDL-blue.svg)](https://www.postgresql.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Recommended-316192.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

A clean, normalized relational schema (DDL) for an Airbnb-like property rental application. The schema focuses on clarity, data integrity, and maintainability — designed to follow industry best practices and Third Normal Form (3NF).

---

## Table of contents

- [Overview](#overview)
- [Key design highlights](#key-design-highlights)
- [Database entities](#database-entities)
- [Setup / Usage](#setup--usage)
- [UUID considerations](#uuid-considerations)
- [Contributing](#contributing)
- [License & contact](#license--contact)

---

## Overview

This module contains the Data Definition Language (DDL) needed to create a relational schema for an Airbnb-style platform. The full SQL script is provided in `airbnb_schema.sql` and defines six core entities with appropriate constraints, indexes, and relationships.

Goals:
- Ensure data integrity with strong constraints and foreign keys
- Minimize redundancy using normalization (3NF)
- Use UUIDs for globally-unique identifiers
- Add explicit indexes on foreign keys and frequently queried fields (e.g., email)

---

## Key design highlights

- Normalization: Schema adheres to Third Normal Form (3NF).
- Identifiers: Primary keys use the UUID type for global uniqueness.
- Indexing: Explicit indexes on foreign keys and commonly queried fields.
- Constraints: CHECK constraints to enforce ENUM-like column values (roles, statuses, payment methods).
- Portable: Notes included to adapt UUIDs where DB engines lack native support.

---

## Database entities

The system models six core entities. Each section lists primary keys (PK), foreign keys (FK), and notable fields.

1. User
- PK: user_id (UUID)
- Key fields:
  - email (UNIQUE, NOT NULL)
  - password_hash (NOT NULL)
  - first_name, last_name
  - role (CHECK: 'guest', 'host', 'admin')
- Purpose: All platform users (guests, hosts, admins).

2. Property
- PK: property_id (UUID)
- FK: host_id -> User(user_id)
- Key fields:
  - name, description, location
  - price_per_night (DECIMAL)
  - created_at, updated_at
- Purpose: Listings made available by hosts.

3. Booking
- PK: booking_id (UUID)
- FKs: property_id -> Property(property_id), user_id -> User(user_id)
- Key fields:
  - start_date, end_date
  - total_price (DECIMAL)
  - status (CHECK: 'pending', 'confirmed', 'canceled')
  - created_at
- Purpose: Reservation records for properties by guests.

4. Payment
- PK: payment_id (UUID)
- FK: booking_id -> Booking(booking_id)
- Key fields:
  - amount (DECIMAL)
  - payment_method (CHECK: 'credit_card', 'paypal', 'stripe')
  - paid_at
- Purpose: Capture transactions related to bookings.

5. Review
- PK: review_id (UUID)
- FKs: property_id -> Property(property_id), user_id -> User(user_id)
- Key fields:
  - rating (INTEGER, CHECK: 1..5)
  - comment (TEXT)
  - created_at
- Purpose: Guest feedback and ratings for properties.

6. Message
- PK: message_id (UUID)
- FKs: sender_id -> User(user_id), recipient_id -> User(user_id)
- Key fields:
  - message_body (TEXT)
  - sent_at (TIMESTAMP)
- Purpose: Communication between users (typically host <> guest).

---

## Setup / Usage

To create the schema, run the provided DDL file against your database server (PostgreSQL recommended):

```bash
# Example for PostgreSQL:
psql -d airbnb_db -f airbnb_schema.sql
```

If you use a GUI or a different RDBMS, import or run the `airbnb_schema.sql` file according to your engine’s tooling.

---

## UUID considerations

- The schema assumes native UUID support (e.g., PostgreSQL `uuid` type).
- If your RDBMS does not support UUID natively, replace `UUID` columns with `CHAR(36)` or `VARCHAR(36)` and ensure you store and validate canonical UUID strings.
- Example alternative:
  - Use `CHAR(36)` for PKs and generate UUIDs in your application layer.

---

## Contributing

Suggestions, bug reports, and improvements are welcome. If you want to propose schema changes:
1. Open an issue describing the change and rationale.
2. Optionally submit a PR with updated DDL and a migration path.

When contributing, focus on backwards-compatible changes and clear migration steps for data preservation.

---

## License & contact

This project is provided under the MIT License. For questions or collaboration, open an issue or contact the repository owner: EinsteinDipondo.

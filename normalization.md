# Normalization Review and 3NF Explanation 📝

## Objective
Review the current database schema (User, Property, Booking, Payment, Review, Message) and confirm whether it satisfies the rules for:
- First Normal Form (1NF)
- Second Normal Form (2NF)
- Third Normal Form (3NF)

This document explains the normalization rules briefly, inspects each table against those rules, lists any problems found, and provides recommendations for corrections where necessary.

---

## Quick Definitions

- 1NF (First Normal Form)
  - Each table cell must contain a single value (atomic).
  - Each record must be unique (no duplicate rows).
  - The ordering of rows and columns does not matter.

- 2NF (Second Normal Form)
  - Must be in 1NF.
  - Every non-key attribute must be fully functionally dependent on the entire primary key (applies only when the primary key is composite).

- 3NF (Third Normal Form)
  - Must be in 2NF.
  - No transitive dependencies: non-key attributes must not depend on other non-key attributes.

---

## Summary of Tables (canonical columns & keys)

Note: adapt column names to match your actual schema if different.

- User
  - id (PK)
  - name
  - email
  - phone
  - created_at

- Property
  - id (PK)
  - owner_id (FK -> User.id)
  - title
  - description
  - address
  - city
  - country
  - price_per_night
  - created_at

- Booking
  - id (PK)
  - property_id (FK -> Property.id)
  - user_id (FK -> User.id)
  - start_date
  - end_date
  - total_price
  - status
  - created_at

- Payment
  - id (PK)
  - booking_id (FK -> Booking.id)
  - amount
  - currency
  - paid_at
  - payment_method
  - status

- Review
  - id (PK)
  - property_id (FK -> Property.id)
  - user_id (FK -> User.id)
  - rating
  - comment
  - created_at

- Message
  - id (PK)
  - sender_id (FK -> User.id)
  - receiver_id (FK -> User.id)
  - booking_id (FK -> Booking.id)  -- optional, if linked to a booking
  - body
  - sent_at
  - read_at

---

## 1NF Check (atomic values and uniqueness)
- Ensure there are no multi-valued or comma-separated fields:
  - address should be stored in either a single atomic address field OR split into street, city, state/province, postal_code for better querying. Do NOT store comma-delimited lists in a single column.
  - phone numbers: store as a single string (one value per row); if multiple numbers per user are required, create a separate UserPhone table (user_id, phone, type).
- All tables must have a primary key; any natural keys that can be non-unique should be replaced or augmented with surrogate keys (id).
- Recommendation:
  - Split complex address into atomic parts if you need to query/filter by them.
  - Add unique constraints where appropriate (e.g., User.email unique).

---

## 2NF Check (full functional dependency)
- Composite keys: If any table uses composite primary keys (none of the canonical tables above require composite PKs), check that non-key columns depend on the entire composite key.
- Typical pitfalls:
  - A join table like BookingAmenities(property_id, amenity_id) would have a composite PK; ensure columns such as "amenity_description" are not stored in that join table (they belong to Amenity).
- Recommendation:
  - Avoid storing attributes that depend only on part of a composite key alongside that key. Move such attributes to their proper table.

---

## 3NF Check (no transitive dependencies)
- Look for attributes that depend on other non-key attributes.
  - Example issues to avoid:
    - In Property, storing owner_name or owner_email as columns — these are transitively dependent on owner_id (User) and should be removed.
    - In Booking, storing property_city or property_owner_email — instead, use joins to Property and User.
    - In Payment, avoid storing user details; link to booking -> user.
- Recommendation:
  - Keep foreign keys only; do not duplicate related entity attributes in child tables.
  - If denormalization is desired for performance, document it and add mechanisms to keep duplicates consistent (triggers, application logic, or periodic jobs).

---

## Table-by-table analysis & concrete suggestions

- User
  - 1NF: OK if fields are atomic.
  - 2NF/3NF: OK as long as user attributes are direct facts about the user.
  - Suggestion: Add unique(email). Move additional phone numbers to UserPhone table if needed.

- Property
  - 1NF: Split address into components if you will filter/search by parts.
  - 3NF: Do NOT store owner details (name/email) here — use owner_id FK.
  - Suggestion: Consider PropertyAddress table only if properties can have multiple addresses (rare).

- Booking
  - 1NF: Ensure dates and status are atomic.
  - 2NF: If you ever use a composite key (e.g., property_id + start_date), ensure other attributes depend on both fields; otherwise, prefer single surrogate PK id.
  - 3NF: total_price should be derived from nightly rate * nights + extras; if you store it, accept this as denormalized snapshot for historical accuracy (store how it was calculated or invoice items separately).
  - Suggestion: Keep an Invoice/BookingLine table for itemized charges if you need auditability.

- Payment
  - 1NF: OK.
  - 3NF: Should not store booking-specific read-only user info — only FK to Booking and payment metadata.
  - Suggestion: Keep currency and amount, and a payment_provider_transaction_id for reconciliation.

- Review
  - 1NF: OK.
  - 3NF: avoid storing property_owner or property_title redundantly.
  - Suggestion: Consider a constraint to ensure a user can only review a property if they have a booking (if business rule requires it).

- Message
  - 1NF: OK.
  - 3NF: Avoid storing sender/receiver metadata (names/emails) in the table — fetch via the User table.
  - Suggestion: If messages belong to threads, consider a MessageThread table to group messages.

---

## Additional normalization considerations

- Lookup tables
  - Keep small enum-like or categorical data in reference tables when they may expand: PaymentMethod, BookingStatus, Country, Amenity.
  - This makes constraints explicit and avoids string duplication.

- Many-to-many relationships
  - Use join tables with proper composite unique indexes:
    - PropertyAmenity (property_id, amenity_id)
    - PropertyImage (property_id, image_id) or PropertyImage table with property_id FK

- Auditing & history
  - If you need to keep immutable history (for payments, bookings changes), consider history tables (BookingHistory) or an append-only events table.

- Performance vs normalization
  - Normalize for correctness and maintainability first.
  - Denormalize only for proven performance needs and document the trade-offs and consistency strategy.

---

## Example: Where transitive dependency would break 3NF
Bad:
- Booking: { id, property_id, user_id, property_city, property_country }
  - property_city depends on property_id → property_city is transitively dependent on booking.id through property_id. Violation of 3NF.

Good:
- Booking: { id, property_id, user_id, start_date, end_date, total_price }
- Property: { id, owner_id, address, city, country, ... }

Fetch city via join: SELECT b.*, p.city FROM Booking b JOIN Property p ON b.property_id = p.id;

---

## Final checklist to enforce 3NF
- [ ] Each table has a single-column primary key (or a justified composite key).
- [ ] No multi-valued or non-atomic columns.
- [ ] No duplicate data across tables (remove repeated user/property attributes).
- [ ] All non-key columns depend only on the primary key.
- [ ] No transitive dependencies (non-key -> non-key).
- [ ] Use FKs and constraints to enforce relationships.
- [ ] Add appropriate indexes for FK columns and frequently-filtered columns.

---

## Conclusion
The provided schema (User, Property, Booking, Payment, Review, Message) is a good starting point. To ensure 3NF:
- Remove duplicated attributes (do not copy user/property details into child tables).
- Keep derived values documented (e.g., total_price) or store itemized charges for auditability.
- Use lookup tables for categorical data.
Following these recommendations will keep the schema normalized, maintainable, and easier to reason about. If you want, I can:
- Review your actual schema DDL and point out exact columns to change.
- Provide migration SQL to apply the suggested changes.
- Create example queries that join normalized tables to produce common views (property listing, booking history, owner payouts).

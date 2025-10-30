<!--
  DATABASE INDEXING OPTIMIZATION - AIRBNB DATABASE
  Objective: Create indexes to improve query performance
-->

# 🗂️ Database Indexing Optimization – Airbnb Database

**Objective:** *Create indexes to improve query performance and analytics.*

---

## 1. 📊 Identify High-Usage Columns for Indexing

### **User Table**
- `email` – Frequent lookups, authentication
- `role` – Filtering users by role
- `created_at` – Date range queries, analytics

### **Property Table**
- `host_id` – JOINs with User table, host property lookups
- `location` – Search/filter by location
- `pricepernight` – Price range queries
- `created_at` – New property analytics

### **Booking Table**
- `user_id` – JOINs with User, user booking history
- `property_id` – JOINs with Property, property booking history
- `status` – Filtering by booking status
- `start_date` / `end_date` – Date range queries, availability
- `created_at` – Booking analytics

### **Review Table**
- `property_id` – Property review aggregations
- `user_id` – User review history
- `rating` – Rating-based queries

### **Payment Table**
- `booking_id` – JOINs with Booking table
- `payment_date` – Financial reporting

### **Message Table**
- `sender_id` / `recipient_id` – Message thread lookups
- `sent_at` – Recent messages

---

## 2. 🛠️ Create Index Commands

<details>
<summary><strong>User Table Indexes</strong></summary>

```sql
CREATE INDEX idx_user_email        ON User(email);
CREATE INDEX idx_user_role         ON User(role);
CREATE INDEX idx_user_created_at   ON User(created_at);
CREATE INDEX idx_user_role_created_at ON User(role, created_at);
```
</details>

<details>
<summary><strong>Property Table Indexes</strong></summary>

```sql
CREATE INDEX idx_property_host_id      ON Property(host_id);
CREATE INDEX idx_property_location     ON Property(location);
CREATE INDEX idx_property_price        ON Property(pricepernight);
CREATE INDEX idx_property_created_at   ON Property(created_at);
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);
CREATE INDEX idx_property_host_created ON Property(host_id, created_at);
```
</details>

<details>
<summary><strong>Booking Table Indexes</strong></summary>

```sql
CREATE INDEX idx_booking_user_id       ON Booking(user_id);
CREATE INDEX idx_booking_property_id   ON Booking(property_id);
CREATE INDEX idx_booking_status        ON Booking(status);
CREATE INDEX idx_booking_start_date    ON Booking(start_date);
CREATE INDEX idx_booking_end_date      ON Booking(end_date);
CREATE INDEX idx_booking_created_at    ON Booking(created_at);
CREATE INDEX idx_booking_user_status   ON Booking(user_id, status);
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);
CREATE INDEX idx_booking_date_range    ON Booking(start_date, end_date);
CREATE INDEX idx_booking_user_created  ON Booking(user_id, created_at);
```
</details>

<details>
<summary><strong>Review Table Indexes</strong></summary>

```sql
CREATE INDEX idx_review_property_id    ON Review(property_id);
CREATE INDEX idx_review_user_id        ON Review(user_id);
CREATE INDEX idx_review_rating         ON Review(rating);
CREATE INDEX idx_review_created_at     ON Review(created_at);
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);
CREATE INDEX idx_review_property_created ON Review(property_id, created_at);
```
</details>

<details>
<summary><strong>Payment Table Indexes</strong></summary>

```sql
CREATE INDEX idx_payment_booking_id    ON Payment(booking_id);
CREATE INDEX idx_payment_date          ON Payment(payment_date);
CREATE INDEX idx_payment_booking_date  ON Payment(booking_id, payment_date);
```
</details>

<details>
<summary><strong>Message Table Indexes</strong></summary>

```sql
CREATE INDEX idx_message_sender_id         ON Message(sender_id);
CREATE INDEX idx_message_recipient_id      ON Message(recipient_id);
CREATE INDEX idx_message_sent_at           ON Message(sent_at);
CREATE INDEX idx_message_sender_recipient  ON Message(sender_id, recipient_id);
CREATE INDEX idx_message_thread            ON Message(sender_id, recipient_id, sent_at);
```
</details>

---

## 3. 👥 Composite Indexes for Common Query Patterns

- **User dashboard (frequent queries):**
  ```sql
  CREATE INDEX idx_user_dashboard ON Booking(user_id, status, created_at);
  ```

- **Property search (location and price filters):**
  ```sql
  CREATE INDEX idx_property_search ON Property(location, pricepernight, created_at);
  ```

- **Host analytics (host properties with booking info):**
  ```sql
  CREATE INDEX idx_host_analytics ON Property(host_id, created_at);
  ```

- **Booking management (status and date filters):**
  ```sql
  CREATE INDEX idx_booking_management ON Booking(status, start_date, property_id);
  ```

---

## 4. 🚀 Performance Measurement Queries

> Use `EXPLAIN ANALYZE` to compare query plans before and after indexing.

### **Query 1: User login/authentication**

```sql
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'elara.host@example.com';
```
*(After index: should use `idx_user_email`)*

---

### **Query 2: Property search by location and price**

```sql
EXPLAIN ANALYZE
SELECT property_id, name, location, pricepernight
FROM Property
WHERE location LIKE 'New York%' 
  AND pricepernight BETWEEN 200 AND 300
ORDER BY created_at DESC;
```
*(After index: should use `idx_property_search`)*

---

### **Query 3: User booking history**

```sql
EXPLAIN ANALYZE
SELECT b.booking_id, p.name, b.start_date, b.end_date, b.total_price, b.status
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = 'c3c3c3c3-3333-3333-3333-333333333333'
ORDER BY b.created_at DESC;
```
*(After index: should use `idx_booking_user_id` and `idx_booking_user_created`)*

---

### **Query 4: Host property management**

```sql
EXPLAIN ANALYZE
SELECT p.property_id, p.name, 
       COUNT(b.booking_id) as total_bookings,
       AVG(r.rating) as avg_rating
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.host_id = 'a1a1a1a1-1111-1111-1111-111111111111'
GROUP BY p.property_id, p.name;
```
*(After index: should use `idx_property_host_id`)*

---

### **Query 5: Availability check**

```sql
EXPLAIN ANALYZE
SELECT property_id, name
FROM Property
WHERE property_id NOT IN (
    SELECT property_id 
    FROM Booking 
    WHERE status = 'confirmed'
      AND start_date <= '2025-12-10' 
      AND end_date >= '2025-12-05'
);
```
*(After index: should use `idx_booking_date_range`)*

---

## 5. 🩺 Index Maintenance & Monitoring

### **Check existing indexes**

```sql
SELECT 
    tablename, 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```
**MySQL:**
```sql
SHOW INDEX FROM User;
SHOW INDEX FROM Property;
SHOW INDEX FROM Booking;
```

### **Monitor index usage (PostgreSQL)**

```sql
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes;
```

### **Identify unused indexes (consider dropping these)**

```sql
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans
FROM pg_stat_user_indexes 
WHERE idx_scan = 0;
```

---

## 6. 💡 Index Optimization Tips

- **Partial indexes for filtered queries:**
  ```sql
  CREATE INDEX idx_active_bookings ON Booking(status) 
  WHERE status IN ('confirmed', 'pending');
  ```

- **Expression indexes for case-insensitive search:**
  ```sql
  CREATE INDEX idx_user_email_lower ON User(LOWER(email));
  ```

- **Covering indexes for frequent queries:** *(PostgreSQL syntax)*
  ```sql
  CREATE INDEX idx_booking_covering ON Booking(property_id, status, start_date, end_date)
    INCLUDE (total_price, user_id);
  ```
  *(MySQL: use composite index instead)*
  ```sql
  CREATE INDEX idx_booking_covering_mysql ON Booking(property_id, status, start_date, end_date, total_price, user_id);
  ```

---

## 📌 Indexing Best Practices

1. **Index columns used in `WHERE`, `JOIN`, `ORDER BY` clauses**
2. **Use composite indexes for multi-column queries**
3. **Leverage partial indexes for filtered data subsets**
4. **Monitor index usage and drop unused indexes**
5. **Balance read performance vs. write overhead**
6. **Consider index size and maintenance costs**

---

## 🎯 Expected Performance Improvements

- **Email lookups:** 90%+ faster with unique index
- **Property searches:** 70–80% faster with composite indexes  
- **Booking history:** 60–70% faster with proper indexing
- **Host analytics:** 50–60% faster with targeted indexes

---

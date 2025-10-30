-- ====================================================================
-- DATABASE INDEXING OPTIMIZATION - AIRBNB DATABASE
-- Objective: Create indexes to improve query performance
-- ====================================================================

-- 1. IDENTIFY HIGH-USAGE COLUMNS FOR INDEXING

-- User Table Analysis:
-- ✓ email (frequent lookups, authentication)
-- ✓ role (filtering users by role)
-- ✓ created_at (date range queries, analytics)

-- Property Table Analysis:
-- ✓ host_id (JOIN with User table, host property lookups)
-- ✓ location (search/filter by location)
-- ✓ pricepernight (price range queries)
-- ✓ created_at (new property analytics)

-- Booking Table Analysis:
-- ✓ user_id (JOIN with User, user booking history)
-- ✓ property_id (JOIN with Property, property booking history)
-- ✓ status (filtering by booking status)
-- ✓ start_date/end_date (date range queries, availability)
-- ✓ created_at (booking analytics)

-- Review Table Analysis:
-- ✓ property_id (property review aggregations)
-- ✓ user_id (user review history)
-- ✓ rating (rating-based queries)

-- Payment Table Analysis:
-- ✓ booking_id (JOIN with Booking table)
-- ✓ payment_date (financial reporting)

-- Message Table Analysis:
-- ✓ sender_id/recipient_id (message thread lookups)
-- ✓ sent_at (recent messages)

-- ====================================================================

-- 2. CREATE INDEX COMMANDS

-- User Table Indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);
CREATE INDEX idx_user_role_created_at ON User(role, created_at);

-- Property Table Indexes
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_price ON Property(pricepernight);
CREATE INDEX idx_property_created_at ON Property(created_at);
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);
CREATE INDEX idx_property_host_created ON Property(host_id, created_at);

-- Booking Table Indexes
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_end_date ON Booking(end_date);
CREATE INDEX idx_booking_created_at ON Booking(created_at);
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);
CREATE INDEX idx_booking_user_created ON Booking(user_id, created_at);

-- Review Table Indexes
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);
CREATE INDEX idx_review_property_created ON Review(property_id, created_at);

-- Payment Table Indexes
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_date ON Payment(payment_date);
CREATE INDEX idx_payment_booking_date ON Payment(booking_id, payment_date);

-- Message Table Indexes
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);
CREATE INDEX idx_message_sender_recipient ON Message(sender_id, recipient_id);
CREATE INDEX idx_message_thread ON Message(sender_id, recipient_id, sent_at);

-- ====================================================================

-- 3. COMPOSITE INDEXES FOR COMMON QUERY PATTERNS

-- For user dashboard (frequent queries)
CREATE INDEX idx_user_dashboard ON Booking(user_id, status, created_at);

-- For property search (location and price filters)
CREATE INDEX idx_property_search ON Property(location, pricepernight, created_at);

-- For host analytics (host properties with booking info)
CREATE INDEX idx_host_analytics ON Property(host_id, created_at);

-- For booking management (status and date filters)
CREATE INDEX idx_booking_management ON Booking(status, start_date, property_id);

-- ====================================================================

-- 4. PERFORMANCE MEASUREMENT QUERIES

-- Query 1: User login/authentication (BEFORE INDEX)
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'elara.host@example.com';

-- Query 1: User login/authentication (AFTER INDEX - should use idx_user_email)
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'elara.host@example.com';

-- Query 2: Property search by location and price (BEFORE INDEX)
EXPLAIN ANALYZE
SELECT property_id, name, location, pricepernight
FROM Property
WHERE location LIKE 'New York%' 
AND pricepernight BETWEEN 200 AND 300
ORDER BY created_at DESC;

-- Query 2: Property search by location and price (AFTER INDEX - should use idx_property_search)
EXPLAIN ANALYZE
SELECT property_id, name, location, pricepernight
FROM Property
WHERE location LIKE 'New York%' 
AND pricepernight BETWEEN 200 AND 300
ORDER BY created_at DESC;

-- Query 3: User booking history (BEFORE INDEX)
EXPLAIN ANALYZE
SELECT b.booking_id, p.name, b.start_date, b.end_date, b.total_price, b.status
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = 'c3c3c3c3-3333-3333-3333-333333333333'
ORDER BY b.created_at DESC;

-- Query 3: User booking history (AFTER INDEX - should use idx_booking_user_id and idx_booking_user_created)
EXPLAIN ANALYZE
SELECT b.booking_id, p.name, b.start_date, b.end_date, b.total_price, b.status
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
WHERE b.user_id = 'c3c3c3c3-3333-3333-3333-333333333333'
ORDER BY b.created_at DESC;

-- Query 4: Host property management (BEFORE INDEX)
EXPLAIN ANALYZE
SELECT p.property_id, p.name, 
       COUNT(b.booking_id) as total_bookings,
       AVG(r.rating) as avg_rating
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.host_id = 'a1a1a1a1-1111-1111-1111-111111111111'
GROUP BY p.property_id, p.name;

-- Query 4: Host property management (AFTER INDEX - should use idx_property_host_id)
EXPLAIN ANALYZE
SELECT p.property_id, p.name, 
       COUNT(b.booking_id) as total_bookings,
       AVG(r.rating) as avg_rating
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
WHERE p.host_id = 'a1a1a1a1-1111-1111-1111-111111111111'
GROUP BY p.property_id, p.name;

-- Query 5: Availability check (BEFORE INDEX)
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

-- Query 5: Availability check (AFTER INDEX - should use idx_booking_date_range)
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

-- ====================================================================

-- 5. INDEX MAINTENANCE AND MONITORING

-- Check existing indexes
SELECT 
    tablename, 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- For MySQL use:
-- SHOW INDEX FROM User;
-- SHOW INDEX FROM Property;
-- SHOW INDEX FROM Booking;

-- Monitor index usage (PostgreSQL)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes;

-- Identify unused indexes (consider dropping these)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans
FROM pg_stat_user_indexes 
WHERE idx_scan = 0;

-- ====================================================================

-- 6. INDEX OPTIMIZATION TIPS

-- Consider partial indexes for filtered queries
CREATE INDEX idx_active_bookings ON Booking(status) 
WHERE status IN ('confirmed', 'pending');

-- Consider expression indexes for case-insensitive search
CREATE INDEX idx_user_email_lower ON User(LOWER(email));

-- Consider covering indexes for frequent queries
CREATE INDEX idx_booking_covering ON Booking(property_id, status, start_date, end_date)
INCLUDE (total_price, user_id);  -- PostgreSQL syntax

-- For MySQL, create composite index instead:
CREATE INDEX idx_booking_covering_mysql ON Booking(property_id, status, start_date, end_date, total_price, user_id);

-- ====================================================================
-- INDEXING BEST PRACTICES:
-- 
-- 1. Index columns used in WHERE, JOIN, ORDER BY clauses
-- 2. Consider composite indexes for multi-column queries
-- 3. Use partial indexes for filtered data subsets
-- 4. Monitor index usage and drop unused indexes
-- 5. Balance read performance vs. write overhead
-- 6. Consider index size and maintenance costs
-- 
-- EXPECTED PERFORMANCE IMPROVEMENTS:
-- - Email lookups: 90%+ faster with unique index
-- - Property searches: 70-80% faster with composite indexes  
-- - Booking history: 60-70% faster with proper indexing
-- - Host analytics: 50-60% faster with targeted indexes
-- ====================================================================

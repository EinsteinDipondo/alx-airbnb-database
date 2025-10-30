-- ====================================================================
-- SQL JOINS EXERCISE - AIRBNB DATABASE
-- Objective: Master SQL joins using different types of joins
-- ====================================================================

-- 1. INNER JOIN: Retrieve all bookings and the respective users who made those bookings
-- Returns only matching records from both tables (bookings that have users)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id;

-- Expected Results: 3 rows (all bookings from the seed data have associated users)

-- ====================================================================

-- 2. LEFT JOIN: Retrieve all properties and their reviews, including properties that have no reviews
-- Returns all properties, with review data where available (NULL for properties without reviews)
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    r.review_id,
    r.rating,
    r.comment,
    u.first_name AS reviewer_name
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN User u ON r.user_id = u.user_id
ORDER BY p.property_id, r.created_at;

-- Expected Results: 3 rows (all 3 properties, with Property 2 and 3 having NULL review data)

-- ====================================================================

-- 3. FULL OUTER JOIN: Retrieve all users and all bookings, even if user has no booking or booking has no user
-- Returns all records from both tables, with matches where they exist
-- Note: MySQL doesn't support FULL OUTER JOIN natively, so using UNION of LEFT and RIGHT JOINs

-- For MySQL:
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.role,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.role,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status
FROM User u
RIGHT JOIN Booking b ON u.user_id = b.user_id
ORDER BY user_id, start_date;


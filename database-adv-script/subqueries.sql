-- ====================================================================
-- SUBQUERIES EXERCISE - AIRBNB DATABASE
-- Objective: Master correlated and non-correlated subqueries
-- ====================================================================

-- 1. NON-CORRELATED SUBQUERY: Find properties where average rating > 4.0
-- This uses a subquery that can run independently of the main query

SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    (SELECT AVG(rating) FROM Review WHERE property_id = p.property_id) AS average_rating
FROM Property p
WHERE (
    SELECT AVG(rating) 
    FROM Review 
    WHERE property_id = p.property_id
) > 4.0;

-- Alternative syntax using HAVING with a subquery in SELECT
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    (SELECT AVG(rating) FROM Review WHERE property_id = p.property_id) AS average_rating
FROM Property p
HAVING average_rating > 4.0;

-- Another approach using subquery in WHERE clause
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight
FROM Property p
WHERE p.property_id IN (
    SELECT property_id 
    FROM Review 
    GROUP BY property_id 
    HAVING AVG(rating) > 4.0
);

-- ====================================================================

-- 2. CORRELATED SUBQUERY: Find users who have made more than 3 bookings
-- The subquery references the outer query (u.user_id) and executes for each row

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    (SELECT COUNT(*) FROM Booking WHERE user_id = u.user_id) AS booking_count
FROM User u
WHERE (
    SELECT COUNT(*) 
    FROM Booking 
    WHERE user_id = u.user_id
) > 3;

-- Alternative using EXISTS with correlated subquery (more efficient for large datasets)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    (SELECT COUNT(*) FROM Booking WHERE user_id = u.user_id) AS booking_count
FROM User u
WHERE EXISTS (
    SELECT 1 
    FROM Booking 
    WHERE user_id = u.user_id 
    GROUP BY user_id 
    HAVING COUNT(*) > 3
);

-- ====================================================================

-- BONUS EXAMPLES: Additional Subquery Patterns

-- 3. Find properties that have never been booked (using NOT EXISTS correlated subquery)
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location
FROM Property p
WHERE NOT EXISTS (
    SELECT 1 
    FROM Booking 
    WHERE property_id = p.property_id
);

-- 4. Find users who have reviewed properties they've booked (correlated subquery)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    r.rating,
    r.comment,
    p.name AS property_name
FROM User u
JOIN Review r ON u.user_id = r.user_id
JOIN Property p ON r.property_id = p.property_id
WHERE EXISTS (
    SELECT 1 
    FROM Booking 
    WHERE user_id = u.user_id 
    AND property_id = p.property_id
    AND status = 'confirmed'
);

-- 5. Find the most expensive booking for each user (correlated subquery for maximum)
SELECT 
    u.first_name,
    u.last_name,
    b.booking_id,
    b.total_price,
    b.start_date,
    b.end_date
FROM User u
JOIN Booking b ON u.user_id = b.user_id
WHERE b.total_price = (
    SELECT MAX(total_price) 
    FROM Booking 
    WHERE user_id = u.user_id
);

-- ====================================================================
-- SUBQUERY TYPE EXPLANATION:
-- 
-- NON-CORRELATED SUBQUERY:
-- - Can run independently of the outer query
-- - Executes once and returns a result set
-- - Used with IN, NOT IN, comparison operators
--
-- CORRELATED SUBQUERY:
-- - References columns from the outer query
-- - Executes once for each row processed by the outer query
-- - Used with EXISTS, NOT EXISTS, or in SELECT/WHERE clauses
-- - Generally slower but more flexible for complex conditions
-- ====================================================================

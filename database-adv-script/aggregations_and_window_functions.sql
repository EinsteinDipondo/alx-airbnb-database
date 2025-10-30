-- ====================================================================
-- AGGREGATION AND WINDOW FUNCTIONS EXERCISE - AIRBNB DATABASE
-- Objective: Master aggregation with GROUP BY and window functions
-- ====================================================================

-- 1. AGGREGATION WITH GROUP BY: Total number of bookings per user
-- Using COUNT function with GROUP BY clause

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.role,
    COUNT(b.booking_id) AS total_bookings,
    -- Additional aggregations for more insights
    SUM(b.total_price) AS total_spent,
    AVG(b.total_price) AS average_booking_value,
    MIN(b.start_date) AS first_booking_date,
    MAX(b.start_date) AS last_booking_date
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.role
ORDER BY total_bookings DESC;

-- Filter to show only users with at least 1 booking
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.role,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent
FROM User u
INNER JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.role
HAVING COUNT(b.booking_id) > 0
ORDER BY total_bookings DESC;

-- Breakdown by booking status
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(CASE WHEN b.status = 'confirmed' THEN 1 ELSE 0 END) AS confirmed_bookings,
    SUM(CASE WHEN b.status = 'pending' THEN 1 ELSE 0 END) AS pending_bookings,
    SUM(CASE WHEN b.status = 'canceled' THEN 1 ELSE 0 END) AS canceled_bookings,
    ROUND(SUM(CASE WHEN b.status = 'canceled' THEN 1 ELSE 0 END) * 100.0 / COUNT(b.booking_id), 2) AS cancellation_rate
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC;

-- ====================================================================

-- 2. WINDOW FUNCTIONS: Rank properties based on total bookings
-- Using ROW_NUMBER, RANK, and DENSE_RANK

-- Basic ranking by booking count
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    -- Different ranking functions demonstrate different behaviors
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_num_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank_position,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank_position
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY total_bookings DESC;

-- Advanced ranking with multiple window functions
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    -- Ranking by different criteria
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS bookings_rank,
    RANK() OVER (ORDER BY SUM(b.total_price) DESC) AS revenue_rank,
    -- Percentile calculations
    ROUND(PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) * 100, 2) AS booking_percentile,
    -- Cumulative distribution
    ROUND(CUME_DIST() OVER (ORDER BY COUNT(b.booking_id) DESC) * 100, 2) AS cumulative_distribution
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY total_bookings DESC;

-- Ranking within location categories
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS location_rank,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS overall_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY p.location, location_rank;

-- ====================================================================

-- 3. COMBINING AGGREGATION AND WINDOW FUNCTIONS

-- User booking analysis with running totals and rankings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.total_price,
    b.status,
    -- Window functions for cumulative analysis
    SUM(b.total_price) OVER (PARTITION BY u.user_id ORDER BY b.start_date) AS running_total,
    COUNT(b.booking_id) OVER (PARTITION BY u.user_id ORDER BY b.start_date) AS running_count,
    AVG(b.total_price) OVER (PARTITION BY u.user_id) AS user_avg_booking,
    -- Ranking user bookings by value
    RANK() OVER (PARTITION BY u.user_id ORDER BY b.total_price DESC) AS user_booking_rank
FROM User u
JOIN Booking b ON u.user_id = b.user_id
WHERE b.status = 'confirmed'
ORDER BY u.user_id, b.start_date;

-- Property performance with window functions for comparison
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    -- Comparison with average
    ROUND(AVG(COUNT(b.booking_id)) OVER (), 2) AS avg_bookings_all_properties,
    ROUND(AVG(SUM(b.total_price)) OVER (), 2) AS avg_revenue_all_properties,
    -- Performance indicators
    CASE 
        WHEN COUNT(b.booking_id) > AVG(COUNT(b.booking_id)) OVER () THEN 'Above Average'
        ELSE 'Below Average'
    END AS booking_performance,
    -- Revenue per booking compared to property price
    ROUND(SUM(b.total_price) / NULLIF(COUNT(b.booking_id), 0), 2) AS avg_revenue_per_booking
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY total_revenue DESC;

-- ====================================================================
-- FUNCTION EXPLANATION:
-- 
-- AGGREGATION FUNCTIONS:
-- COUNT() - Counts number of rows
-- SUM() - Sums values in a column
-- AVG() - Calculates average
-- MIN()/MAX() - Finds minimum/maximum values
--
-- WINDOW FUNCTIONS:
-- ROW_NUMBER() - Unique sequential numbers (no ties)
-- RANK() - Ranking with gaps for ties (1,2,2,4)
-- DENSE_RANK() - Ranking without gaps for ties (1,2,2,3)
-- PERCENT_RANK() - Relative rank as percentage (0-1)
-- CUME_DIST() - Cumulative distribution (0-1)
--
-- KEY DIFFERENCES:
-- GROUP BY collapses rows, Window Functions preserve rows
-- GROUP BY requires aggregation, Window Functions work with existing data
-- ====================================================================

-- 4. PRACTICAL BUSINESS INSIGHTS QUERIES

-- Top performing properties with detailed rankings
WITH PropertyPerformance AS (
    SELECT 
        p.property_id,
        p.name AS property_name,
        p.host_id,
        u.first_name AS host_name,
        p.location,
        p.pricepernight,
        COUNT(b.booking_id) AS total_bookings,
        SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) AS confirmed_revenue,
        RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS popularity_rank,
        RANK() OVER (ORDER BY SUM(CASE WHEN b.status = 'confirmed' THEN b.total_price ELSE 0 END) DESC) AS revenue_rank
    FROM Property p
    JOIN User u ON p.host_id = u.user_id
    LEFT JOIN Booking b ON p.property_id = b.property_id
    GROUP BY p.property_id, p.name, p.host_id, u.first_name, p.location, p.pricepernight
)
SELECT 
    property_name,
    host_name,
    location,
    pricepernight,
    total_bookings,
    confirmed_revenue,
    popularity_rank,
    revenue_rank,
    CASE 
        WHEN popularity_rank <= 2 THEN 'High Demand'
        WHEN popularity_rank <= 4 THEN 'Medium Demand'
        ELSE 'Low Demand'
    END AS demand_category
FROM PropertyPerformance
ORDER BY popularity_rank;

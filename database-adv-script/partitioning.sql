-- ====================================================================
-- TABLE PARTITIONING IMPLEMENTATION - BOOKING TABLE
-- Objective: Partition Booking table by start_date for performance optimization
-- ====================================================================

-- 1. CREATE PARTITIONED VERSION OF BOOKING TABLE
-- Using range partitioning by year on start_date column

CREATE TABLE Booking_Partitioned (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE RESTRICT,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE RESTRICT
) PARTITION BY RANGE (YEAR(start_date));

-- 2. CREATE PARTITIONS FOR DIFFERENT YEARS
-- Include past, current, and future years for comprehensive coverage

-- Historical data partition
CREATE TABLE booking_partition_2023 PARTITION OF Booking_Partitioned
FOR VALUES FROM (2023) TO (2024);

-- Current year partition
CREATE TABLE booking_partition_2024 PARTITION OF Booking_Partitioned
FOR VALUES FROM (2024) TO (2025);

-- Future year partitions
CREATE TABLE booking_partition_2025 PARTITION OF Booking_Partitioned
FOR VALUES FROM (2025) TO (2026);

CREATE TABLE booking_partition_2026 PARTITION OF Booking_Partitioned
FOR VALUES FROM (2026) TO (2027);

-- Catch-all partition for dates beyond 2026
CREATE TABLE booking_partition_future PARTITION OF Booking_Partitioned
FOR VALUES FROM (2027) TO (MAXVALUE);

-- 3. MIGRATE EXISTING DATA FROM ORIGINAL BOOKING TABLE
-- In production, this would be done with proper backup and validation

INSERT INTO Booking_Partitioned 
SELECT * FROM Booking;

-- 4. CREATE OPTIMIZED INDEXES ON PARTITIONED TABLE
-- Global indexes that work across all partitions

CREATE INDEX idx_booking_partitioned_start_date ON Booking_Partitioned(start_date);
CREATE INDEX idx_booking_partitioned_user_date ON Booking_Partitioned(user_id, start_date);
CREATE INDEX idx_booking_partitioned_property_date ON Booking_Partitioned(property_id, start_date);
CREATE INDEX idx_booking_partitioned_status_date ON Booking_Partitioned(status, start_date);
CREATE INDEX idx_booking_partitioned_date_range ON Booking_Partitioned(start_date, end_date);

-- 5. PERFORMANCE TESTING QUERIES

-- Test Query 1: Date range query for specific year
EXPLAIN ANALYZE
SELECT 
    booking_id, 
    start_date, 
    end_date, 
    total_price, 
    status
FROM Booking_Partitioned
WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31'
AND status = 'confirmed';

-- Test Query 2: Monthly booking analytics
EXPLAIN ANALYZE
SELECT 
    DATE_FORMAT(start_date, '%Y-%m') as month,
    COUNT(*) as booking_count,
    SUM(total_price) as total_revenue,
    AVG(total_price) as average_booking_value
FROM Booking_Partitioned
WHERE start_date BETWEEN '2024-01-01' AND '2025-12-31'
GROUP BY DATE_FORMAT(start_date, '%Y-%m')
ORDER BY month;

-- Test Query 3: User booking history with date filter
EXPLAIN ANALYZE
SELECT 
    booking_id,
    start_date,
    end_date,
    total_price,
    status
FROM Booking_Partitioned
WHERE user_id = 'c3c3c3c3-3333-3333-3333-333333333333'
AND start_date >= '2025-01-01'
ORDER BY start_date DESC
LIMIT 50;

-- Test Query 4: Property availability check
EXPLAIN ANALYZE
SELECT 
    property_id,
    COUNT(*) as booking_count
FROM Booking_Partitioned
WHERE start_date BETWEEN '2025-06-01' AND '2025-08-31'
AND status IN ('confirmed', 'pending')
GROUP BY property_id
ORDER BY booking_count DESC;

-- 6. PARTITION MAINTENANCE OPERATIONS

-- Check partition information and statistics
SELECT 
    partition_name,
    table_rows,
    data_length,
    index_length
FROM information_schema.partitions
WHERE table_name = 'Booking_Partitioned'
ORDER BY partition_ordinal_position;

-- Example: Add new partition for 2027
ALTER TABLE Booking_Partitioned 
ADD PARTITION (
    PARTITION booking_partition_2027 VALUES FROM (2027) TO (2028)
);

-- Example: Drop old partition (data archiving)
-- ALTER TABLE Booking_Partitioned 
-- DROP PARTITION booking_partition_2023;

-- 7. COMPARE WITH ORIGINAL TABLE (if testing with large dataset)
-- Note: These would show significant differences with large data volumes

-- Original table query
EXPLAIN ANALYZE
SELECT COUNT(*) 
FROM Booking 
WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31';

-- Partitioned table query
EXPLAIN ANALYZE
SELECT COUNT(*) 
FROM Booking_Partitioned 
WHERE start_date BETWEEN '2025-01-01' AND '2025-12-31';

-- 8. VERIFY PARTITION PRUNING IS WORKING
-- Check which partitions are accessed in query execution

EXPLAIN PARTITIONS
SELECT *
FROM Booking_Partitioned
WHERE start_date BETWEEN '2025-03-01' AND '2025-03-31';

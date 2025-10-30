-- ====================================================================
-- TABLE PARTITIONING OPTIMIZATION - AIRBNB DATABASE
-- Objective: Implement partitioning on Booking table for large datasets
-- ====================================================================

-- 1. CREATE PARTITIONED BOOKING TABLE
-- Assuming we're dealing with millions of booking records

-- First, create a new partitioned table structure
CREATE TABLE Booking_Partitioned (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (YEAR(start_date));

-- 2. CREATE PARTITIONS FOR DIFFERENT YEARS
-- Create partitions for historical and future data

CREATE TABLE booking_partition_2023 PARTITION OF Booking_Partitioned
FOR VALUES FROM (2023) TO (2024);

CREATE TABLE booking_partition_2024 PARTITION OF Booking_Partitioned
FOR VALUES FROM (2024) TO (2025);

CREATE TABLE booking_partition_2025 PARTITION OF Booking_Partitioned
FOR VALUES FROM (2025) TO (2026);

CREATE TABLE booking_partition_2026 PARTITION OF Booking_Partitioned
FOR VALUES FROM (2026) TO (2027);

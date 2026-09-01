-- ============================================================
-- Day 18: Partitioning & Bucketing
-- ============================================================

-- Q1. Create a partitioned table: trips_partitioned
--     Partition by RANGE on pickup_datetime, create 3 monthly partitions.
--     Load data. Verify row counts per partition.
-- YOUR QUERY:

-- Q2. Run EXPLAIN on:
--     a) WHERE pickup_datetime BETWEEN '2023-01-01' AND '2023-01-31'
--     b) WHERE DATE_TRUNC('month', pickup_datetime) = '2023-01-01'
--     Which uses partition pruning? Why?
-- YOUR QUERY:

-- Q3. Add an index on each partition for pickup_location_id.
--     Show that queries on (partition column + location_id) use both.
-- YOUR QUERY:

-- Q4. Write a script using generate_series to CREATE 12 monthly partitions
--     for the full year 2023. (Loop or CTE approach)
-- YOUR QUERY:

-- Q5. CHALLENGE: Design and implement a full partitioned table:
--     - Partition by month
--     - Index on (pickup_location_id, fare_amount)
--     - Partial index for credit card trips only (payment_type = 1)
--     - Show EXPLAIN ANALYZE for a query using all three features
-- YOUR QUERY:

-- ============================================================
-- Check solutions/week3/ for answers
-- ============================================================

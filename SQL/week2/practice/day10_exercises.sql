-- ============================================================
-- ============================================================
-- Day 10 Exercises: Indexes & Query Planning
-- ============================================================

-- Q1. Run EXPLAIN ANALYZE on this query BEFORE adding any index:
--     SELECT * FROM yellow_taxi_trips WHERE pickup_datetime > '2023-01-15';
--     Note the plan type (Seq Scan?) and actual execution time.
-- YOUR QUERY:

-- Q2. Create a B-tree index on pickup_datetime.
--     Re-run Q1's EXPLAIN ANALYZE. How did the plan and time change?
-- YOUR QUERY (CREATE INDEX + EXPLAIN ANALYZE):

-- Q3. Create a composite index on (pickup_location_id, pickup_datetime).
--     Test with: WHERE pickup_location_id = 161 AND pickup_datetime > '2023-01-10'
--     Does the query use the index?
-- YOUR QUERY:

-- Q4. Test the "index killer": Does EXTRACT() on an indexed column skip the index?
--     Compare:
--     a) WHERE EXTRACT(HOUR FROM pickup_datetime) = 8
--     b) WHERE pickup_datetime::TIME BETWEEN '08:00' AND '08:59:59'
--     Run EXPLAIN ANALYZE on both.
-- YOUR QUERY:

-- Q5. Check which indexes currently exist on yellow_taxi_trips.
-- YOUR QUERY:

-- Q6. Find all indexes on yellow_taxi_trips that have never been used (idx_scan = 0).
--     (Run a few queries first to simulate usage, then check pg_stat_user_indexes)
-- YOUR QUERY:

-- Q7. CHALLENGE: Design an index strategy for this common reporting query:
--     "Daily revenue per borough for credit card trips in January 2023"
--     Write the query, EXPLAIN ANALYZE it, create appropriate index(es),
--     then EXPLAIN ANALYZE again and compare.
-- YOUR QUERY:

-- ============================================================
-- Done! Check solutions/week2/ for answers
-- ============================================================

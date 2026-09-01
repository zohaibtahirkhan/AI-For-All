-- ============================================================
-- Day 20: Performance Optimization
-- ============================================================

-- Q1. Correlated subquery vs CTE+JOIN:
--     Write "zone avg fare per trip" using a correlated subquery.
--     Then rewrite using CTE+JOIN. EXPLAIN ANALYZE both. Compare times.
-- YOUR QUERY:

-- Q2. Filter-before-join optimization:
--     Find all trips in Manhattan zones.
--     Write two versions: a) JOIN then filter, b) Filter taxi_zones first then JOIN.
--     EXPLAIN ANALYZE both. Which is faster?
-- YOUR QUERY:

-- Q3. Index design exercise:
--     For this query: SELECT * FROM yellow_taxi_trips WHERE payment_type = 1 AND fare_amount > 50
--     a) Run EXPLAIN ANALYZE without an index
--     b) Create an appropriate index (consider composite vs partial)
--     c) Run EXPLAIN ANALYZE again
--     d) Document the improvement
-- YOUR QUERY:

-- Q4. EXISTS vs IN for large subqueries:
--     "Find trips from Manhattan zones" using:
--     a) WHERE pickup_location_id IN (SELECT ...)
--     b) WHERE EXISTS (SELECT 1 ...)
--     EXPLAIN ANALYZE both.
-- YOUR QUERY:

-- Q5. CHALLENGE: Take your Day 21 cohort/retention query and optimize it:
--     a) Add indexes based on EXPLAIN output
--     b) Rewrite any correlated subqueries as joins
--     c) Pre-aggregate data in a CTE to avoid repeated scans
--     d) Show before/after EXPLAIN ANALYZE with timing
-- YOUR QUERY:

-- ============================================================
-- Check solutions/week3/ for answers
-- ============================================================

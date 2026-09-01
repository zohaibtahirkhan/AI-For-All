-- ============================================================
-- Day 15: ETL/ELT Patterns
-- ============================================================

-- Q1. Build a 3-layer CTE pipeline: staging (raw), intermediate (cleaned+enriched), final (aggregated).
--     Output: daily borough revenue summary.
-- YOUR QUERY:

-- Q2. Add pipeline metadata columns to a staging SELECT:
--     _source (hardcoded 'yellow_taxi'), _loaded_at (NOW()), _pipeline_version ('1.0.0')
-- YOUR QUERY:

-- Q3. Implement idempotent refresh: DELETE for target_date + INSERT. Wrap in a transaction.
--     Test by running the same target_date twice — verify no duplicates.
-- YOUR QUERY:

-- Q4. Build a data validation step in the pipeline:
--     Count how many rows pass/fail each of these checks:
--     a) fare_amount > 0
--     b) trip_distance > 0
--     c) passenger_count > 0
--     d) dropoff_datetime > pickup_datetime
--     Show: check_name, pass_count, fail_count
-- YOUR QUERY:

-- Q5. CHALLENGE: Write a full ELT pipeline as a series of CTEs:
--     Stage 1 (raw): select from yellow_taxi_trips for a specific date
--     Stage 2 (validated): flag and exclude invalid rows, log failures
--     Stage 3 (enriched): add zone names
--     Stage 4 (aggregated): daily zone summary
--     Final: INSERT into target table with UPSERT (ON CONFLICT)
-- YOUR QUERY:

-- ============================================================
-- Check solutions/week3/ for answers
-- ============================================================

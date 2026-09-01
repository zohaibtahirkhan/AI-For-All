-- ============================================================
-- Day 19: Data Quality Checks
-- ============================================================

-- Q1. Null rate check: for each monetary column (fare_amount, tip_amount, total_amount,
--     congestion_surcharge), show: column_name, null_count, null_pct
-- YOUR QUERY:

-- Q2. Range validity: show count of trips violating each business rule:
--     a) fare_amount < 2.50 (minimum NYC fare)
--     b) fare_amount > 500 (likely data error)
--     c) trip_distance <= 0 with fare > 0 (impossible)
--     d) dropoff <= pickup (time travel!)
-- YOUR QUERY:

-- Q3. Create dq_results table and INSERT the results from Q2 in a structured format:
--     check_name, table_name, rows_checked, rows_failed, failure_rate, passed (bool)
-- YOUR QUERY:

-- Q4. Volume anomaly detection: find any day where trip_count is more than
--     2 standard deviations from the 7-day rolling mean. 
--     Show: date, trips, rolling_mean, z_score, anomaly_flag
-- YOUR QUERY:

-- Q5. CHALLENGE: Build a complete DQ monitoring pipeline:
--     - Run 6+ checks for a given date
--     - INSERT results into dq_results
--     - If any check has failure_rate > 5%, RAISE EXCEPTION with details
--     - Output a summary: total_checks, passed, failed
-- YOUR QUERY:

-- ============================================================
-- Check solutions/week3/ for answers
-- ============================================================

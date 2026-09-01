-- ============================================================
-- ============================================================
-- Day 14 Exercises: Stored Procedures & Functions
-- ============================================================

-- Q1. Create a function classify_trip_distance(distance NUMERIC) RETURNS TEXT
--     that returns: 'Very Short' (<1mi), 'Short' (1-3mi), 
--     'Medium' (3-10mi), 'Long' (>10mi)
--     Then use it in a GROUP BY query.
-- YOUR QUERY:

-- Q2. Create a function zone_revenue(zone_id INTEGER, start_date DATE, end_date DATE)
--     RETURNS NUMERIC that returns total revenue for that zone in the date range.
-- YOUR QUERY:

-- Q3. Create a table-returning function get_top_zones(n INTEGER, by_column TEXT)
--     that returns the top N zones by either 'revenue' or 'trips'.
--     (Use dynamic SQL with EXECUTE ... USING for the column name)
-- YOUR QUERY:

-- Q4. Create a stored procedure load_daily_summary(p_date DATE) that:
--     a) Deletes existing data for that date from daily_zone_summary
--     b) Inserts fresh aggregation
--     c) Logs the row count to a processing_log table
--     d) Commits
-- YOUR QUERY:

-- Q5. CHALLENGE: Create a data quality procedure that scans yellow_taxi_trips
--     for a given date and inserts quality check results into a dq_results table:
--     (check_name, check_date, rows_checked, rows_failed, pass_flag)
--     Run checks for: null fares, negative distances, impossible durations.
-- YOUR QUERY:

-- ============================================================
-- Done! Check solutions/week2/ for answers
-- ============================================================

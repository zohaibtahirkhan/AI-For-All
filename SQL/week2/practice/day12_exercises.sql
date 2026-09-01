-- ============================================================
-- ============================================================
-- Day 12 Exercises: Transactions & ACID
-- ============================================================

-- Q1. Write a transaction that:
--     a) Creates a table: daily_totals(trip_date DATE, trips INT, revenue NUMERIC)
--     b) Inserts the aggregated daily data for your dataset
--     c) Commits
--     Make it idempotent (use CREATE TABLE IF NOT EXISTS + TRUNCATE or UPSERT).
-- YOUR QUERY:

-- Q2. Demonstrate ROLLBACK: Start a transaction, insert a fake row into
--     yellow_taxi_trips, verify it exists within the transaction,
--     then ROLLBACK and verify it's gone.
-- YOUR QUERY:

-- Q3. Implement UPSERT for a zone_daily_summary table.
--     Run the same UPSERT twice for the same date — verify the row isn't duplicated.
-- YOUR QUERY:

-- Q4. Write an idempotent "refresh" procedure using DELETE + INSERT in a transaction.
--     Call it twice for the same date and verify results are consistent.
-- YOUR QUERY:

-- Q5. CHALLENGE: Write a procedure that processes an entire month's data:
--     For each day in the month, DELETE + INSERT into daily_zone_summary.
--     Use a LOOP with COMMIT after each day (so failure mid-month
--     doesn't roll back all previous days).
-- YOUR QUERY:

-- ============================================================
-- Done! Check solutions/week2/ for answers
-- ============================================================

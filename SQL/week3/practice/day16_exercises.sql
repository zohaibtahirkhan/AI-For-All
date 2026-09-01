-- ============================================================
-- Day 16: Incremental Loading
-- ============================================================

-- Q1. Create a pipeline_watermarks table. Write a transaction that:
--     a) Reads the last processed timestamp
--     b) Selects only new records from yellow_taxi_trips
--     c) Updates the watermark
--     (Simulate with a BEGIN; SELECT; INSERT; UPDATE; COMMIT block)
-- YOUR QUERY:

-- Q2. Create two "snapshot" tables: morning_snapshot and evening_snapshot.
--     Populate morning with 100 trips; evening with 95 of those + 10 new ones + 3 changed.
--     Write CDC queries to find: INSERTs, DELETEs, UPDATEs.
-- YOUR QUERY:

-- Q3. Handle late-arriving data: write a DELETE + INSERT transaction that reprocesses
--     the last 3 days. Make it idempotent.
-- YOUR QUERY:

-- Q4. CHALLENGE: Implement a full incremental pipeline:
--     - Create a watermarks table
--     - Process only dates not yet in fct_daily_zone_revenue
--     - Use UPSERT for re-run safety
--     - Log: rows_inserted, rows_updated, watermark_updated_to
-- YOUR QUERY:

-- ============================================================
-- Check solutions/week3/ for answers
-- ============================================================

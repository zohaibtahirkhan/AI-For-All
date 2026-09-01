-- ============================================================
-- day30_interview_questions.sql
-- ============================================================

-- ============================================================
-- Day 30: Interview Practice Questions
-- Write solutions from scratch — no looking at previous exercises!
-- These mirror real DE interview questions.
-- ============================================================

-- SECTION A: Window Functions (common in every DE interview)

-- A1. [Classic] Rank trips by fare_amount within each payment_type.
--     Show only trips that are in the top 10% of their payment group (NTILE).
-- YOUR QUERY:

-- A2. [Time-series] Calculate 7-day rolling average of daily revenue.
--     Flag days where actual revenue is >20% above the rolling average.
-- YOUR QUERY:

-- A3. [Top-N] For each hour of the day, show the top 3 pickup zones by trip count.
-- YOUR QUERY:


-- SECTION B: Data Engineering Patterns

-- B1. [Idempotent] Write an idempotent procedure to refresh fct_daily_zone_revenue
--     for a given date. Run it 3 times and verify the result is the same each time.
-- YOUR QUERY:

-- B2. [SCD2] Zone 161's service_zone changes from 'Yellow Zone' to 'Boro Zone'.
--     Apply the SCD Type 2 update and query the zone history.
-- YOUR QUERY:

-- B3. [Incremental] Design a watermark-based incremental load.
--     Show the watermark update + incremental SELECT + UPSERT all in one transaction.
-- YOUR QUERY:


-- SECTION C: Analytical Queries

-- C1. [Gaps and Islands] Find consecutive days where total trips > 100,000.
--     Show streak_start, streak_end, length_in_days.
-- YOUR QUERY:

-- C2. [Cohort] Group zones by the month they first had trips.
--     For each cohort, show % of zones still active 1, 2, 3 months later.
-- YOUR QUERY:

-- C3. [Funnel] Build a conversion funnel:
--     Started trip → Completed trip → Paid with credit card → Left a tip > 15%
--     Show count and % at each stage.
-- YOUR QUERY:


-- SECTION D: Performance & Quality

-- D1. [EXPLAIN] Write a complex query, run EXPLAIN ANALYZE, identify the bottleneck,
--     add an index, and show the improved plan.
-- YOUR QUERY:

-- D2. [Data Quality] Write a single query that checks 5 different quality rules
--     and returns a pass/fail report. One row per check.
-- YOUR QUERY:

-- D3. [Edge Cases] Write a query that correctly handles:
--     - NULL tip_amount (treat as 0)
--     - Zero fare_amount (skip in tip % calculation)
--     - Trips where dropoff < pickup (mark as invalid)
--     Show the count at each filter stage.
-- YOUR QUERY:

-- ============================================================
-- 🎉 You've completed the 30-Day SQL for AI and Data Engineers Roadmap!
-- ============================================================

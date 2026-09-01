-- ============================================================
-- ============================================================
-- Day 13 Exercises: Views & Materialized Views
-- ============================================================

-- Q1. Create a view vw_enriched_trips that joins yellow_taxi_trips
--     to taxi_zones (pickup AND dropoff) and payment_types.
--     Include all trip columns plus the human-readable names.
-- YOUR QUERY:

-- Q2. Query your view to find avg fare by pickup_borough and payment description.
-- YOUR QUERY:

-- Q3. Create a materialized view mv_hourly_stats:
--     hour_of_day, trips, avg_fare, avg_distance, total_revenue
--     Then query it to find the top 5 hours by revenue.
-- YOUR QUERY:

-- Q4. REFRESH the materialized view and time how long it takes
--     (Use \timing in psql or wrap in EXPLAIN ANALYZE).
-- YOUR QUERY:

-- Q5. Create a UNIQUE index on the materialized view to enable CONCURRENT refresh.
--     Then run: REFRESH MATERIALIZED VIEW CONCURRENTLY mv_hourly_stats;
-- YOUR QUERY:

-- Q6. CHALLENGE: Create a materialized view that is a "zone performance dashboard":
--     zone, borough, trips, revenue, avg_fare, avg_tip_pct, rank_by_revenue
--     (Include the rank using a window function in the MV definition)
--     Then create appropriate indexes and query it.
-- YOUR QUERY:

-- ============================================================
-- Done! Check solutions/week2/ for answers
-- ============================================================

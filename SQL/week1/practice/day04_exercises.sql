-- ============================================================
-- Day 4 Exercises: Subqueries & CTEs
-- ============================================================

-- Q1. Using a subquery in WHERE, find all trips with fare_amount 
--     above the overall average fare. How many are there?
-- YOUR QUERY:

-- Q2. Using IN with a subquery, find all trips that picked up in Queens.
--     (Get Queens location_ids from taxi_zones, then filter trips)
-- YOUR QUERY:

-- Q3. Find trips where pickup_location_id has NO match in taxi_zones.
--     Use NOT EXISTS. Compare your count to the LEFT JOIN approach from Day 3.
-- YOUR QUERY:

-- Q4. Using a derived table (subquery in FROM), get the top 5 hours of
--     the day by trip count, then show only those hours where avg fare > $15.
-- YOUR QUERY:

-- Q5. Write a 3-stage CTE pipeline:
--     Stage 1 (clean): Remove trips with fare <= 0 or distance <= 0
--     Stage 2 (enrich): Add pickup_zone and dropoff_zone from taxi_zones
--     Stage 3 (summarize): Avg fare and trip count per pickup_zone
--     Final: Show top 15 zones by trip count.
-- YOUR QUERY:

-- Q6. Using a CTE, calculate for each payment type:
--     - trip_count
--     - avg_fare
--     - pct_of_total_trips (this trip type's count / total trips * 100)
--     The pct_of_total requires knowing the total — use a CTE for that.
-- YOUR QUERY:

-- Q7. Using a recursive CTE, generate a series of dates for all of January 2023.
--     Then LEFT JOIN to actual daily trip counts to show days with 0 trips (if any).
-- YOUR QUERY:

-- Q8. CHALLENGE: Multi-CTE pipeline for a zone performance report:
--     CTE 1: Clean data (remove outliers)
--     CTE 2: Zone-level stats (trips, revenue, avg fare, avg tip %)
--     CTE 3: Rank zones by revenue
--     CTE 4: Classify as 'Top 10%', 'Mid', 'Bottom 10%' using NTILE or CASE
--     Final: Show zone name, borough, rank, classification, revenue
-- YOUR QUERY:

-- ============================================================

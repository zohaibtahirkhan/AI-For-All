-- ============================================================
-- Day 2 Exercises: Aggregations & GROUP BY
-- Dataset: NYC Yellow Taxi Trips
-- ============================================================


-- ------------------------------------------------------------
-- BASIC AGGREGATIONS
-- ------------------------------------------------------------

-- Q1. What is the total number of trips, total revenue (sum of total_amount),
--     and average fare_amount in the entire dataset?
-- YOUR QUERY:



-- Q2. What is the median fare_amount (use PERCENTILE_CONT)?
--     Also compute the mean. Are they different? Why?
-- YOUR QUERY:



-- Q3. What percentage of trips have a NULL passenger_count?
--     Show: total_rows, null_count, null_pct (as a %)
-- YOUR QUERY:



-- ------------------------------------------------------------
-- GROUP BY ANALYSIS
-- ------------------------------------------------------------

-- Q4. Break down trips and total revenue by payment_type.
--     Order by trip_count descending.
--     (Join to payment_types table to show the description too)
-- YOUR QUERY:



-- Q5. How many trips did each vendor (vendor_id) make?
--     What was their average fare? Which vendor had higher avg fares?
-- YOUR QUERY:



-- Q6. Show the number of trips per hour of day (0–23).
--     Which hour has the most trips? Fewest?
--     Order by hour_of_day ascending.
-- YOUR QUERY:



-- Q7. Show daily trip counts and total revenue for the entire month
--     (one row per day). Order by date.
-- YOUR QUERY:



-- Q8. Show trips and avg fare by pickup borough.
--     (Join yellow_taxi_trips to taxi_zones on pickup_location_id = location_id)
--     Order by trips descending.
-- YOUR QUERY:



-- ------------------------------------------------------------
-- HAVING CLAUSE
-- ------------------------------------------------------------

-- Q9. Find all pickup zones (pickup_location_id) with MORE than 5,000 trips.
--     Show the zone name (join to taxi_zones), trip count, and avg fare.
--     Order by trip_count descending.
-- YOUR QUERY:



-- Q10. Find hours of the day where the average fare is above $20
--      AND there were at least 1,000 trips. 
--      Order by avg_fare descending.
-- YOUR QUERY:



-- ------------------------------------------------------------
-- CONDITIONAL AGGREGATION (Pivot style)
-- ------------------------------------------------------------

-- Q11. In a single query row, show counts of trips for each payment type:
--      credit_card_trips, cash_trips, no_charge_trips, dispute_trips
--      (Use FILTER or CASE WHEN)
-- YOUR QUERY:



-- Q12. For each day of the week (Monday=1 through Sunday=7),
--      show: total trips, avg fare, total tips, and tip_rate (tip/fare %)
--      among credit card payments only.
--      Hint: use EXTRACT(DOW FROM pickup_datetime) — 0=Sunday in PostgreSQL
-- YOUR QUERY:



-- ------------------------------------------------------------
-- DATA QUALITY CHECKS (Very DE-specific!)
-- ------------------------------------------------------------

-- Q13. For each column in this list, show the count of NULL values:
--      vendor_id, passenger_count, trip_distance, 
--      pickup_location_id, dropoff_location_id,
--      fare_amount, tip_amount, total_amount
--      Present results as one row per column (use UNION ALL).
-- YOUR QUERY:



-- Q14. Find any trips where:
--      - total_amount < fare_amount  (impossible: total should always >= fare)
--      - OR fare_amount < 0
--      - OR trip_distance < 0
--      Count them and show a few examples.
-- YOUR QUERY:



-- ------------------------------------------------------------
-- CHALLENGE
-- ------------------------------------------------------------

-- Q15. Create a "time of day" breakdown:
--      - Night: 10 PM to 5 AM
--      - Morning Rush: 5 AM to 10 AM  
--      - Midday: 10 AM to 4 PM
--      - Evening Rush: 4 PM to 10 PM
--      For each period, show: trip_count, avg_fare, avg_tip, avg_distance
--      (Hint: Use CASE WHEN with EXTRACT(HOUR FROM pickup_datetime))
-- YOUR QUERY:



-- Q16. Show month-over-month revenue change.
--      For each month (if you have multiple months of data), show:
--      month, total_revenue, previous_month_revenue, revenue_change_pct
--      (Hint: Use LAG window function — preview of Day 8!)
--      If single month: show daily revenue with day-over-day change instead.
-- YOUR QUERY:



-- ============================================================
-- Done! Check solutions/week1/day02_solutions.sql
-- ============================================================

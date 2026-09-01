-- ============================================================
-- Day 3 Exercises: JOINs
-- Dataset: NYC Yellow Taxi Trips + Lookup Tables
-- ============================================================


-- ------------------------------------------------------------
-- INNER JOIN
-- ------------------------------------------------------------

-- Q1. Show each trip's pickup zone and borough name (join to taxi_zones).
--     Display: pickup_datetime, fare_amount, pickup_zone, pickup_borough
--     Limit to 20 rows.
-- YOUR QUERY:



-- Q2. Show trips where both pickup AND dropoff occurred in Manhattan.
--     (Two joins to taxi_zones — one for pickup, one for dropoff)
--     Count how many such trips exist.
-- YOUR QUERY:



-- Q3. Revenue by pickup borough: 
--     borough, trip_count, total_revenue, avg_fare
--     Ordered by total_revenue descending.
-- YOUR QUERY:



-- Q4. Find the top 10 most popular pickup zone → dropoff zone routes.
--     Show: pickup_zone, dropoff_zone, trip_count, avg_fare
--     (Requires two joins to taxi_zones)
-- YOUR QUERY:



-- ------------------------------------------------------------
-- LEFT JOIN
-- ------------------------------------------------------------

-- Q5. Are there any trips where pickup_location_id does NOT exist 
--     in the taxi_zones table? Find them using LEFT JOIN.
--     How many trips have unrecognized pickup locations?
-- YOUR QUERY:



-- Q6. For every zone in taxi_zones, show how many times it was a 
--     PICKUP location. Include zones with 0 pickups too.
--     Show: zone, borough, pickup_count
--     Order by pickup_count descending.
-- YOUR QUERY:



-- Q7. Show all trips with their payment description (join to payment_types).
--     Include trips even if payment_type doesn't match the lookup table.
--     Replace unmatched payment types with 'Unknown'.
--     (Use COALESCE or CASE on the joined column)
-- YOUR QUERY:



-- ------------------------------------------------------------
-- FULL OUTER JOIN & CROSS JOIN
-- ------------------------------------------------------------

-- Q8. Using CROSS JOIN, generate a "report scaffold" showing 
--     every combination of borough × payment_type_description.
--     This is useful for reports that need to show 0s, not just 
--     rows that exist. Show all combinations ordered by borough, payment type.
-- YOUR QUERY:



-- Q9. Using the scaffold from Q8, LEFT JOIN the actual trip counts per
--     borough × payment_type. Rows with no trips should show 0, not NULL.
--     (Combine CROSS JOIN scaffold with a LEFT JOIN to the actual data)
-- YOUR QUERY:



-- ------------------------------------------------------------
-- SELF JOIN
-- ------------------------------------------------------------

-- Q10. Find all pairs of taxi zones in the same borough.
--      Show: zone_a, zone_b, borough
--      Avoid showing (A,B) AND (B,A) — use location_id < location_id.
--      Limit to 30 rows.
-- YOUR QUERY:



-- ------------------------------------------------------------
-- MULTI-TABLE JOINS (realistic pipeline scenario)
-- ------------------------------------------------------------

-- Q11. Create a "trip report" joining to ALL lookup tables:
--      pickup zone, dropoff zone, payment type description, vendor name.
--      Show 10 sample trips with all human-readable columns.
-- YOUR QUERY:



-- Q12. Revenue report by pickup_borough and payment_type_description.
--      Show all combinations (even those with 0 trips using scaffold approach).
--      Columns: borough, payment_type, trip_count, total_revenue
--      Order by borough, payment_type.
-- YOUR QUERY:



-- ------------------------------------------------------------
-- DATA QUALITY (JOIN-based checks)
-- ------------------------------------------------------------

-- Q13. Find all pickup_location_id values in yellow_taxi_trips 
--      that are NOT in the taxi_zones table.
--      (Hint: LEFT JOIN where right side IS NULL, or use NOT IN / NOT EXISTS)
--      How many distinct invalid IDs exist? How many trips use them?
-- YOUR QUERY:



-- Q14. Check for join fanout: does taxi_zones have any duplicate location_id values?
--      Write a query to confirm the taxi_zones table has no duplicate location_ids.
--      (This is a join safety check you should run before any JOIN pipeline)
-- YOUR QUERY:



-- ------------------------------------------------------------
-- CHALLENGE
-- ------------------------------------------------------------

-- Q15. Airport trips analysis:
--      - JFK (rate_code_id = 2) and Newark (rate_code_id = 3) are airport routes
--      - For these airport trips, show:
--        airport_name, trip_count, avg_fare, avg_tip, avg_tip_pct (tip/fare)
--      - Also show what PICKUP borough most airport trips originate from
-- YOUR QUERY:



-- Q16. "Fare efficiency" by zone pair:
--      For the top 20 busiest pickup→dropoff zone combinations,
--      calculate: avg fare per mile (fare_amount / trip_distance)
--      Only include trips where trip_distance > 0.
--      Show: pickup_zone, dropoff_zone, trips, avg_fare_per_mile
--      Order by avg_fare_per_mile descending.
-- YOUR QUERY:



-- ============================================================
-- Done! Check solutions/week1/day03_solutions.sql
-- ============================================================

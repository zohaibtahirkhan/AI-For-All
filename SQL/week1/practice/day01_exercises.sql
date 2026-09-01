-- ============================================================
-- Day 1 Exercises: SELECT, WHERE, ORDER BY
-- Dataset: NYC Yellow Taxi Trips
-- ============================================================
-- Instructions:
--   1. Write your SQL below each question
--   2. Run it against the nyc_taxi database
--   3. Check solutions/ only after attempting all questions
-- ============================================================


-- ------------------------------------------------------------
-- WARM-UP (Basic SELECT)
-- ------------------------------------------------------------

-- Q1. Select the first 20 rows from yellow_taxi_trips.
--     Show only: pickup_datetime, dropoff_datetime, fare_amount, tip_amount, total_amount
-- YOUR QUERY:



-- Q2. How many total rows are in yellow_taxi_trips?
--     (Hint: use COUNT(*))
-- YOUR QUERY:



-- Q3. Show all unique values of payment_type in the dataset.
-- YOUR QUERY:



-- ------------------------------------------------------------
-- FILTERING WITH WHERE
-- ------------------------------------------------------------

-- Q4. Find all trips where the fare_amount was greater than $100.
--     Show: pickup_datetime, fare_amount, tip_amount, total_amount
--     Order by fare_amount descending.
-- YOUR QUERY:



-- Q5. Find all trips that were paid in cash (payment_type = 2)
--     AND had a trip_distance longer than 10 miles.
--     How many such trips exist?
-- YOUR QUERY:



-- Q6. Find trips where passenger_count is between 3 and 6 (inclusive).
--     Order by passenger_count, then by fare_amount descending.
--     Show top 50 rows.
-- YOUR QUERY:



-- Q7. Find all trips that were NOT standard rate (rate_code_id = 1).
--     Show all columns. How many such trips are there?
-- YOUR QUERY:



-- Q8. Find trips where the tip_amount is NULL.
--     (In a real pipeline, you'd need to handle these carefully!)
--     How many rows have a NULL tip_amount?
-- YOUR QUERY:



-- ------------------------------------------------------------
-- STRING AND DATE FILTERS
-- ------------------------------------------------------------

-- Q9. In the taxi_zones table, find all zones in the 'Manhattan' borough.
--     Order alphabetically by zone name.
-- YOUR QUERY:



-- Q10. In taxi_zones, find all zones whose name contains the word 'Park'.
--      (Case-insensitive if possible — use ILIKE in PostgreSQL)
-- YOUR QUERY:



-- Q11. Find all trips that occurred on January 15, 2023.
--      (Filter: pickup_datetime falls on that date)
--      How many trips happened that day?
-- YOUR QUERY:



-- Q12. Find all trips during the morning rush hour:
--      pickup_datetime between 7:00 AM and 9:00 AM across all days.
--      (Hint: use EXTRACT(HOUR FROM pickup_datetime) or 
--             pickup_datetime::time BETWEEN '07:00' AND '09:00')
-- YOUR QUERY:



-- ------------------------------------------------------------
-- CALCULATIONS AND EXPRESSIONS
-- ------------------------------------------------------------

-- Q13. Show a "tip percentage" for credit card trips:
--      tip_amount / fare_amount * 100 AS tip_pct
--      Filter: payment_type = 1 (credit card) AND fare_amount > 0
--      Order by tip_pct descending.
--      Show top 20 rows (look for outliers!).
-- YOUR QUERY:



-- Q14. Calculate trip_duration_minutes as the difference between
--      dropoff_datetime and pickup_datetime for each trip.
--      Filter for trips under 60 minutes.
--      (Hint: EXTRACT(EPOCH FROM (dropoff_datetime - pickup_datetime)) / 60)
--      Show: trip_id, pickup_datetime, trip_duration_minutes, fare_amount
--      Order by trip_duration_minutes descending. Top 10.
-- YOUR QUERY:



-- ------------------------------------------------------------
-- CHALLENGE QUESTIONS
-- ------------------------------------------------------------

-- Q15. Find trips that look suspicious:
--      - fare_amount = 0 OR fare_amount < 0
--      - OR total_amount < fare_amount  (total less than base fare? impossible)
--      - OR trip_distance = 0 AND total_amount > 0
--      How many such records exist? This is a data quality check!
-- YOUR QUERY:



-- Q16. Find the top 5 most expensive trips (by total_amount) 
--      that were NOT airport rides (rate_code_id NOT IN (2, 3))
--      and had exactly 1 passenger.
--      Show: pickup_datetime, dropoff_datetime, trip_distance, 
--            passenger_count, rate_code_id, total_amount
-- YOUR QUERY:



-- Q17. (THINK ABOUT IT) Why does this query fail? Fix it.
--      SELECT 
--          fare_amount + tip_amount AS revenue,
--          vendor_id
--      FROM yellow_taxi_trips
--      WHERE revenue > 50
--      ORDER BY revenue DESC;
-- YOUR FIXED QUERY:



-- ============================================================
-- Done! Check solutions/week1/day01_solutions.sql
-- ============================================================

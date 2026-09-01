-- ============================================================
-- ============================================================
-- Day 11 Exercises: Data Types & Casting
-- ============================================================

-- Q1. Show pickup_datetime as: DATE only, TIME only, Unix timestamp (epoch seconds).
-- YOUR QUERY:

-- Q2. Simulate a type mismatch: what happens when you compare
--     pickup_location_id (INTEGER) to '161' (TEXT)?
--     Then try '161.5' — does it error or cast automatically?
-- YOUR QUERY:

-- Q3. Demonstrate FLOAT vs NUMERIC precision:
--     SELECT 0.1::FLOAT + 0.2::FLOAT, 0.1::NUMERIC + 0.2::NUMERIC;
--     Then sum 10 rows of 0.1 using both types.
-- YOUR QUERY:

-- Q4. Create a safe_cast_numeric function and test it on:
--     '25.50', '0', 'bad_data', NULL, '1e5'
-- YOUR QUERY:

-- Q5. The raw data sometimes has fare_amount stored as text (simulated).
--     Write a query to safely convert: CASE WHEN safe_cast works THEN cast ELSE NULL.
-- YOUR QUERY:

-- Q6. Show NYC taxi pickup_datetime in both UTC and 'America/New_York' timezone.
--     What is the offset? Does it change between January and July?
-- YOUR QUERY:

-- Q7. CHALLENGE: Write a data type audit query that checks each monetary column
--     (fare_amount, tip_amount, total_amount) for:
--     - Values that would overflow NUMERIC(8,2)
--     - Values that aren't multiples of $0.01 (penny-level precision)
--     - Negative values
-- YOUR QUERY:

-- ============================================================
-- Done! Check solutions/week2/ for answers
-- ============================================================

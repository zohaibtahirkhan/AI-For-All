-- ============================================================
-- ============================================================
-- Day 8 Exercises: Window Functions Basics
-- ============================================================

-- Q1. Rank all trips by fare_amount within each pickup borough.
--     Show: borough, trip_id, fare_amount, rank_in_borough
--     (Use ROW_NUMBER and RANK — compare the difference when ties exist)
-- YOUR QUERY:

-- Q2. For each pickup zone, show:
--     zone, trips, avg_fare, and the zone's rank by trip_count (DENSE_RANK)
-- YOUR QUERY:

-- Q3. Classify trips into fare quartiles using NTILE(4).
--     Show the count and avg tip_pct for each quartile.
-- YOUR QUERY:

-- Q4. Using LAG, compute day-over-day trip count change.
--     Show: date, trips, prev_day_trips, daily_change, pct_change
-- YOUR QUERY:

-- Q5. Using LEAD, for each trip find the NEXT trip's pickup_datetime
--     in the same pickup zone. Calculate the gap in minutes.
--     Show top 20 rows with the longest gaps.
-- YOUR QUERY:

-- Q6. For each trip, show: fare_amount, zone avg fare, and how many 
--     standard deviations away the trip is from the zone average.
--     (fare - avg) / stddev = z-score. Flag trips with z-score > 3 as outliers.
-- YOUR QUERY:

-- Q7. Top-N per group: Find the single most expensive trip (by total_amount)
--     for each day of the week (Monday–Sunday). Show all 7 rows.
-- YOUR QUERY:

-- Q8. CHALLENGE: Revenue contribution — for each zone, show what percentage
--     of the BOROUGH's total revenue that zone contributes.
--     Hint: SUM(revenue) OVER (PARTITION BY borough) as denominator.
-- YOUR QUERY:

-- ============================================================
-- Done! Check solutions/week2/ for answers
-- ============================================================

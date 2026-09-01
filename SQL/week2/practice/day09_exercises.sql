-- ============================================================
-- ============================================================
-- Day 9 Exercises: Window Functions Advanced
-- ============================================================

-- Q1. Compute a running total of trips and revenue by day.
--     Show: date, daily_trips, daily_revenue, cumulative_trips, cumulative_revenue
-- YOUR QUERY:

-- Q2. Compute a 7-day moving average of daily trip counts.
--     Show: date, trips, ma_7day
--     For the first 6 days, the MA will be based on fewer rows — that's OK.
-- YOUR QUERY:

-- Q3. Find days where trip count was more than 1.5x the 7-day moving average.
--     These are "surge" days. What do they have in common (day of week, events)?
-- YOUR QUERY:

-- Q4. For each trip, use FIRST_VALUE and LAST_VALUE to show:
--     - The most expensive trip in the same zone (that day)
--     - The cheapest trip in the same zone (that day)
--     - Where the current trip falls (min, mid, max)
-- YOUR QUERY:

-- Q5. Compute cumulative revenue as a percentage of total monthly revenue.
--     Show at what point in the month 50% of revenue was reached.
-- YOUR QUERY:

-- Q6. Using PERCENTILE_CONT, compute the 25th, 50th, 75th, 95th, and 99th
--     percentile of fare_amount per borough.
-- YOUR QUERY:

-- Q7. CHALLENGE: Detect anomalous days — days where revenue is more than
--     2 standard deviations from the 30-day rolling mean.
--     Use window functions for both the rolling mean and rolling stddev.
-- YOUR QUERY:

-- ============================================================
-- Done! Check solutions/week2/ for answers
-- ============================================================

# Day 8 — Window Functions Basics

## 🎯 Learning Goals
Use window functions to compute rankings, running totals, and comparisons without collapsing rows. This is the single most powerful SQL feature for AI and Data Engineers.

---

## 1. What Are Window Functions?

Unlike GROUP BY which collapses rows, window functions compute a value *across a set of rows related to the current row* while keeping all rows intact.

```
Regular GROUP BY:    5 rows → 1 summary row
Window Function:     5 rows → 5 rows (each with an added computed value)
```

### Syntax
```sql
function_name() OVER (
    [PARTITION BY column1, column2]   -- Like GROUP BY within the window
    [ORDER BY column3]                -- Ordering within partition
    [ROWS/RANGE frame_specification]  -- Window frame (Day 9)
)
```

---

## 2. Ranking Functions

### ROW_NUMBER — Unique sequential number
```sql
-- Rank trips by fare within each pickup zone
SELECT
    trip_id,
    pickup_location_id,
    fare_amount,
    ROW_NUMBER() OVER (
        PARTITION BY pickup_location_id
        ORDER BY fare_amount DESC
    ) AS rank_in_zone
FROM yellow_taxi_trips
WHERE fare_amount > 0;
```

### RANK — Ties get same rank, gaps after ties
```sql
-- Rank zones by revenue (ties get same rank, next rank skips)
SELECT
    pickup_location_id,
    SUM(total_amount) AS revenue,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM yellow_taxi_trips
GROUP BY pickup_location_id;
```

### DENSE_RANK — Ties get same rank, no gaps
```sql
SELECT
    pickup_location_id,
    SUM(total_amount) AS revenue,
    DENSE_RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM yellow_taxi_trips
GROUP BY pickup_location_id;
-- RANK:       1, 2, 2, 4   (gap after tie)
-- DENSE_RANK: 1, 2, 2, 3   (no gap)
```

### NTILE — Divide into N buckets (quartiles, deciles)
```sql
-- Classify trips into fare quartiles
SELECT
    trip_id,
    fare_amount,
    NTILE(4) OVER (ORDER BY fare_amount) AS fare_quartile   -- 1=lowest, 4=highest
FROM yellow_taxi_trips
WHERE fare_amount > 0;
```

---

## 3. Offset Functions: LAG and LEAD

### LAG — Access previous row's value
```sql
-- Day-over-day revenue change
WITH daily_revenue AS (
    SELECT
        DATE_TRUNC('day', pickup_datetime)::DATE AS trip_date,
        SUM(total_amount) AS revenue
    FROM yellow_taxi_trips
    GROUP BY 1
)
SELECT
    trip_date,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY trip_date) AS prev_day_revenue,
    revenue - LAG(revenue, 1) OVER (ORDER BY trip_date) AS day_over_day_change,
    ROUND(
        (revenue - LAG(revenue, 1) OVER (ORDER BY trip_date))
        / NULLIF(LAG(revenue, 1) OVER (ORDER BY trip_date), 0) * 100, 2
    ) AS pct_change
FROM daily_revenue
ORDER BY trip_date;
```

### LEAD — Access next row's value
```sql
-- Time until next trip in a zone (gap analysis)
SELECT
    trip_id,
    pickup_location_id,
    pickup_datetime,
    LEAD(pickup_datetime) OVER (
        PARTITION BY pickup_location_id
        ORDER BY pickup_datetime
    ) AS next_trip_start,
    LEAD(pickup_datetime) OVER (
        PARTITION BY pickup_location_id
        ORDER BY pickup_datetime
    ) - pickup_datetime AS gap_to_next_trip
FROM yellow_taxi_trips
ORDER BY pickup_location_id, pickup_datetime
LIMIT 50;
```

---

## 4. Aggregate Window Functions

Run aggregates without GROUP BY:

```sql
SELECT
    trip_id,
    pickup_location_id,
    fare_amount,
    AVG(fare_amount) OVER (PARTITION BY pickup_location_id) AS zone_avg_fare,
    fare_amount - AVG(fare_amount) OVER (PARTITION BY pickup_location_id) AS diff_from_zone_avg,
    COUNT(*) OVER (PARTITION BY pickup_location_id) AS trips_in_zone,
    SUM(total_amount) OVER (PARTITION BY pickup_location_id) AS zone_total_revenue
FROM yellow_taxi_trips
WHERE fare_amount > 0
LIMIT 30;
```

---

## 5. Top-N per Group (Classic Problem)

Get the top N rows within each group — impossible with GROUP BY alone:

```sql
-- Top 3 most expensive trips per pickup borough
WITH ranked_trips AS (
    SELECT
        t.trip_id,
        t.pickup_datetime,
        t.fare_amount,
        z.borough,
        ROW_NUMBER() OVER (
            PARTITION BY z.borough
            ORDER BY t.fare_amount DESC
        ) AS rn
    FROM yellow_taxi_trips t
    INNER JOIN taxi_zones z ON t.pickup_location_id = z.location_id
    WHERE t.fare_amount > 0
)
SELECT *
FROM ranked_trips
WHERE rn <= 3
ORDER BY borough, rn;
```

---

## Key Takeaways
- Window functions keep all rows while computing group-level values
- `ROW_NUMBER` = unique; `RANK` = gaps on ties; `DENSE_RANK` = no gaps; `NTILE` = buckets
- `LAG`/`LEAD` access the previous/next row — essential for time-series analysis
- Aggregate functions (SUM, AVG, COUNT) work as window functions with OVER()
- Top-N per group = window function + filter in CTE/subquery

## 📝 Now open `practice/day08_exercises.sql`!

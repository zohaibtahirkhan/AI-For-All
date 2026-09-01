# Day 9 — Window Functions Advanced (Frames, Running Totals)

## 🎯 Learning Goals
Master window frames for running calculations and moving averages — core analytical patterns.

---

## 1. Window Frames

The ROWS/RANGE clause defines *which rows in the partition* are included in the window calculation.

```sql
OVER (
    ORDER BY trip_date
    ROWS BETWEEN start_bound AND end_bound
)
```

**Bounds:**
- `UNBOUNDED PRECEDING` — from the first row of partition
- `N PRECEDING` — N rows before current
- `CURRENT ROW` — current row only
- `N FOLLOWING` — N rows after current
- `UNBOUNDED FOLLOWING` — to the last row of partition

---

## 2. Running Totals

```sql
WITH daily AS (
    SELECT DATE_TRUNC('day', pickup_datetime)::DATE AS dt, SUM(total_amount) AS revenue
    FROM yellow_taxi_trips GROUP BY 1
)
SELECT
    dt,
    revenue,
    SUM(revenue) OVER (ORDER BY dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(revenue) OVER (ORDER BY dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM daily ORDER BY dt;
```

## 3. Moving Averages

```sql
WITH daily AS (
    SELECT DATE_TRUNC('day', pickup_datetime)::DATE AS dt, SUM(total_amount) AS revenue
    FROM yellow_taxi_trips GROUP BY 1
)
SELECT
    dt,
    revenue,
    AVG(revenue) OVER (ORDER BY dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ma_7day,
    AVG(revenue) OVER (ORDER BY dt ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS ma_30day
FROM daily ORDER BY dt;
```

## 4. FIRST_VALUE / LAST_VALUE / NTH_VALUE

```sql
SELECT
    trip_id,
    pickup_location_id,
    fare_amount,
    FIRST_VALUE(fare_amount) OVER (PARTITION BY pickup_location_id ORDER BY fare_amount DESC) AS zone_max_fare,
    LAST_VALUE(fare_amount) OVER (
        PARTITION BY pickup_location_id 
        ORDER BY fare_amount DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS zone_min_fare
FROM yellow_taxi_trips
WHERE fare_amount > 0;
```

## 5. Percentile Window Functions

```sql
SELECT
    pickup_location_id,
    AVG(fare_amount) AS avg_fare,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fare_amount) AS p50,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY fare_amount) AS p90,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY fare_amount) AS p99
FROM yellow_taxi_trips WHERE fare_amount > 0
GROUP BY pickup_location_id;
```

## 📝 Now open `practice/day09_exercises.sql`!

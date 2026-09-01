# Day 4 — Subqueries & CTEs

## 🎯 Learning Goals
Write modular, readable SQL using subqueries and Common Table Expressions. CTEs are the #1 tool for writing maintainable data pipelines.

---

## 1. Subqueries

A subquery is a query nested inside another query. It can appear in:
- `WHERE` clause (filter using a computed value)
- `FROM` clause (treat query result as a table — "derived table")
- `SELECT` clause (scalar subquery)

### Subquery in WHERE

```sql
-- Find trips with above-average fare
SELECT trip_id, pickup_datetime, fare_amount
FROM yellow_taxi_trips
WHERE fare_amount > (
    SELECT AVG(fare_amount)
    FROM yellow_taxi_trips
    WHERE fare_amount > 0
);
```

### IN with Subquery

```sql
-- Trips that picked up in Manhattan boroughs
SELECT trip_id, pickup_datetime, fare_amount
FROM yellow_taxi_trips
WHERE pickup_location_id IN (
    SELECT location_id
    FROM taxi_zones
    WHERE borough = 'Manhattan'
);
```

### EXISTS vs IN

```sql
-- EXISTS: typically faster when subquery could return NULL or large sets
SELECT t.trip_id, t.pickup_datetime
FROM yellow_taxi_trips t
WHERE EXISTS (
    SELECT 1
    FROM taxi_zones z
    WHERE z.location_id = t.pickup_location_id
      AND z.borough = 'Manhattan'
);

-- NOT EXISTS: find trips with NO matching zone (data quality check)
SELECT t.trip_id, t.pickup_location_id
FROM yellow_taxi_trips t
WHERE NOT EXISTS (
    SELECT 1
    FROM taxi_zones z
    WHERE z.location_id = t.pickup_location_id
);
```

### Subquery in FROM (Derived Table)

```sql
-- Get hourly summary, then filter for peak hours only
SELECT *
FROM (
    SELECT
        EXTRACT(HOUR FROM pickup_datetime) AS hour,
        COUNT(*) AS trips,
        AVG(fare_amount) AS avg_fare
    FROM yellow_taxi_trips
    GROUP BY EXTRACT(HOUR FROM pickup_datetime)
) hourly_stats
WHERE trips > 50000
ORDER BY trips DESC;
```

### Scalar Subquery in SELECT

```sql
-- Show each trip's fare vs. the zone's average fare
SELECT
    t.trip_id,
    t.pickup_location_id,
    t.fare_amount,
    (
        SELECT AVG(t2.fare_amount)
        FROM yellow_taxi_trips t2
        WHERE t2.pickup_location_id = t.pickup_location_id
          AND t2.fare_amount > 0
    ) AS zone_avg_fare,
    t.fare_amount - (
        SELECT AVG(t2.fare_amount)
        FROM yellow_taxi_trips t2
        WHERE t2.pickup_location_id = t.pickup_location_id
          AND t2.fare_amount > 0
    ) AS diff_from_zone_avg
FROM yellow_taxi_trips t
LIMIT 20;
-- ⚠️ Warning: correlated scalar subqueries are SLOW on large tables
-- Prefer window functions (Day 8) or CTEs for this pattern
```

---

## 2. Common Table Expressions (CTEs)

CTEs use the `WITH` keyword to name a query and reference it later. They're like temporary views scoped to a single query.

### Basic Syntax

```sql
WITH cte_name AS (
    -- This is the CTE query
    SELECT ...
    FROM ...
    WHERE ...
)
-- Main query references the CTE
SELECT *
FROM cte_name;
```

### Single CTE Example

```sql
-- Step 1: Get per-zone avg fare
-- Step 2: Find high-earning zones
WITH zone_stats AS (
    SELECT
        pickup_location_id,
        COUNT(*)            AS trips,
        AVG(fare_amount)    AS avg_fare,
        SUM(total_amount)   AS total_revenue
    FROM yellow_taxi_trips
    WHERE fare_amount > 0
    GROUP BY pickup_location_id
)
SELECT
    z.zone,
    z.borough,
    s.trips,
    ROUND(s.avg_fare, 2)      AS avg_fare,
    ROUND(s.total_revenue, 2) AS total_revenue
FROM zone_stats s
INNER JOIN taxi_zones z ON s.pickup_location_id = z.location_id
WHERE s.avg_fare > 20
ORDER BY s.total_revenue DESC;
```

### Multiple CTEs (chained)

```sql
WITH 
-- Step 1: Clean data (remove obvious outliers)
clean_trips AS (
    SELECT *
    FROM yellow_taxi_trips
    WHERE fare_amount BETWEEN 2.50 AND 500
      AND trip_distance BETWEEN 0.1 AND 100
      AND passenger_count BETWEEN 1 AND 6
      AND pickup_datetime IS NOT NULL
),

-- Step 2: Aggregate by zone
zone_summary AS (
    SELECT
        pickup_location_id,
        COUNT(*)                 AS trips,
        ROUND(AVG(fare_amount), 2)   AS avg_fare,
        ROUND(AVG(trip_distance), 2) AS avg_distance,
        ROUND(SUM(total_amount), 2)  AS total_revenue
    FROM clean_trips
    GROUP BY pickup_location_id
),

-- Step 3: Rank zones
zone_ranked AS (
    SELECT
        *,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM zone_summary
)

-- Final query: join to zone names and filter top 20
SELECT
    r.revenue_rank,
    z.zone,
    z.borough,
    r.trips,
    r.avg_fare,
    r.avg_distance,
    r.total_revenue
FROM zone_ranked r
INNER JOIN taxi_zones z ON r.pickup_location_id = z.location_id
WHERE r.revenue_rank <= 20
ORDER BY r.revenue_rank;
```

### CTEs for Data Pipelines (The Key Pattern)

In real data engineering, CTEs map to pipeline stages:

```sql
WITH
-- Stage 1: Source (raw data with basic filter)
source AS (
    SELECT *
    FROM yellow_taxi_trips
    WHERE pickup_datetime >= '2023-01-01'
      AND pickup_datetime <  '2023-02-01'
),

-- Stage 2: Cleaned (remove invalid records)
cleaned AS (
    SELECT *
    FROM source
    WHERE fare_amount > 0
      AND trip_distance > 0
      AND passenger_count > 0
      AND dropoff_datetime > pickup_datetime  -- sanity check
),

-- Stage 3: Enriched (add zone names)
enriched AS (
    SELECT
        c.*,
        pu.zone     AS pickup_zone,
        pu.borough  AS pickup_borough,
        do.zone     AS dropoff_zone,
        do.borough  AS dropoff_borough
    FROM cleaned c
    LEFT JOIN taxi_zones pu ON c.pickup_location_id = pu.location_id
    LEFT JOIN taxi_zones do ON c.dropoff_location_id = do.location_id
),

-- Stage 4: Feature-engineered (add computed columns)
featured AS (
    SELECT
        *,
        EXTRACT(EPOCH FROM (dropoff_datetime - pickup_datetime)) / 60 AS trip_minutes,
        EXTRACT(HOUR FROM pickup_datetime)                              AS pickup_hour,
        EXTRACT(DOW FROM pickup_datetime)                               AS day_of_week,
        CASE WHEN tip_amount > 0 THEN 1 ELSE 0 END                     AS tipped
    FROM enriched
)

-- Final output
SELECT *
FROM featured
ORDER BY pickup_datetime;
```

---

## 3. Recursive CTEs

Recursive CTEs can reference themselves. Used for hierarchical data (org charts, networks) and generating sequences.

### Generating a Date Series

```sql
-- Generate all dates in January 2023
WITH RECURSIVE date_series AS (
    -- Anchor: starting value
    SELECT '2023-01-01'::DATE AS dt
    
    UNION ALL
    
    -- Recursive: add one day until end of month
    SELECT dt + INTERVAL '1 day'
    FROM date_series
    WHERE dt < '2023-01-31'
)
SELECT dt FROM date_series;
```

### Left-joining date series to fill gaps in trip data

```sql
WITH RECURSIVE date_series AS (
    SELECT '2023-01-01'::DATE AS dt
    UNION ALL
    SELECT dt + INTERVAL '1 day'
    FROM date_series
    WHERE dt < '2023-01-31'
),
daily_trips AS (
    SELECT
        DATE_TRUNC('day', pickup_datetime)::DATE AS trip_date,
        COUNT(*) AS trips
    FROM yellow_taxi_trips
    GROUP BY 1
)
SELECT
    d.dt AS date,
    COALESCE(t.trips, 0) AS trip_count  -- 0 for days with no data
FROM date_series d
LEFT JOIN daily_trips t ON d.dt = t.trip_date
ORDER BY d.dt;
```

---

## 4. CTEs vs Subqueries — When to Use Each

| Scenario | Use |
|---------|-----|
| Simple, one-time filter | Subquery in WHERE |
| Complex multi-step logic | CTE |
| Reuse same result multiple times in query | CTE |
| Readability matters (production code) | CTE always |
| Recursive logic (dates, hierarchies) | Recursive CTE |

> **DE Rule of Thumb:** If a subquery is more than 3 lines or used more than once, make it a CTE. CTEs are self-documenting and easier to debug.

---

## 5. Materialized CTEs (PostgreSQL 12+)

By default, PostgreSQL may re-evaluate a CTE each time it's referenced. Use `MATERIALIZED` to force caching:

```sql
WITH expensive_calculation AS MATERIALIZED (
    SELECT pickup_location_id, COUNT(*) AS trips, AVG(fare_amount) AS avg_fare
    FROM yellow_taxi_trips
    GROUP BY pickup_location_id
)
-- This CTE is computed once and cached
SELECT * FROM expensive_calculation WHERE trips > 1000
UNION ALL
SELECT * FROM expensive_calculation WHERE avg_fare > 25;
```

---

## Key Takeaways

- Subqueries in WHERE are great for simple "filter by computed value" patterns
- `EXISTS` > `IN` when subquery may return NULLs or large result sets
- CTEs (`WITH`) break complex queries into named, readable stages
- Multiple CTEs chain naturally — think of them as pipeline stages
- Recursive CTEs generate sequences and handle hierarchical data
- In production: always prefer CTEs over deeply nested subqueries for readability

---

## 📝 Now open `practice/day04_exercises.sql` and complete the exercises!

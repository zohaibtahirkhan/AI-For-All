# Day 25 — Recursive CTEs & Graph Queries

## 🎯 Learning Goals
Handle hierarchical data and generate sequences using recursive SQL.

---

## 1. Recursive CTE Structure

```sql
WITH RECURSIVE cte AS (
    -- Anchor: runs once (starting rows)
    SELECT ...

    UNION ALL

    -- Recursive part: references cte itself, runs until no new rows
    SELECT ... FROM cte WHERE termination_condition
)
SELECT * FROM cte;
```

---

## 2. Generate Date Series

```sql
WITH RECURSIVE dates AS (
    SELECT '2023-01-01'::DATE AS dt
    UNION ALL
    SELECT dt + 1 FROM dates WHERE dt < '2023-12-31'
)
SELECT d.dt, COALESCE(t.trips, 0) AS trips
FROM dates d
LEFT JOIN (
    SELECT pickup_datetime::DATE AS dt, COUNT(*) AS trips
    FROM yellow_taxi_trips GROUP BY 1
) t ON d.dt = t.dt
ORDER BY d.dt;
```

---

## 3. Generate Number Series (PostgreSQL alternative)

```sql
-- Recursive approach
WITH RECURSIVE nums AS (
    SELECT 1 AS n UNION ALL SELECT n+1 FROM nums WHERE n < 24
)
SELECT n AS hour FROM nums;

-- PostgreSQL built-in (preferred)
SELECT generate_series(0, 23) AS hour_of_day;
SELECT generate_series('2023-01-01'::DATE, '2023-01-31'::DATE, '1 day') AS dt;
```

---

## 4. Trip Chain Analysis (Graph traversal)

```sql
-- Find zones reachable from JFK (zone 132) within 2 trip hops
WITH direct_connections AS (
    SELECT DISTINCT pickup_location_id, dropoff_location_id
    FROM yellow_taxi_trips
    WHERE fare_amount > 0
),
reachable AS (
    SELECT 132 AS zone, 0 AS hops, ARRAY[132] AS path
    UNION ALL
    SELECT c.dropoff_location_id, r.hops + 1, r.path || c.dropoff_location_id
    FROM reachable r
    INNER JOIN direct_connections c ON r.zone = c.pickup_location_id
    WHERE r.hops < 2
      AND NOT c.dropoff_location_id = ANY(r.path)   -- no cycles
)
SELECT DISTINCT zone, MIN(hops) AS min_hops
FROM reachable
GROUP BY zone
ORDER BY min_hops, zone;
```

## 📝 Now open `practice/day25_exercises.sql`!

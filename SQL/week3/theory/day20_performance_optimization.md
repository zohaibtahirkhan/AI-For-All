# Day 20 — Query Performance Optimization

## 🎯 Learning Goals
Diagnose slow queries and apply systematic optimizations — a core DE skill.

---

## 1. The Optimization Mindset

Always: **Measure first, optimize second.** Use EXPLAIN ANALYZE to find the bottleneck.

**Most common performance killers:**
1. Missing index on JOIN/WHERE/ORDER BY column
2. Function wrapping on indexed column (breaks index)
3. SELECT * with unused columns
4. Suboptimal join order
5. Not using partition pruning
6. N+1 query pattern (correlated subqueries in SELECT)

---

## 2. Query Rewriting Patterns

### Replace correlated subquery with JOIN

```sql
-- SLOW: correlated subquery runs once per row
SELECT t.trip_id, t.fare_amount,
    (SELECT AVG(fare_amount) FROM yellow_taxi_trips t2
     WHERE t2.pickup_location_id = t.pickup_location_id) AS zone_avg
FROM yellow_taxi_trips t;

-- FAST: compute zone avgs once, then join
WITH zone_avgs AS (
    SELECT pickup_location_id, AVG(fare_amount) AS avg_fare
    FROM yellow_taxi_trips GROUP BY pickup_location_id
)
SELECT t.trip_id, t.fare_amount, z.avg_fare AS zone_avg
FROM yellow_taxi_trips t
INNER JOIN zone_avgs z ON t.pickup_location_id = z.pickup_location_id;
```

### Push filters early (filter before join)

```sql
-- SLOW: join everything, then filter
SELECT t.*, z.borough
FROM yellow_taxi_trips t
INNER JOIN taxi_zones z ON t.pickup_location_id = z.location_id
WHERE z.borough = 'Manhattan';

-- FAST: filter the smaller table first
WITH manhattan_zones AS (
    SELECT location_id FROM taxi_zones WHERE borough = 'Manhattan'
)
SELECT t.*, 'Manhattan' AS borough
FROM yellow_taxi_trips t
INNER JOIN manhattan_zones z ON t.pickup_location_id = z.location_id;
```

### EXISTS instead of IN for large subquery results

```sql
-- IN loads all subquery results into memory
WHERE pickup_location_id IN (SELECT location_id FROM taxi_zones WHERE borough = 'Manhattan')

-- EXISTS short-circuits on first match
WHERE EXISTS (SELECT 1 FROM taxi_zones z
              WHERE z.location_id = t.pickup_location_id AND z.borough = 'Manhattan')
```

---

## 3. Statistics and Vacuuming

```sql
-- Update table statistics (run after bulk loads)
ANALYZE yellow_taxi_trips;

-- Reclaim space and update stats
VACUUM ANALYZE yellow_taxi_trips;

-- Check if table needs vacuuming
SELECT relname, n_live_tup, n_dead_tup, last_vacuum, last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'yellow_taxi_trips';
```

---

## 4. Batch Processing Pattern

```sql
-- Process large updates in batches to avoid lock contention
DO $$
DECLARE
    batch_size INT := 10000;
    offset_val INT := 0;
    rows_updated INT;
BEGIN
    LOOP
        UPDATE yellow_taxi_trips
        SET fare_category = classify_fare(fare_amount)
        WHERE trip_id IN (
            SELECT trip_id FROM yellow_taxi_trips
            WHERE fare_category IS NULL
            LIMIT batch_size
        );
        GET DIAGNOSTICS rows_updated = ROW_COUNT;
        EXIT WHEN rows_updated = 0;
        RAISE NOTICE 'Updated % rows', rows_updated;
        PERFORM pg_sleep(0.1);  -- brief pause to reduce I/O pressure
    END LOOP;
END;
$$;
```

## 📝 Now open `practice/day20_exercises.sql`!

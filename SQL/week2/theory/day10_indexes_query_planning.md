# indexes_query_planning — Indexes & Query Planning (EXPLAIN ANALYZE)

## 🎯 Learning Goals
Understand how PostgreSQL finds data; write queries that use indexes efficiently.

---

## 1. What Is an Index?
An index is a separate data structure that lets PostgreSQL find rows without scanning the whole table.

```sql
-- EXPLAIN ANALYZE: see what the query planner does
EXPLAIN ANALYZE
SELECT * FROM yellow_taxi_trips WHERE pickup_datetime > '2023-01-15';

-- Without index: Seq Scan (reads every row)
-- With index:   Index Scan (jumps directly)
```

## 2. Creating Indexes
```sql
-- B-tree index (default) — good for =, <, >, BETWEEN, ORDER BY
CREATE INDEX idx_pickup_datetime ON yellow_taxi_trips(pickup_datetime);

-- Composite index (column order matters: most selective first)
CREATE INDEX idx_zone_date ON yellow_taxi_trips(pickup_location_id, pickup_datetime);

-- Partial index (only index a subset)
CREATE INDEX idx_large_fares ON yellow_taxi_trips(fare_amount) WHERE fare_amount > 100;

-- Drop an index
DROP INDEX idx_pickup_datetime;
```

## 3. Reading EXPLAIN Output
```
Seq Scan   → reading all rows (bad for large tables)
Index Scan → using index (good)
Bitmap Heap Scan → index + heap fetch (OK for moderate selectivity)

Key numbers to watch:
- cost=0.00..1234.56  (estimated rows and cost)
- actual time=0.025..5.432  (real execution time in ms)
- rows=1234  (actual rows returned)
- loops=1   (how many times this step ran)
```

## 4. When Indexes Help vs Hurt
**Help:** Highly selective filters (few rows match), JOINs on foreign keys, ORDER BY on large tables  
**Hurt:** Low-cardinality columns (boolean, payment_type), write-heavy tables (every INSERT updates all indexes), function-wrapped columns

```sql
-- Function on indexed column kills the index:
WHERE UPPER(zone) = 'MANHATTAN'   -- ❌ index not used
WHERE zone = 'Manhattan'          -- ✅ index used

-- Expression index for function queries:
CREATE INDEX idx_upper_zone ON taxi_zones(UPPER(zone));
```

## 📝 Now open `practice/day10_exercises.sql`!

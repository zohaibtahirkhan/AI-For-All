# Day 7 — Set Operations (UNION, INTERSECT, EXCEPT)

## 🎯 Learning Goals
Combine results from multiple queries — key for reconciliation, deduplication, and combining data sources in pipelines.

---

## 1. UNION — Combine and Deduplicate

`UNION` stacks two result sets and removes duplicates. `UNION ALL` keeps duplicates (faster, no dedup step).

**Rules:** Both queries must have the same number of columns and compatible data types.

```sql
-- All unique pickup location IDs used by either yellow OR green taxis
SELECT DISTINCT pickup_location_id FROM yellow_taxi_trips
UNION
SELECT DISTINCT pickup_location_id FROM green_taxi_trips
ORDER BY pickup_location_id;
```

### UNION ALL (preferred for pipelines)
```sql
-- Combine yellow and green trip data into a single result
SELECT 
    'yellow'         AS taxi_type,
    pickup_datetime,
    fare_amount,
    trip_distance
FROM yellow_taxi_trips

UNION ALL

SELECT 
    'green'          AS taxi_type,
    pickup_datetime,
    fare_amount,
    trip_distance
FROM green_taxi_trips

ORDER BY pickup_datetime
LIMIT 50;
```

> **DE Rule:** Always use `UNION ALL` unless you specifically need deduplication. `UNION` adds a sort+dedup step that's expensive at scale.

### CTE + UNION ALL (pipeline pattern)
```sql
WITH all_trips AS (
    SELECT 'yellow' AS source, vendor_id, pickup_datetime, fare_amount, total_amount
    FROM yellow_taxi_trips
    UNION ALL
    SELECT 'green'  AS source, vendor_id, pickup_datetime, fare_amount, total_amount
    FROM green_taxi_trips
)
SELECT
    source,
    DATE_TRUNC('day', pickup_datetime) AS trip_date,
    COUNT(*) AS trips,
    SUM(total_amount) AS revenue
FROM all_trips
GROUP BY source, DATE_TRUNC('day', pickup_datetime)
ORDER BY trip_date, source;
```

---

## 2. INTERSECT — Only Rows in Both

Returns rows that appear in BOTH result sets.

```sql
-- Location IDs that appear as pickup zones in BOTH yellow AND green taxis
SELECT DISTINCT pickup_location_id FROM yellow_taxi_trips
INTERSECT
SELECT DISTINCT pickup_location_id FROM green_taxi_trips
ORDER BY pickup_location_id;
```

---

## 3. EXCEPT — Rows in First but Not Second

```sql
-- Location IDs used by yellow taxis but NOT by green taxis
SELECT DISTINCT pickup_location_id FROM yellow_taxi_trips
EXCEPT
SELECT DISTINCT pickup_location_id FROM green_taxi_trips
ORDER BY pickup_location_id;

-- Location IDs in taxi_zones that are NEVER used as a pickup
SELECT location_id FROM taxi_zones
EXCEPT
SELECT DISTINCT pickup_location_id FROM yellow_taxi_trips
ORDER BY location_id;
```

---

## 4. Practical DE Use Cases

### Data Reconciliation (compare two sources)
```sql
-- Records in source A but not in B (missing data)
WITH source_a AS (SELECT trip_id FROM yellow_taxi_trips),
     source_b AS (SELECT trip_id FROM some_other_system)
SELECT 'In A not B' AS status, COUNT(*) FROM (SELECT trip_id FROM source_a EXCEPT SELECT trip_id FROM source_b) x
UNION ALL
SELECT 'In B not A', COUNT(*) FROM (SELECT trip_id FROM source_b EXCEPT SELECT trip_id FROM source_a) x;
```

### Incremental Load: Find New Records
```sql
-- Find records in staging table that don't exist in production
SELECT trip_id FROM staging_yellow_taxi
EXCEPT
SELECT trip_id FROM yellow_taxi_trips;
```

---

## Key Takeaways
- `UNION ALL` = stack rows (keep dupes); `UNION` = stack + deduplicate
- Always use `UNION ALL` in pipelines for performance
- `INTERSECT` = overlap only; `EXCEPT` = set difference
- These are invaluable for data reconciliation between two sources

---

## 🎉 Week 1 Complete!
You now know the full SQL foundation:
SELECT → Aggregations → JOINs → CTEs → Functions → NULLs → Set Ops

## 📝 Open `practice/day07_exercises.sql` to finish the week!

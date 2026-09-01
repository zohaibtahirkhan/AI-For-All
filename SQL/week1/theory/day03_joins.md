# Day 3 — JOINs (INNER, LEFT, RIGHT, FULL, CROSS, SELF)

## 🎯 Learning Goals
Master every type of JOIN and understand when to use each one. JOINs are the most fundamental data engineering operation — you'll use them every single day.

---

## 1. The Concept of a JOIN

A JOIN combines rows from two or more tables based on a related column. In our dataset:
- `yellow_taxi_trips` has `pickup_location_id` (a number)
- `taxi_zones` has `location_id` (a number) + `borough`, `zone`, `service_zone`

A JOIN lets you combine these to see *where* each trip actually went.

---

## 2. INNER JOIN — Only Matching Rows

Returns rows that have a match in **both** tables. Non-matching rows are dropped.

```sql
SELECT
    t.pickup_datetime,
    t.fare_amount,
    z.borough     AS pickup_borough,
    z.zone        AS pickup_zone
FROM yellow_taxi_trips t
INNER JOIN taxi_zones z ON t.pickup_location_id = z.location_id
LIMIT 20;
```

> **Tip:** Table aliases (`t`, `z`) keep queries readable. Use them always with JOINs.

```sql
-- Join both pickup AND dropoff zones
SELECT
    t.pickup_datetime,
    t.fare_amount,
    pu.zone   AS pickup_zone,
    pu.borough AS pickup_borough,
    do.zone   AS dropoff_zone,
    do.borough AS dropoff_borough
FROM yellow_taxi_trips t
INNER JOIN taxi_zones pu ON t.pickup_location_id = pu.location_id
INNER JOIN taxi_zones do ON t.dropoff_location_id = do.location_id
LIMIT 20;
```

### INNER JOIN with Aggregation (the most common real pattern)

```sql
-- Revenue by borough (INNER JOIN + GROUP BY)
SELECT
    z.borough,
    COUNT(*)                    AS trips,
    ROUND(SUM(t.total_amount), 2) AS total_revenue,
    ROUND(AVG(t.fare_amount), 2)  AS avg_fare
FROM yellow_taxi_trips t
INNER JOIN taxi_zones z ON t.pickup_location_id = z.location_id
GROUP BY z.borough
ORDER BY total_revenue DESC;
```

---

## 3. LEFT JOIN — All Left Table Rows

Returns **all rows from the left table** and matching rows from the right. Non-matching right rows become NULL.

```sql
-- Show all trips, even those with unknown pickup zones
SELECT
    t.trip_id,
    t.pickup_location_id,
    z.borough,  -- NULL if no match in taxi_zones
    z.zone      -- NULL if no match in taxi_zones
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z ON t.pickup_location_id = z.location_id
WHERE z.location_id IS NULL  -- Find trips with unrecognized location IDs
LIMIT 20;
```

> ⚠️ **Key DE insight:** Use LEFT JOIN when you need *all records from the main table* regardless of whether lookup table matches. This is essential for data quality auditing and avoiding silent data loss in pipelines.

```sql
-- Find which zones have no trips (zones that are never a pickup location)
SELECT
    z.location_id,
    z.borough,
    z.zone,
    COUNT(t.trip_id) AS trip_count
FROM taxi_zones z
LEFT JOIN yellow_taxi_trips t ON z.location_id = t.pickup_location_id
GROUP BY z.location_id, z.borough, z.zone
HAVING COUNT(t.trip_id) = 0
ORDER BY z.borough, z.zone;
```

---

## 4. RIGHT JOIN

Returns **all rows from the right table** + matching left rows. Rarely used — you can always rewrite a RIGHT JOIN as a LEFT JOIN by swapping tables.

```sql
-- Same as the LEFT JOIN example above, just written differently
SELECT
    z.location_id,
    z.borough,
    t.trip_id
FROM yellow_taxi_trips t
RIGHT JOIN taxi_zones z ON t.pickup_location_id = z.location_id;
-- Equivalent to: taxi_zones LEFT JOIN yellow_taxi_trips
```

---

## 5. FULL OUTER JOIN

Returns **all rows from both tables**. Non-matching rows have NULLs on the side with no match.

```sql
-- Compare yellow vs green taxi trips per zone
-- (Trips that exist in one but not the other)
SELECT
    COALESCE(y.pickup_location_id, g.pickup_location_id) AS location_id,
    COUNT(y.trip_id) AS yellow_trips,
    COUNT(g.trip_id) AS green_trips
FROM yellow_taxi_trips y
FULL OUTER JOIN green_taxi_trips g 
    ON y.pickup_location_id = g.pickup_location_id
    AND DATE_TRUNC('day', y.pickup_datetime) = DATE_TRUNC('day', g.pickup_datetime)
GROUP BY COALESCE(y.pickup_location_id, g.pickup_location_id);
```

---

## 6. CROSS JOIN

Returns the **Cartesian product** — every row from table A combined with every row from table B. Use carefully (can produce huge results).

```sql
-- Create a report template: all boroughs × all payment types
SELECT
    b.borough,
    pt.description AS payment_type_name
FROM (SELECT DISTINCT borough FROM taxi_zones) b
CROSS JOIN payment_types pt
ORDER BY b.borough, pt.payment_type_id;
-- Useful for ensuring all combinations appear in a report
-- even if some have zero trips
```

---

## 7. SELF JOIN

A table joins with itself. Used for hierarchical or comparison queries.

```sql
-- Find zones in the same borough but different service zones
-- (comparing a zone to other zones in the same borough)
SELECT
    a.zone      AS zone_1,
    b.zone      AS zone_2,
    a.borough,
    a.service_zone AS zone_1_service,
    b.service_zone AS zone_2_service
FROM taxi_zones a
INNER JOIN taxi_zones b 
    ON a.borough = b.borough           -- Same borough
    AND a.service_zone <> b.service_zone  -- Different service zone
    AND a.location_id < b.location_id     -- Avoid duplicates (A+B and B+A)
ORDER BY a.borough, a.zone
LIMIT 20;
```

---

## 8. JOIN Types Visual Summary

```
Table A:  1, 2, 3, 4
Table B:  2, 3, 4, 5

INNER JOIN:       2, 3, 4         (only matches)
LEFT JOIN:    1, 2, 3, 4         (all A + matched B; unmatched B = NULL)
RIGHT JOIN:      2, 3, 4, 5      (matched A + all B; unmatched A = NULL)
FULL JOIN:  1, 2, 3, 4, 5        (everything)
CROSS JOIN: every combination    (A rows × B rows)
```

---

## 9. Common DE Pitfalls with JOINs

### Fanout (Duplicate Rows)
If the right table has multiple rows matching one left row, you get duplicates:

```sql
-- If taxi_zones had duplicate location_ids, this would multiply rows!
SELECT COUNT(*) FROM yellow_taxi_trips;  -- Say: 1,000,000

SELECT COUNT(*)
FROM yellow_taxi_trips t
INNER JOIN taxi_zones z ON t.pickup_location_id = z.location_id;
-- If taxi_zones has 2 rows for location_id 161, count becomes 1,200,000!
-- Always check for duplicates in lookup tables before joining
```

**Always verify uniqueness first:**
```sql
-- Check for duplicates in the join key
SELECT location_id, COUNT(*) 
FROM taxi_zones 
GROUP BY location_id 
HAVING COUNT(*) > 1;
-- If this returns rows, you have a problem!
```

### Implicit Filtering from INNER JOIN
When you INNER JOIN and the lookup table doesn't have all keys, you silently lose rows:

```sql
-- This drops trips with unknown location_ids!
SELECT t.*, z.borough
FROM yellow_taxi_trips t
INNER JOIN taxi_zones z ON t.pickup_location_id = z.location_id;

-- Use LEFT JOIN to keep everything and flag unknowns:
SELECT 
    t.*,
    COALESCE(z.borough, 'UNKNOWN') AS borough
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z ON t.pickup_location_id = z.location_id;
```

### Multi-Column JOINs
Sometimes you need multiple columns to uniquely identify a match:

```sql
SELECT t.*, ref.description
FROM yellow_taxi_trips t
INNER JOIN some_reference_table ref 
    ON t.vendor_id = ref.vendor_id
    AND t.rate_code_id = ref.rate_code_id;
```

---

## 10. JOIN Performance Tips

- **Index the join columns** (especially foreign keys)
- **Filter before joining** (use WHERE or subquery to reduce rows first)
- **Prefer INNER JOIN over CROSS JOIN** unless you explicitly need the Cartesian product
- **In BigQuery/Redshift**: large table goes first (left), smaller lookup table goes second (right)

---

## Key Takeaways

| JOIN type | When to use |
|-----------|-------------|
| INNER JOIN | When both sides must have a match; most common for reporting |
| LEFT JOIN | When you need all records from the main table; use in pipelines to avoid data loss |
| RIGHT JOIN | Rare; just flip to LEFT JOIN for clarity |
| FULL OUTER JOIN | Reconciliation queries; comparing two sources |
| CROSS JOIN | Generating combinations; creating report scaffolds |
| SELF JOIN | Hierarchical data; comparing rows in same table |

---

## 📝 Now open `practice/day03_exercises.sql` and complete the exercises!

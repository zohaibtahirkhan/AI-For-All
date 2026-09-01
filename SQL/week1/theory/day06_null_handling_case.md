# Day 6 — NULL Handling & CASE WHEN

## 🎯 Learning Goals
Handle NULLs safely and write conditional logic — essential for data cleaning pipelines.

---

## 1. Understanding NULL

NULL means "unknown" or "missing" — it is NOT zero, NOT empty string, NOT false.

```sql
-- NULL arithmetic always returns NULL
SELECT NULL + 5;      -- NULL
SELECT NULL * 0;      -- NULL (not 0!)
SELECT NULL = NULL;   -- NULL (not TRUE!)
SELECT NULL IS NULL;  -- TRUE — the only safe comparison
```

### The NULL trap in WHERE
```sql
-- This MISSES rows where passenger_count IS NULL:
SELECT * FROM yellow_taxi_trips WHERE passenger_count != 1;

-- Correct: explicitly include NULLs if needed
SELECT * FROM yellow_taxi_trips 
WHERE passenger_count != 1 OR passenger_count IS NULL;
```

---

## 2. NULL-Handling Functions

### COALESCE — First non-NULL value
```sql
SELECT
    trip_id,
    COALESCE(passenger_count, 1)       AS passengers,    -- default to 1
    COALESCE(tip_amount, 0)            AS tip,           -- default to 0
    COALESCE(congestion_surcharge, 0)  AS congestion
FROM yellow_taxi_trips
LIMIT 10;
```

### NULLIF — Return NULL if equal to value
```sql
-- Avoid divide-by-zero: NULLIF returns NULL if denominator is 0
SELECT
    fare_amount / NULLIF(trip_distance, 0) AS fare_per_mile
FROM yellow_taxi_trips;
```

### IS NULL / IS NOT NULL
```sql
SELECT
    COUNT(*)                        AS total,
    COUNT(passenger_count)          AS non_null_passengers,
    COUNT(*) - COUNT(passenger_count) AS null_passengers
FROM yellow_taxi_trips;
```

---

## 3. CASE WHEN

The SQL version of if/else.

### Simple CASE
```sql
SELECT
    trip_id,
    payment_type,
    CASE payment_type
        WHEN 1 THEN 'Credit Card'
        WHEN 2 THEN 'Cash'
        WHEN 3 THEN 'No Charge'
        WHEN 4 THEN 'Dispute'
        ELSE 'Other'
    END AS payment_description
FROM yellow_taxi_trips;
```

### Searched CASE (more flexible)
```sql
SELECT
    fare_amount,
    CASE
        WHEN fare_amount < 5              THEN 'Minimum'
        WHEN fare_amount BETWEEN 5 AND 20 THEN 'Standard'
        WHEN fare_amount BETWEEN 20 AND 50 THEN 'Long Trip'
        WHEN fare_amount > 50             THEN 'Premium'
        ELSE 'Unknown'
    END AS fare_category
FROM yellow_taxi_trips;
```

### CASE in aggregations (conditional counts)
```sql
SELECT
    COUNT(*)                                              AS total_trips,
    COUNT(CASE WHEN fare_amount < 5 THEN 1 END)          AS short_trips,
    COUNT(CASE WHEN fare_amount > 50 THEN 1 END)         AS long_trips,
    SUM(CASE WHEN payment_type = 1 THEN tip_amount 
             ELSE 0 END)                                  AS cc_tips_total
FROM yellow_taxi_trips;
```

### CASE for Safe Division (always pair with NULLIF)
```sql
SELECT
    tip_amount / NULLIF(fare_amount, 0) * 100 AS tip_pct
FROM yellow_taxi_trips
WHERE payment_type = 1;
```

---

## 4. Data Cleaning Patterns

### Standardize a messy column
```sql
UPDATE yellow_taxi_trips
SET passenger_count = CASE
    WHEN passenger_count IS NULL     THEN 1
    WHEN passenger_count <= 0        THEN 1
    WHEN passenger_count > 6         THEN NULL  -- Mark as invalid
    ELSE passenger_count
END;
```

### NULL-safe comparison
```sql
-- Check if two nullable columns are equal
SELECT *
FROM yellow_taxi_trips t1
WHERE (t1.passenger_count = t1.vendor_id)
   OR (t1.passenger_count IS NULL AND t1.vendor_id IS NULL);
-- PostgreSQL also has: t1.passenger_count IS NOT DISTINCT FROM t1.vendor_id
```

---

## Key Takeaways
- NULL propagates: any arithmetic with NULL returns NULL
- `COALESCE(col, default)` replaces NULL with a fallback
- `NULLIF(col, value)` converts a specific value to NULL (prevents divide-by-zero)
- `CASE WHEN` is if/else logic — indispensable for data transformation
- Always handle NULL explicitly in WHERE clauses

## 📝 Now open `practice/day06_exercises.sql`!

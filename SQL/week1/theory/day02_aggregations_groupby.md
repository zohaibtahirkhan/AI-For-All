# Day 2 — Aggregations & GROUP BY

## 🎯 Learning Goals
Summarize millions of rows into meaningful metrics. This is the bread-and-butter of every data pipeline and analytical query.

---

## 1. Aggregate Functions

Aggregate functions collapse multiple rows into a single value.

| Function | Purpose | Example |
|----------|---------|---------|
| `COUNT(*)` | Count all rows | Total trips |
| `COUNT(col)` | Count non-NULL values | Trips with a tip |
| `SUM(col)` | Sum of values | Total revenue |
| `AVG(col)` | Average value | Avg fare |
| `MIN(col)` | Minimum value | Cheapest trip |
| `MAX(col)` | Maximum value | Most expensive trip |
| `STDDEV(col)` | Standard deviation | Fare variability |
| `PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY col)` | Median | Median fare |

```sql
-- Summary stats for the whole dataset
SELECT
    COUNT(*)                                                  AS total_trips,
    COUNT(tip_amount)                                         AS trips_with_tip_recorded,
    ROUND(SUM(fare_amount), 2)                                AS total_revenue,
    ROUND(AVG(fare_amount), 2)                                AS avg_fare,
    MIN(fare_amount)                                          AS min_fare,
    MAX(fare_amount)                                          AS max_fare,
    ROUND(STDDEV(fare_amount), 2)                             AS fare_stddev,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fare_amount)  AS median_fare
FROM yellow_taxi_trips
WHERE fare_amount > 0;
```

### COUNT(*) vs COUNT(column)

```sql
SELECT
    COUNT(*)               AS all_rows,          -- Counts everything, including NULLs
    COUNT(passenger_count) AS rows_with_passengers,  -- Excludes NULLs
    COUNT(DISTINCT passenger_count) AS unique_passenger_counts
FROM yellow_taxi_trips;
```

---

## 2. GROUP BY — Aggregating by Category

`GROUP BY` splits the table into groups and applies aggregate functions to each group.

### Syntax
```sql
SELECT grouping_column, AGG_FUNCTION(column)
FROM table
GROUP BY grouping_column;
```

### Example: Revenue by payment type

```sql
SELECT
    payment_type,
    COUNT(*)                      AS trip_count,
    ROUND(SUM(total_amount), 2)   AS total_revenue,
    ROUND(AVG(fare_amount), 2)    AS avg_fare
FROM yellow_taxi_trips
GROUP BY payment_type
ORDER BY total_revenue DESC;
```

### GROUP BY Multiple Columns

```sql
-- Trips and revenue by vendor and payment type
SELECT
    vendor_id,
    payment_type,
    COUNT(*)                    AS trips,
    ROUND(AVG(fare_amount), 2)  AS avg_fare
FROM yellow_taxi_trips
GROUP BY vendor_id, payment_type
ORDER BY vendor_id, payment_type;
```

### GROUP BY with Date Truncation (common in DE work)

```sql
-- Daily trip counts and revenue
SELECT
    DATE_TRUNC('day', pickup_datetime)  AS trip_date,
    COUNT(*)                             AS trips,
    ROUND(SUM(total_amount), 2)          AS daily_revenue
FROM yellow_taxi_trips
GROUP BY DATE_TRUNC('day', pickup_datetime)
ORDER BY trip_date;

-- By hour of day (demand pattern analysis)
SELECT
    EXTRACT(HOUR FROM pickup_datetime)  AS hour_of_day,
    COUNT(*)                             AS trip_count,
    ROUND(AVG(fare_amount), 2)           AS avg_fare
FROM yellow_taxi_trips
GROUP BY EXTRACT(HOUR FROM pickup_datetime)
ORDER BY hour_of_day;
```

---

## 3. HAVING — Filtering Aggregated Results

`WHERE` filters *rows before* aggregation. `HAVING` filters *groups after* aggregation.

```sql
-- Payment types with more than 10,000 trips
SELECT
    payment_type,
    COUNT(*) AS trip_count
FROM yellow_taxi_trips
GROUP BY payment_type
HAVING COUNT(*) > 10000
ORDER BY trip_count DESC;
```

### WHERE vs HAVING — Side by Side

```sql
-- WHERE filters individual rows before grouping
SELECT payment_type, COUNT(*) AS trips
FROM yellow_taxi_trips
WHERE fare_amount > 10          -- Only include rows where fare > $10
GROUP BY payment_type;

-- HAVING filters groups after aggregation
SELECT payment_type, COUNT(*) AS trips
FROM yellow_taxi_trips
GROUP BY payment_type
HAVING COUNT(*) > 5000;         -- Only include groups with >5000 trips
```

### Using Both

```sql
SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
    COUNT(*)                            AS trips,
    AVG(fare_amount)                    AS avg_fare
FROM yellow_taxi_trips
WHERE fare_amount BETWEEN 5 AND 200   -- Exclude outliers first
GROUP BY EXTRACT(HOUR FROM pickup_datetime)
HAVING COUNT(*) > 1000               -- Only hours with meaningful volume
ORDER BY avg_fare DESC;
```

---

## 4. Execution Order (Updated)

```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

This is why you can't use a SELECT alias in HAVING:

```sql
-- ❌ WRONG
SELECT payment_type, COUNT(*) AS cnt
FROM yellow_taxi_trips
GROUP BY payment_type
HAVING cnt > 1000;  -- "cnt" not yet defined!

-- ✅ CORRECT
SELECT payment_type, COUNT(*) AS cnt
FROM yellow_taxi_trips
GROUP BY payment_type
HAVING COUNT(*) > 1000;
```

---

## 5. Useful Aggregation Patterns for AI and Data Engineers

### Null Rate Check (Data Quality)
```sql
SELECT
    COUNT(*)                                      AS total_rows,
    COUNT(passenger_count)                        AS non_null_passenger,
    COUNT(*) - COUNT(passenger_count)             AS null_passenger_count,
    ROUND(
        (COUNT(*) - COUNT(passenger_count))::NUMERIC / COUNT(*) * 100, 2
    )                                             AS null_pct
FROM yellow_taxi_trips;
```

### Min/Max Date Bounds (Pipeline Validation)
```sql
SELECT
    MIN(pickup_datetime) AS earliest_record,
    MAX(pickup_datetime) AS latest_record,
    MAX(pickup_datetime) - MIN(pickup_datetime) AS date_span
FROM yellow_taxi_trips;
```

### Approximate Distinct Count (Big Data)
```sql
-- COUNT(DISTINCT col) is expensive on large tables
-- Use approximation functions in BigQuery/Redshift:
-- BigQuery: APPROX_COUNT_DISTINCT(col)
-- Redshift: APPROXIMATE COUNT(DISTINCT col)
-- PostgreSQL: use HyperLogLog extension for large tables

SELECT COUNT(DISTINCT pickup_location_id) AS unique_pickup_zones
FROM yellow_taxi_trips;
```

### Conditional Aggregation (Pivoting)
```sql
-- Count trips per payment type in a single row
SELECT
    COUNT(*) FILTER (WHERE payment_type = 1) AS credit_card_trips,
    COUNT(*) FILTER (WHERE payment_type = 2) AS cash_trips,
    COUNT(*) FILTER (WHERE payment_type = 3) AS no_charge_trips,
    COUNT(*) FILTER (WHERE payment_type = 4) AS dispute_trips
FROM yellow_taxi_trips;

-- The SUM + CASE pattern (works in all databases):
SELECT
    SUM(CASE WHEN payment_type = 1 THEN 1 ELSE 0 END) AS credit_card_trips,
    SUM(CASE WHEN payment_type = 2 THEN 1 ELSE 0 END) AS cash_trips,
    SUM(CASE WHEN tip_amount > 0 THEN tip_amount ELSE 0 END) AS total_tips
FROM yellow_taxi_trips;
```

---

## 6. GROUP BY ROLLUP and CUBE (Advanced)

```sql
-- ROLLUP: Subtotals and grand total
SELECT
    EXTRACT(MONTH FROM pickup_datetime) AS month,
    payment_type,
    COUNT(*) AS trips,
    ROUND(SUM(total_amount), 2) AS revenue
FROM yellow_taxi_trips
WHERE EXTRACT(YEAR FROM pickup_datetime) = 2023
GROUP BY ROLLUP(
    EXTRACT(MONTH FROM pickup_datetime),
    payment_type
)
ORDER BY month NULLS LAST, payment_type NULLS LAST;
-- NULL in month = grand total row
-- NULL in payment_type = monthly subtotal

-- CUBE: All combinations of subtotals
-- GROUP BY CUBE(col1, col2) generates subtotals for every dimension combo
```

---

## Key Takeaways

- Use `COUNT(*)` to count rows, `COUNT(col)` to count non-NULLs
- `GROUP BY` collapses groups — every SELECT column must be either grouped or aggregated
- `HAVING` filters after aggregation (like WHERE is for rows)
- Conditional aggregation (`FILTER` / `CASE WHEN`) enables pivot-style queries
- `DATE_TRUNC` is your best friend for time-series aggregations
- `NULL` rates and date bounds checks are essential DE patterns

---

## 📝 Now open `practice/day02_exercises.sql` and complete the exercises!

# Day 19 — Data Quality Checks in SQL

## 🎯 Learning Goals
Build systematic SQL-based data quality checks — the foundation of trustworthy pipelines.

---

## 1. Categories of Data Quality Checks

| Category | What to Check | Example |
|---------|--------------|---------|
| Completeness | Null rates | passenger_count null % |
| Uniqueness | Duplicate rows | Duplicate trip_ids |
| Validity | Value ranges | fare_amount >= 0 |
| Consistency | Cross-column logic | dropoff > pickup |
| Referential Integrity | FK violations | location_id in taxi_zones |
| Freshness | Data recency | Max date < today - 2 |
| Volume | Row count anomaly | Today's rows vs 7-day avg |

---

## 2. Writing Quality Checks

```sql
-- Build a reusable DQ check framework
CREATE TABLE dq_results (
    check_id      SERIAL PRIMARY KEY,
    check_name    TEXT NOT NULL,
    check_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    table_name    TEXT,
    rows_checked  BIGINT,
    rows_failed   BIGINT,
    failure_rate  NUMERIC(5,4),
    threshold_pct NUMERIC(5,4),
    passed        BOOLEAN,
    checked_at    TIMESTAMP DEFAULT NOW()
);

-- Run a batch of checks
WITH checks AS (
    SELECT 
        'null_fare_amount'    AS check_name, 'yellow_taxi_trips' AS tbl,
        COUNT(*) AS total, COUNT(*) FILTER (WHERE fare_amount IS NULL) AS failed
    FROM yellow_taxi_trips
    UNION ALL
    SELECT 'negative_fare', 'yellow_taxi_trips',
        COUNT(*), COUNT(*) FILTER (WHERE fare_amount < 0)
    FROM yellow_taxi_trips
    UNION ALL
    SELECT 'invalid_duration', 'yellow_taxi_trips',
        COUNT(*), COUNT(*) FILTER (WHERE dropoff_datetime <= pickup_datetime)
    FROM yellow_taxi_trips
    UNION ALL
    SELECT 'null_location', 'yellow_taxi_trips',
        COUNT(*), COUNT(*) FILTER (WHERE pickup_location_id IS NULL OR dropoff_location_id IS NULL)
    FROM yellow_taxi_trips
    UNION ALL
    SELECT 'unknown_pickup_zone', 'yellow_taxi_trips',
        COUNT(*), COUNT(*) FILTER (WHERE pickup_location_id NOT IN (SELECT location_id FROM taxi_zones))
    FROM yellow_taxi_trips
)
INSERT INTO dq_results (check_name, table_name, rows_checked, rows_failed, failure_rate, threshold_pct, passed)
SELECT
    check_name, tbl, total, failed,
    ROUND(failed::NUMERIC / NULLIF(total, 0), 4) AS failure_rate,
    0.01 AS threshold_pct,  -- 1% failure tolerance
    (failed::NUMERIC / NULLIF(total, 0)) <= 0.01 AS passed
FROM checks;

-- Check results
SELECT check_name, rows_failed, failure_rate, passed
FROM dq_results
ORDER BY checked_at DESC;
```

---

## 3. Volume Anomaly Detection

```sql
-- Flag days where trip count is outside 2 stddevs of the 30-day rolling mean
WITH daily AS (
    SELECT DATE_TRUNC('day', pickup_datetime)::DATE AS dt, COUNT(*) AS trips
    FROM yellow_taxi_trips GROUP BY 1
),
stats AS (
    SELECT dt, trips,
        AVG(trips) OVER (ORDER BY dt ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING) AS rolling_avg,
        STDDEV(trips) OVER (ORDER BY dt ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING) AS rolling_std
    FROM daily
)
SELECT dt, trips, ROUND(rolling_avg, 0) AS expected,
    ROUND((trips - rolling_avg) / NULLIF(rolling_std, 0), 2) AS z_score,
    CASE WHEN ABS((trips - rolling_avg) / NULLIF(rolling_std, 0)) > 2 THEN '⚠️ ANOMALY' ELSE 'OK' END AS status
FROM stats
ORDER BY dt;
```

---

## 4. Schema Validation

```sql
-- Verify column data types match expectations
SELECT column_name, data_type, character_maximum_length, numeric_precision
FROM information_schema.columns
WHERE table_name = 'yellow_taxi_trips'
ORDER BY ordinal_position;
```

## 📝 Now open `practice/day19_exercises.sql`!

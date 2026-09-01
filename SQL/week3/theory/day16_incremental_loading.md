# Day 16 — Incremental Loading & Change Detection

## 🎯 Learning Goals
Load only new/changed data instead of reprocessing everything — essential for scalable pipelines.

---

## 1. Full Load vs Incremental Load

**Full Load:** Truncate and reload entire table. Simple but slow and expensive.

**Incremental Load:** Only process new or changed records. Requires change detection.

---

## 2. Watermark-Based Incremental Load

The most common pattern: track the last processed timestamp.

```sql
-- Step 1: Create a watermark tracking table
CREATE TABLE pipeline_watermarks (
    pipeline_name TEXT PRIMARY KEY,
    last_processed_at TIMESTAMP,
    last_run_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO pipeline_watermarks VALUES ('yellow_taxi_load', '2023-01-01 00:00:00', NOW());

-- Step 2: Load only new records
DO $$
DECLARE
    v_watermark TIMESTAMP;
    v_max_ts    TIMESTAMP;
BEGIN
    -- Get last processed timestamp
    SELECT last_processed_at INTO v_watermark
    FROM pipeline_watermarks
    WHERE pipeline_name = 'yellow_taxi_load';

    -- Process new records only
    INSERT INTO fct_trips_incremental
    SELECT *, NOW() AS _loaded_at
    FROM yellow_taxi_trips
    WHERE pickup_datetime > v_watermark;

    -- Get new max timestamp
    SELECT MAX(pickup_datetime) INTO v_max_ts FROM yellow_taxi_trips;

    -- Update watermark
    UPDATE pipeline_watermarks
    SET last_processed_at = v_max_ts, last_run_at = NOW()
    WHERE pipeline_name = 'yellow_taxi_load';
END;
$$;
```

---

## 3. Change Data Capture (CDC) Pattern

Detect what changed between two snapshots:

```sql
-- Find NEW records (in new snapshot but not old)
SELECT 'INSERT' AS change_type, n.*
FROM new_snapshot n
LEFT JOIN old_snapshot o ON n.trip_id = o.trip_id
WHERE o.trip_id IS NULL

UNION ALL

-- Find DELETED records
SELECT 'DELETE', o.*
FROM old_snapshot o
LEFT JOIN new_snapshot n ON o.trip_id = n.trip_id
WHERE n.trip_id IS NULL

UNION ALL

-- Find UPDATED records (same key, different values)
SELECT 'UPDATE', n.*
FROM new_snapshot n
INNER JOIN old_snapshot o ON n.trip_id = o.trip_id
WHERE n.fare_amount <> o.fare_amount
   OR n.total_amount <> o.total_amount;
```

---

## 4. Partition-Based Incremental (BigQuery/Snowflake Pattern)

```sql
-- Process only the partition for today
INSERT INTO fct_daily_trips PARTITION (trip_date = CURRENT_DATE)
SELECT ...
FROM stg_trips
WHERE trip_date = CURRENT_DATE;
```

---

## 5. Late-Arriving Data

Real data pipelines must handle late arrivals:

```sql
-- Reprocess the last 3 days to catch late-arriving records
BEGIN;
DELETE FROM fct_daily_zone_revenue
WHERE trip_date >= CURRENT_DATE - INTERVAL '3 days';

INSERT INTO fct_daily_zone_revenue
SELECT ...
FROM yellow_taxi_trips
WHERE pickup_datetime >= CURRENT_DATE - INTERVAL '3 days';
COMMIT;
```

## 📝 Now open `practice/day16_exercises.sql`!

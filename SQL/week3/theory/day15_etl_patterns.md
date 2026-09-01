# Day 15 — ETL vs ELT Patterns in SQL

## 🎯 Learning Goals
Write SQL that implements the core Extract-Transform-Load and Extract-Load-Transform patterns used in modern data pipelines.

---

## 1. ETL vs ELT

**ETL (Extract → Transform → Load):** Transform data *before* loading into the warehouse. Traditional approach.

**ELT (Extract → Load → Transform):** Load raw data first, transform *inside* the warehouse with SQL. Modern approach (BigQuery, Snowflake, dbt).

Most modern DE work is ELT — you'll write the T in SQL.

---

## 2. The Staging → Intermediate → Final Layer Pattern

```sql
-- Layer 1: STAGING — raw data, minimal transformation
CREATE TABLE stg_yellow_taxi AS
SELECT
    *,
    NOW() AS _loaded_at,        -- pipeline metadata
    'yellow_taxi_2023_01' AS _source_file
FROM raw_yellow_taxi_jan;

-- Layer 2: INTERMEDIATE — cleaned and conformed
CREATE TABLE int_trips AS
WITH validated AS (
    SELECT *
    FROM stg_yellow_taxi
    WHERE fare_amount BETWEEN 2.50 AND 1000
      AND trip_distance BETWEEN 0.01 AND 200
      AND passenger_count BETWEEN 1 AND 9
      AND dropoff_datetime > pickup_datetime
),
enriched AS (
    SELECT
        v.*,
        pu.borough AS pickup_borough, pu.zone AS pickup_zone,
        do.borough AS dropoff_borough, do.zone AS dropoff_zone,
        EXTRACT(EPOCH FROM (dropoff_datetime - pickup_datetime)) / 60 AS trip_minutes
    FROM validated v
    LEFT JOIN taxi_zones pu ON v.pickup_location_id = pu.location_id
    LEFT JOIN taxi_zones do ON v.dropoff_location_id = do.location_id
)
SELECT * FROM enriched;

-- Layer 3: FINAL — business-level aggregates
CREATE TABLE fct_daily_zone_revenue AS
SELECT
    DATE_TRUNC('day', pickup_datetime)::DATE AS trip_date,
    pickup_location_id, pickup_zone, pickup_borough,
    COUNT(*) AS trips,
    ROUND(SUM(fare_amount), 2) AS total_fare,
    ROUND(SUM(tip_amount), 2) AS total_tips,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(trip_minutes), 1) AS avg_trip_minutes
FROM int_trips
GROUP BY 1, 2, 3, 4;
```

---

## 3. Idempotent Pipelines

An idempotent pipeline produces the same result whether run once or 10 times. Critical for reliability.

```sql
-- TRUNCATE + INSERT (simple, fully idempotent)
TRUNCATE TABLE fct_daily_zone_revenue;
INSERT INTO fct_daily_zone_revenue ...;

-- DELETE + INSERT for specific partition (safer for production)
BEGIN;
DELETE FROM fct_daily_zone_revenue WHERE trip_date = '2023-01-15';
INSERT INTO fct_daily_zone_revenue
SELECT ... FROM int_trips WHERE pickup_datetime::DATE = '2023-01-15';
COMMIT;

-- UPSERT (most flexible)
INSERT INTO fct_daily_zone_revenue (trip_date, pickup_location_id, trips, revenue)
SELECT ... 
ON CONFLICT (trip_date, pickup_location_id)
DO UPDATE SET trips = EXCLUDED.trips, revenue = EXCLUDED.revenue;
```

---

## 4. Data Lineage in SQL

Always tag records with pipeline metadata:

```sql
SELECT
    trip_id,
    fare_amount,
    'yellow_taxi'       AS _source,
    '2023-01-01'::DATE  AS _source_date,
    NOW()               AS _transformed_at,
    'v1.2.0'            AS _pipeline_version
FROM yellow_taxi_trips;
```

## 📝 Now open `practice/day15_exercises.sql`!

# Day 24 — dbt Patterns (Models, Tests, Macros)

## 🎯 Learning Goals
Understand how dbt structures SQL for maintainable, testable data pipelines.

---

## 1. What Is dbt?

dbt (data build tool) lets you write SELECT statements as "models", handles dependency ordering, testing, and documentation. The T in ELT.

**dbt = your SQL SELECTs + Jinja templating + dependency graph + testing**

---

## 2. Model Layers

```sql
-- models/staging/stg_yellow_taxi_trips.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'yellow_taxi_trips') }}
),
renamed AS (
    SELECT
        vendor_id,
        tpep_pickup_datetime  AS pickup_datetime,
        tpep_dropoff_datetime AS dropoff_datetime,
        passenger_count,
        trip_distance,
        PULocationID          AS pickup_location_id,
        DOLocationID          AS dropoff_location_id,
        payment_type,
        fare_amount,
        tip_amount,
        total_amount
    FROM source
    WHERE fare_amount > 0
)
SELECT * FROM renamed
```

```sql
-- models/marts/fct_daily_revenue.sql
{{ config(
    materialized='incremental',
    unique_key=['trip_date', 'pickup_location_id']
) }}

SELECT
    DATE_TRUNC('day', pickup_datetime)::DATE AS trip_date,
    pickup_location_id,
    COUNT(*) AS trips,
    ROUND(SUM(total_amount), 2) AS revenue
FROM {{ ref('stg_yellow_taxi_trips') }}
{% if is_incremental() %}
WHERE pickup_datetime >= (SELECT MAX(trip_date) - INTERVAL '3 days' FROM {{ this }})
{% endif %}
GROUP BY 1, 2
```

---

## 3. dbt Tests (schema.yml)

```yaml
models:
  - name: stg_yellow_taxi_trips
    columns:
      - name: pickup_datetime
        tests: [not_null]
      - name: fare_amount
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000
      - name: payment_type
        tests:
          - accepted_values:
              values: [1, 2, 3, 4, 5, 6]
```

---

## 4. dbt Macros

```sql
-- macros/classify_fare.sql
{% macro classify_fare(col) %}
CASE
    WHEN {{ col }} < 8  THEN 'Short'
    WHEN {{ col }} < 25 THEN 'Medium'
    WHEN {{ col }} < 60 THEN 'Long'
    ELSE 'Premium'
END
{% endmacro %}

-- Use in a model:
SELECT fare_amount, {{ classify_fare('fare_amount') }} AS fare_tier
FROM {{ ref('stg_yellow_taxi_trips') }}
```

---

## 5. Incremental Strategy in Pure SQL

Even without dbt, implement the same logic:

```sql
-- The incremental pattern dbt uses under the hood
-- 1. Create new data
WITH new_data AS (
    SELECT trip_date, pickup_location_id, COUNT(*) AS trips, SUM(total_amount) AS revenue
    FROM yellow_taxi_trips
    WHERE pickup_datetime >= CURRENT_DATE - INTERVAL '3 days'  -- lookback window
    GROUP BY 1, 2
)
-- 2. Merge into target
INSERT INTO fct_daily_revenue (trip_date, pickup_location_id, trips, revenue)
SELECT * FROM new_data
ON CONFLICT (trip_date, pickup_location_id)
DO UPDATE SET trips = EXCLUDED.trips, revenue = EXCLUDED.revenue;
```

## 📝 Now open `practice/day24_exercises.sql`!

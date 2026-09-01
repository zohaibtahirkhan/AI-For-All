# Day 22 — BigQuery SQL

## 🎯 Learning Goals
Write BigQuery-specific SQL using the NYC Taxi public dataset (no setup required!).

---

## 1. Accessing the Public Dataset

```sql
-- BigQuery public dataset — reference directly, no download needed
SELECT COUNT(*)
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;
```

---

## 2. Partitioned + Clustered Tables

```sql
-- Create your own partitioned table
CREATE TABLE `my_project.taxi.trips`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, payment_type
AS SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

-- Partition filter = cost control
SELECT COUNT(*), SUM(fare_amount)
FROM `my_project.taxi.trips`
WHERE DATE(pickup_datetime) = '2022-01-15';
```

---

## 3. ARRAY and STRUCT

```sql
-- ARRAY_AGG: collect values into an array
SELECT
    pickup_location_id,
    ARRAY_AGG(DISTINCT payment_type ORDER BY payment_type) AS payment_types_used,
    ARRAY_AGG(fare_amount ORDER BY fare_amount DESC LIMIT 5) AS top_5_fares
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY pickup_location_id;

-- UNNEST: flatten array back to rows
WITH zone_payments AS (
    SELECT pickup_location_id,
           ARRAY_AGG(DISTINCT payment_type) AS ptypes
    FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
    GROUP BY pickup_location_id
)
SELECT pickup_location_id, pt
FROM zone_payments, UNNEST(ptypes) AS pt;
```

---

## 4. Approximate Aggregations

```sql
SELECT
    APPROX_COUNT_DISTINCT(pickup_location_id) AS approx_unique_zones,
    COUNT(DISTINCT pickup_location_id) AS exact_unique_zones,
    APPROX_QUANTILES(fare_amount, 100)[OFFSET(50)] AS median_fare
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;
```

---

## 5. BigQuery vs PostgreSQL Syntax Differences

| Feature | PostgreSQL | BigQuery |
|---------|-----------|---------|
| Date truncation | `DATE_TRUNC('day', col)` | `DATE_TRUNC(col, DAY)` |
| Extract DOW | `EXTRACT(DOW FROM col)` | `EXTRACT(DAYOFWEEK FROM col)` |
| Regex match | `col ~ 'pattern'` | `REGEXP_CONTAINS(col, 'pattern')` |
| String split | `SPLIT_PART(col, ',', 1)` | `SPLIT(col, ',')[SAFE_OFFSET(0)]` |

## 📝 Now open `practice/day22_exercises.sql`!

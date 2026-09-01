# Day 28 — SQL for ML Feature Engineering

## 🎯 Learning Goals
Generate ML-ready feature sets using SQL — the most scalable approach.

---

## 1. Why SQL for Features?

- Scales to billions of rows in your warehouse
- Same SQL runs in training and production serving
- Point-in-time correctness prevents data leakage
- Version-controlled via dbt or git

---

## 2. Feature Engineering for Fare Prediction

```sql
CREATE TABLE ml_trip_features AS
WITH base AS (
    SELECT
        t.trip_id,
        t.fare_amount AS label,

        -- Temporal features
        EXTRACT(HOUR FROM t.pickup_datetime)    AS pickup_hour,
        EXTRACT(DOW FROM t.pickup_datetime)     AS pickup_dow,
        CASE WHEN EXTRACT(DOW FROM t.pickup_datetime) IN (0,6) THEN 1 ELSE 0 END AS is_weekend,

        -- Trip features
        t.trip_distance,
        t.passenger_count,
        t.rate_code_id,

        -- Location features
        t.pickup_location_id,
        t.dropoff_location_id,
        CASE WHEN pu.borough = do.borough THEN 1 ELSE 0 END AS same_borough,
        pu.borough AS pickup_borough
    FROM yellow_taxi_trips t
    LEFT JOIN taxi_zones pu ON t.pickup_location_id = pu.location_id
    LEFT JOIN taxi_zones do ON t.dropoff_location_id = do.location_id
    WHERE t.fare_amount BETWEEN 2.50 AND 500
      AND t.trip_distance BETWEEN 0.1 AND 100
),
zone_history AS (
    -- Historical zone stats (point-in-time safe)
    SELECT pickup_location_id,
           AVG(fare_amount) AS zone_avg_fare,
           STDDEV(fare_amount) AS zone_fare_std,
           COUNT(*) AS zone_trip_count
    FROM yellow_taxi_trips WHERE fare_amount > 0
    GROUP BY pickup_location_id
)
SELECT
    b.*,
    z.zone_avg_fare,
    z.zone_fare_std,
    z.zone_trip_count,
    ROUND((b.label - z.zone_avg_fare) / NULLIF(z.zone_fare_std, 0), 3) AS label_zscore
FROM base b
LEFT JOIN zone_history z USING (pickup_location_id);
```

---

## 3. Avoiding Data Leakage

```sql
-- GOOD: rolling window uses only prior trips (no leakage)
SELECT
    trip_id, pickup_datetime, fare_amount,
    AVG(fare_amount) OVER (
        PARTITION BY pickup_location_id
        ORDER BY pickup_datetime
        ROWS BETWEEN 1000 PRECEDING AND 1 PRECEDING  -- past trips only
    ) AS rolling_zone_avg
FROM yellow_taxi_trips;
```

---

## 4. Target Encoding & One-Hot Encoding

```sql
SELECT
    trip_id,
    -- One-hot encode payment_type
    CASE WHEN payment_type = 1 THEN 1 ELSE 0 END AS is_credit_card,
    CASE WHEN payment_type = 2 THEN 1 ELSE 0 END AS is_cash,
    -- Target encode borough (mean fare per category)
    AVG(fare_amount) OVER (PARTITION BY pickup_borough) AS borough_mean_fare
FROM yellow_taxi_trips;
```

## 📝 Now open `practice/day28_exercises.sql`!

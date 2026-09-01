# Day 21 — Analytical Patterns (Cohort, Funnel, Retention)

## 🎯 Learning Goals
Implement the most common analytical query patterns used in data teams.

---

## 1. Cohort Analysis

Group users/entities by their first event date and track behavior over time.

```sql
-- Cohort: zones grouped by when they first appeared in trip data
WITH first_appearance AS (
    SELECT
        pickup_location_id,
        DATE_TRUNC('month', MIN(pickup_datetime))::DATE AS cohort_month
    FROM yellow_taxi_trips
    GROUP BY pickup_location_id
),
monthly_activity AS (
    SELECT
        t.pickup_location_id,
        DATE_TRUNC('month', t.pickup_datetime)::DATE AS activity_month,
        COUNT(*) AS trips
    FROM yellow_taxi_trips t
    GROUP BY 1, 2
)
SELECT
    f.cohort_month,
    EXTRACT(MONTH FROM AGE(m.activity_month, f.cohort_month)) AS months_since_first,
    COUNT(DISTINCT f.pickup_location_id) AS zones,
    SUM(m.trips) AS total_trips
FROM first_appearance f
INNER JOIN monthly_activity m USING (pickup_location_id)
GROUP BY 1, 2
ORDER BY 1, 2;
```

---

## 2. Retention Analysis

```sql
-- Week-over-week retention: what % of zones active in week N are also active in week N+1?
WITH weekly_zones AS (
    SELECT
        DATE_TRUNC('week', pickup_datetime)::DATE AS week_start,
        pickup_location_id
    FROM yellow_taxi_trips
    GROUP BY 1, 2
)
SELECT
    w1.week_start,
    COUNT(DISTINCT w1.pickup_location_id) AS active_zones,
    COUNT(DISTINCT w2.pickup_location_id) AS retained_next_week,
    ROUND(
        COUNT(DISTINCT w2.pickup_location_id)::NUMERIC /
        NULLIF(COUNT(DISTINCT w1.pickup_location_id), 0) * 100, 1
    ) AS retention_pct
FROM weekly_zones w1
LEFT JOIN weekly_zones w2
    ON w1.pickup_location_id = w2.pickup_location_id
    AND w2.week_start = w1.week_start + INTERVAL '1 week'
GROUP BY w1.week_start
ORDER BY w1.week_start;
```

---

## 3. Funnel Analysis

```sql
-- Fare amount funnel: how many trips reach each price tier?
WITH funnel AS (
    SELECT
        COUNT(*) FILTER (WHERE fare_amount >= 2.50)  AS step_1_any_fare,
        COUNT(*) FILTER (WHERE fare_amount >= 10)    AS step_2_over_10,
        COUNT(*) FILTER (WHERE fare_amount >= 25)    AS step_3_over_25,
        COUNT(*) FILTER (WHERE fare_amount >= 50)    AS step_4_over_50,
        COUNT(*) FILTER (WHERE fare_amount >= 100)   AS step_5_over_100
    FROM yellow_taxi_trips
    WHERE fare_amount > 0
)
SELECT
    'Step 1: Any valid fare' AS funnel_step, step_1_any_fare AS count,
    100.0 AS pct_of_top
FROM funnel
UNION ALL
SELECT 'Step 2: Over $10', step_2_over_10,
    ROUND(step_2_over_10::NUMERIC / step_1_any_fare * 100, 1)
FROM funnel
UNION ALL
SELECT 'Step 3: Over $25', step_3_over_25,
    ROUND(step_3_over_25::NUMERIC / step_1_any_fare * 100, 1)
FROM funnel
-- ... etc
ORDER BY pct_of_top DESC;
```

---

## 4. Period-over-Period Comparison

```sql
-- Compare this week vs last week
WITH weekly AS (
    SELECT
        DATE_TRUNC('week', pickup_datetime)::DATE AS week_start,
        SUM(total_amount) AS revenue, COUNT(*) AS trips
    FROM yellow_taxi_trips GROUP BY 1
)
SELECT
    w.week_start,
    w.trips, w.revenue,
    LAG(w.trips)   OVER (ORDER BY w.week_start) AS prev_week_trips,
    LAG(w.revenue) OVER (ORDER BY w.week_start) AS prev_week_revenue,
    ROUND((w.revenue - LAG(w.revenue) OVER (ORDER BY w.week_start))
          / NULLIF(LAG(w.revenue) OVER (ORDER BY w.week_start), 0) * 100, 1) AS wow_revenue_pct
FROM weekly w ORDER BY w.week_start;
```

## 📝 Week 3 complete! Open `practice/day21_exercises.sql`!

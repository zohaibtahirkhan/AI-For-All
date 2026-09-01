# views_materialized_views — Views & Materialized Views

## 🎯 Learning Goals
Create reusable query abstractions and understand when to materialize.

---

## 1. Regular Views — Saved Queries
```sql
-- Create a view (query stored, not data)
CREATE OR REPLACE VIEW vw_trip_summary AS
SELECT
    DATE_TRUNC('day', pickup_datetime)::DATE AS trip_date,
    z.borough AS pickup_borough,
    COUNT(*) AS trips,
    ROUND(SUM(total_amount), 2) AS revenue
FROM yellow_taxi_trips t
LEFT JOIN taxi_zones z ON t.pickup_location_id = z.location_id
WHERE fare_amount > 0
GROUP BY 1, 2;

-- Query it like a table
SELECT * FROM vw_trip_summary WHERE pickup_borough = 'Manhattan';
```

## 2. Materialized Views — Stored Results
```sql
-- Results are stored physically (like a table)
CREATE MATERIALIZED VIEW mv_zone_daily_stats AS
SELECT
    pickup_location_id,
    DATE_TRUNC('day', pickup_datetime)::DATE AS trip_date,
    COUNT(*) AS trips,
    AVG(fare_amount) AS avg_fare,
    SUM(total_amount) AS revenue
FROM yellow_taxi_trips
GROUP BY 1, 2;

-- Create index on materialized view
CREATE INDEX ON mv_zone_daily_stats(trip_date);

-- Refresh when source data changes
REFRESH MATERIALIZED VIEW mv_zone_daily_stats;
-- REFRESH MATERIALIZED VIEW CONCURRENTLY ...  -- non-blocking refresh
```

## 3. When to Use Which
| Type | Data Stored | Query Speed | Freshness |
|------|------------|-------------|-----------|
| View | No | Slow (re-runs) | Always fresh |
| Materialized View | Yes | Fast (pre-computed) | Stale until refresh |

**DE Rule:** Use materialized views for expensive aggregations that are queried frequently. Refresh on a schedule (e.g., daily).

## 📝 Now open `practice/day13_exercises.sql`!

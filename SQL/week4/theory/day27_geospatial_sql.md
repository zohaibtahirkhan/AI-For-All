# Day 27 — Geospatial SQL

## 🎯 Learning Goals
Query spatial data using PostGIS for location-based analytics.

---

## 1. PostGIS Setup

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add geometry to taxi_zones
ALTER TABLE taxi_zones ADD COLUMN centroid GEOMETRY(POINT, 4326);

-- Manually add approximate centroids for key zones
UPDATE taxi_zones SET centroid = ST_SetSRID(ST_MakePoint(-73.7789, 40.6413), 4326)
WHERE zone = 'JFK Airport';

UPDATE taxi_zones SET centroid = ST_SetSRID(ST_MakePoint(-73.9857, 40.7580), 4326)
WHERE zone = 'Times Sq/Theatre District';
```

---

## 2. Common Spatial Operations

```sql
-- Distance between two zones (in km)
SELECT
    a.zone AS from_zone, b.zone AS to_zone,
    ROUND(
        ST_Distance(
            ST_Transform(a.centroid, 32618),
            ST_Transform(b.centroid, 32618)
        ) / 1000, 2
    ) AS distance_km
FROM taxi_zones a, taxi_zones b
WHERE a.zone = 'JFK Airport' AND b.zone != a.zone
ORDER BY distance_km
LIMIT 10;

-- Find zones within N km of a point
SELECT zone, borough
FROM taxi_zones
WHERE ST_DWithin(
    ST_Transform(centroid, 32618),
    ST_Transform(ST_GeomFromText('POINT(-73.9857 40.7580)', 4326), 32618),
    3000  -- 3 km
);
```

---

## 3. Revenue Heatmap Query

```sql
SELECT
    z.zone, z.borough,
    COUNT(t.trip_id) AS pickups,
    ROUND(SUM(t.total_amount), 2) AS revenue,
    ST_AsGeoJSON(z.centroid) AS geojson_point
FROM taxi_zones z
LEFT JOIN yellow_taxi_trips t ON z.location_id = t.pickup_location_id
GROUP BY z.location_id, z.zone, z.borough, z.centroid
ORDER BY revenue DESC NULLS LAST;
```

## 📝 Now open `practice/day27_exercises.sql`!

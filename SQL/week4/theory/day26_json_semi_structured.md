# Day 26 — JSON & Semi-Structured Data

## 🎯 Learning Goals
Query and transform JSON data — increasingly common in modern data pipelines.

---

## 1. JSON vs JSONB

Use JSONB for queryable data (binary format, indexed, faster).

```sql
CREATE TABLE trip_metadata (
    trip_id INTEGER PRIMARY KEY,
    metadata JSONB
);

INSERT INTO trip_metadata VALUES
(1, '{"source":"app","device":"iOS","surge":1.5,"tags":["airport","premium"]}'),
(2, '{"source":"web","device":null,"surge":1.0,"tags":["standard"]}');
```

---

## 2. Querying JSONB

```sql
SELECT
    trip_id,
    metadata ->> 'source'     AS source,         -- text output
    metadata -> 'surge'        AS surge_json,     -- JSONB output
    (metadata ->> 'surge')::NUMERIC AS surge_num, -- cast to type
    metadata -> 'tags' ->> 0   AS first_tag,      -- array element
    jsonb_array_length(metadata -> 'tags') AS tag_count
FROM trip_metadata;

-- Filter on JSON value
SELECT * FROM trip_metadata WHERE metadata ->> 'source' = 'app';

-- Key existence
SELECT * FROM trip_metadata WHERE metadata ? 'surge';

-- Value in array
SELECT * FROM trip_metadata WHERE metadata -> 'tags' ? 'airport';
```

---

## 3. GIN Index for JSONB

```sql
CREATE INDEX idx_metadata_gin ON trip_metadata USING GIN(metadata);
-- Now JSON queries use the index
```

---

## 4. Expanding JSON

```sql
-- Expand keys to rows
SELECT trip_id, key, value
FROM trip_metadata, jsonb_each(metadata);

-- Expand array to rows
SELECT trip_id, tag
FROM trip_metadata, jsonb_array_elements_text(metadata -> 'tags') AS tag;

-- Extract known fields as typed columns
SELECT * FROM trip_metadata,
jsonb_to_record(metadata) AS t(source TEXT, surge NUMERIC);
```

---

## 5. Building JSON Output

```sql
-- Build a JSON summary per zone
SELECT
    pickup_location_id,
    jsonb_build_object(
        'zone_id', pickup_location_id,
        'trips', COUNT(*),
        'revenue', ROUND(SUM(total_amount), 2),
        'avg_fare', ROUND(AVG(fare_amount), 2)
    ) AS stats
FROM yellow_taxi_trips WHERE fare_amount > 0
GROUP BY pickup_location_id LIMIT 10;
```

## 📝 Now open `practice/day26_exercises.sql`!

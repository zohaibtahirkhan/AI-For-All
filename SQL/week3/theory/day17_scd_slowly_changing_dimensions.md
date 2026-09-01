# Day 17 — Slowly Changing Dimensions (SCD)

## 🎯 Learning Goals
Implement dimension table history tracking — a fundamental data warehousing skill.

---

## 1. What Are SCDs?

Dimension tables (zones, vendors, payment types) occasionally change. SCDs define *how* to handle those changes.

**Our example:** The taxi zone service_zone classification changes over time.

---

## 2. SCD Type 1 — Overwrite (No History)

Simply update the existing record. History is lost.

```sql
-- Zone service classification changed for location_id 161
UPDATE taxi_zones
SET service_zone = 'Boro Zone'  -- was 'Yellow Zone'
WHERE location_id = 161;
```

---

## 3. SCD Type 2 — Full History (Most Common in DE)

Keep old record, add new record with validity dates.

```sql
-- SCD Type 2 table structure
CREATE TABLE taxi_zones_scd2 (
    surrogate_key    SERIAL PRIMARY KEY,
    location_id      INTEGER NOT NULL,
    borough          VARCHAR(50),
    zone             VARCHAR(100),
    service_zone     VARCHAR(50),
    valid_from       DATE NOT NULL,
    valid_to         DATE,              -- NULL = current record
    is_current       BOOLEAN DEFAULT TRUE
);

-- Implement SCD Type 2 update in SQL
-- Step 1: Close the current record
UPDATE taxi_zones_scd2
SET valid_to    = CURRENT_DATE - 1,
    is_current  = FALSE
WHERE location_id = 161
  AND is_current = TRUE;

-- Step 2: Insert new version
INSERT INTO taxi_zones_scd2 (location_id, borough, zone, service_zone, valid_from, is_current)
VALUES (161, 'Manhattan', 'Midtown Center', 'Boro Zone', CURRENT_DATE, TRUE);
```

### Query SCD Type 2 — Point-in-Time Lookup

```sql
-- What was the service_zone on January 1, 2023?
SELECT location_id, zone, service_zone
FROM taxi_zones_scd2
WHERE location_id = 161
  AND valid_from <= '2023-01-01'
  AND (valid_to IS NULL OR valid_to >= '2023-01-01');

-- Join trips to their historical zone classifications
SELECT t.trip_id, t.pickup_datetime, z.zone, z.service_zone
FROM yellow_taxi_trips t
INNER JOIN taxi_zones_scd2 z
    ON t.pickup_location_id = z.location_id
    AND t.pickup_datetime::DATE BETWEEN z.valid_from AND COALESCE(z.valid_to, '9999-12-31');
```

### Bulk SCD Type 2 — MERGE Pattern

```sql
-- Upsert with SCD Type 2 logic using CTEs
WITH changes AS (
    SELECT
        s.location_id, s.borough, s.zone, s.service_zone,
        t.surrogate_key AS existing_key,
        CASE
            WHEN t.surrogate_key IS NULL THEN 'INSERT'
            WHEN t.service_zone <> s.service_zone THEN 'UPDATE'
            ELSE 'NO_CHANGE'
        END AS action
    FROM staging_zones s
    LEFT JOIN taxi_zones_scd2 t
        ON s.location_id = t.location_id AND t.is_current = TRUE
)
-- Close old records
UPDATE taxi_zones_scd2
SET valid_to = CURRENT_DATE - 1, is_current = FALSE
WHERE surrogate_key IN (SELECT existing_key FROM changes WHERE action = 'UPDATE');
-- Insert new records
INSERT INTO taxi_zones_scd2 (location_id, borough, zone, service_zone, valid_from)
SELECT location_id, borough, zone, service_zone, CURRENT_DATE
FROM changes WHERE action IN ('INSERT', 'UPDATE');
```

---

## 4. SCD Type 3 — Previous Value Column

Store only the previous value, not full history. Simple but limited.

```sql
CREATE TABLE taxi_zones_scd3 (
    location_id          INTEGER PRIMARY KEY,
    current_service_zone VARCHAR(50),
    prev_service_zone    VARCHAR(50),   -- stores one version of history
    changed_at           TIMESTAMP
);
```

---

## Key Takeaways
- SCD1: Overwrite (simplest, no history)
- SCD2: New row per change with validity dates (most useful in DE)
- SCD3: Add "previous" column (limited history)
- Always join through surrogate key, not natural key, in SCD2 environments

## 📝 Now open `practice/day17_exercises.sql`!

# Day 5 — String & Date Functions

## 🎯 Learning Goals
Manipulate strings and dates — two of the messiest data types in real pipelines.

---

## 1. String Functions

### Case & Trimming
```sql
SELECT
    UPPER(borough)          AS upper_borough,   -- MANHATTAN
    LOWER(borough)          AS lower_borough,   -- manhattan
    INITCAP(borough)        AS title_borough,   -- Manhattan
    TRIM('  NYC  ')         AS trimmed,         -- 'NYC'
    LTRIM('  NYC')          AS left_trim,       -- 'NYC'
    RTRIM('NYC  ')          AS right_trim       -- 'NYC'
FROM taxi_zones;
```

### Length & Substring
```sql
SELECT
    zone,
    LENGTH(zone)                AS zone_length,
    SUBSTRING(zone, 1, 5)       AS first_5_chars,   -- or LEFT(zone, 5)
    RIGHT(zone, 3)              AS last_3_chars,
    POSITION('/' IN zone)       AS slash_position    -- 0 if not found
FROM taxi_zones;
```

### Concatenation
```sql
SELECT
    zone || ', ' || borough     AS zone_borough,          -- PostgreSQL
    CONCAT(zone, ', ', borough) AS zone_borough_concat,   -- Standard SQL
    borough || ' (' || service_zone || ')'  AS label
FROM taxi_zones;
```

### Replace & Split
```sql
SELECT
    REPLACE(zone, '/', '-')                         AS zone_clean,
    SPLIT_PART(zone, '/', 1)                        AS zone_part1,
    SPLIT_PART(zone, '/', 2)                        AS zone_part2,
    REGEXP_REPLACE(zone, '[^a-zA-Z ]', '', 'g')    AS letters_only
FROM taxi_zones;
```

### Pattern Matching
```sql
-- LIKE and ILIKE
SELECT * FROM taxi_zones WHERE zone ILIKE '%airport%';

-- Regular expressions (PostgreSQL)
SELECT * FROM taxi_zones WHERE zone ~ '^[0-9]';      -- starts with digit
SELECT * FROM taxi_zones WHERE zone !~ '[^a-zA-Z ]'; -- only letters/spaces
```

---

## 2. Date & Timestamp Functions

This is where DE work gets intensive. NYC Taxi timestamps are rich — use them!

### Current Time
```sql
SELECT
    NOW()                       AS current_timestamp,
    CURRENT_DATE                AS today,
    CURRENT_TIME                AS now_time,
    CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AS utc_now;
```

### Extracting Parts
```sql
SELECT
    pickup_datetime,
    EXTRACT(YEAR  FROM pickup_datetime)   AS year,
    EXTRACT(MONTH FROM pickup_datetime)   AS month,
    EXTRACT(DAY   FROM pickup_datetime)   AS day,
    EXTRACT(HOUR  FROM pickup_datetime)   AS hour,
    EXTRACT(MINUTE FROM pickup_datetime)  AS minute,
    EXTRACT(DOW   FROM pickup_datetime)   AS day_of_week,  -- 0=Sun, 6=Sat
    EXTRACT(DOY   FROM pickup_datetime)   AS day_of_year,
    EXTRACT(WEEK  FROM pickup_datetime)   AS week_number
FROM yellow_taxi_trips
LIMIT 10;
```

### Truncation (crucial for grouping)
```sql
SELECT
    DATE_TRUNC('year',   pickup_datetime)  AS year_start,
    DATE_TRUNC('month',  pickup_datetime)  AS month_start,
    DATE_TRUNC('week',   pickup_datetime)  AS week_start,
    DATE_TRUNC('day',    pickup_datetime)  AS day_start,
    DATE_TRUNC('hour',   pickup_datetime)  AS hour_start
FROM yellow_taxi_trips
LIMIT 5;

-- Group by week:
SELECT
    DATE_TRUNC('week', pickup_datetime) AS week_start,
    COUNT(*) AS trips
FROM yellow_taxi_trips
GROUP BY 1
ORDER BY 1;
```

### Arithmetic & Duration
```sql
SELECT
    pickup_datetime,
    dropoff_datetime,
    dropoff_datetime - pickup_datetime                     AS duration_interval,
    EXTRACT(EPOCH FROM (dropoff_datetime - pickup_datetime)) AS duration_seconds,
    EXTRACT(EPOCH FROM (dropoff_datetime - pickup_datetime)) / 60 AS duration_minutes,
    
    -- Date arithmetic
    pickup_datetime + INTERVAL '1 hour'                    AS one_hour_later,
    pickup_datetime::DATE + 7                              AS one_week_later
FROM yellow_taxi_trips
LIMIT 10;
```

### Formatting
```sql
SELECT
    TO_CHAR(pickup_datetime, 'YYYY-MM-DD')          AS date_str,
    TO_CHAR(pickup_datetime, 'Day, DD Month YYYY')  AS long_date,
    TO_CHAR(pickup_datetime, 'HH24:MI:SS')          AS time_str,
    TO_CHAR(fare_amount, 'FM$999,990.00')           AS fare_formatted
FROM yellow_taxi_trips
LIMIT 5;
```

### Parsing Strings to Dates
```sql
SELECT TO_DATE('2023-01-15', 'YYYY-MM-DD') AS parsed_date;
SELECT TO_TIMESTAMP('2023-01-15 14:30:00', 'YYYY-MM-DD HH24:MI:SS');
```

---

## 3. Common DE Patterns

### Weekend vs Weekday
```sql
SELECT
    CASE 
        WHEN EXTRACT(DOW FROM pickup_datetime) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS trips,
    AVG(fare_amount) AS avg_fare
FROM yellow_taxi_trips
GROUP BY day_type;
```

### Time Buckets (Rush hours)
```sql
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 7 AND 9 THEN 'AM Rush'
        WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 16 AND 19 THEN 'PM Rush'
        WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 22 AND 23 
             OR EXTRACT(HOUR FROM pickup_datetime) BETWEEN 0 AND 4 THEN 'Late Night'
        ELSE 'Off-Peak'
    END AS time_period,
    COUNT(*) AS trips
FROM yellow_taxi_trips
GROUP BY time_period
ORDER BY trips DESC;
```

### Incremental Load Filter (DE pipeline pattern)
```sql
-- Only process records from the last completed hour
SELECT *
FROM yellow_taxi_trips
WHERE pickup_datetime >= DATE_TRUNC('hour', NOW() - INTERVAL '1 hour')
  AND pickup_datetime <  DATE_TRUNC('hour', NOW());
```

---

## Key Takeaways
- `DATE_TRUNC` for grouping by time period; `EXTRACT` for getting a single component
- String functions: `UPPER/LOWER`, `TRIM`, `SUBSTRING`, `REPLACE`, `SPLIT_PART`
- Duration = `dropoff - pickup`; convert to seconds with `EXTRACT(EPOCH FROM ...)`
- `TO_CHAR` for formatting output; `TO_DATE`/`TO_TIMESTAMP` for parsing strings
- Weekend/weekday classification uses `EXTRACT(DOW ...)` = 0 or 6

## 📝 Now open `practice/day05_exercises.sql`!

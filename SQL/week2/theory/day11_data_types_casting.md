# data_types_casting — Data Types & Casting

## 🎯 Learning Goals
Handle type mismatches and casting safely in pipelines.

---

## 1. Core PostgreSQL Data Types
```sql
-- Numeric
INTEGER, BIGINT, NUMERIC(precision, scale), FLOAT, DOUBLE PRECISION

-- Text
VARCHAR(n), TEXT, CHAR(n)

-- Date/Time
DATE, TIME, TIMESTAMP, TIMESTAMPTZ (timestamp with timezone), INTERVAL

-- Other
BOOLEAN, UUID, JSONB, ARRAY
```

## 2. Explicit Casting
```sql
-- Two syntax styles:
SELECT '2023-01-15'::DATE;                    -- PostgreSQL style
SELECT CAST('2023-01-15' AS DATE);            -- Standard SQL

-- Common casts in taxi data:
SELECT 
    fare_amount::INTEGER,                      -- truncates decimal
    pickup_datetime::DATE,                     -- strips time
    pickup_location_id::TEXT,                 -- number to string
    '100.50'::NUMERIC,                        -- string to number
    EXTRACT(EPOCH FROM pickup_datetime)::BIGINT AS unix_ts
FROM yellow_taxi_trips LIMIT 5;
```

## 3. Implicit Casting Traps
```sql
-- Type mismatch silently changes behavior:
WHERE pickup_location_id = '161'    -- OK, PostgreSQL casts '161' to integer
WHERE pickup_location_id = '161.0'  -- May fail or produce unexpected results

-- Safe pattern: always cast explicitly in pipelines
WHERE pickup_location_id = CAST('161' AS INTEGER)
```

## 4. Numeric Precision
```sql
-- FLOAT has rounding errors — never use for money!
SELECT 0.1::FLOAT + 0.2::FLOAT;   -- 0.30000000000000004
SELECT 0.1::NUMERIC + 0.2::NUMERIC; -- 0.3  ✓

-- Always use NUMERIC for financial data
ALTER TABLE yellow_taxi_trips ALTER COLUMN fare_amount TYPE NUMERIC(10,2);
```

## 📝 Now open `practice/day11_exercises.sql`!

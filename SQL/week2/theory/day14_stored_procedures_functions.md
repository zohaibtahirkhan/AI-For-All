# stored_procedures_functions — Stored Procedures & User-Defined Functions

## 🎯 Learning Goals
Encapsulate reusable logic in the database for pipeline operations.

---

## 1. User-Defined Functions (UDFs)
```sql
-- Function: calculate tip percentage safely
CREATE OR REPLACE FUNCTION tip_percentage(tip NUMERIC, fare NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    IF fare IS NULL OR fare = 0 THEN
        RETURN NULL;
    END IF;
    RETURN ROUND(tip / fare * 100, 2);
END;
$$ LANGUAGE plpgsql;

-- Use it:
SELECT tip_percentage(tip_amount, fare_amount) AS tip_pct
FROM yellow_taxi_trips
WHERE payment_type = 1;
```

## 2. Stored Procedures (PostgreSQL 11+)
```sql
CREATE OR REPLACE PROCEDURE refresh_daily_stats(target_date DATE)
LANGUAGE plpgsql AS $$
BEGIN
    -- Delete existing data for the date
    DELETE FROM daily_zone_summary WHERE trip_date = target_date;
    
    -- Insert fresh aggregation
    INSERT INTO daily_zone_summary (zone_id, trip_date, trips, revenue)
    SELECT 
        pickup_location_id,
        target_date,
        COUNT(*),
        SUM(total_amount)
    FROM yellow_taxi_trips
    WHERE pickup_datetime::DATE = target_date
    GROUP BY pickup_location_id;
    
    COMMIT;
END;
$$;

-- Call it:
CALL refresh_daily_stats('2023-01-15'::DATE);
```

## 3. SQL Functions (Simpler)
```sql
CREATE OR REPLACE FUNCTION classify_fare(fare NUMERIC)
RETURNS TEXT AS $$
    SELECT CASE
        WHEN fare < 8  THEN 'Short'
        WHEN fare < 25 THEN 'Medium'
        WHEN fare < 60 THEN 'Long'
        ELSE 'Premium'
    END;
$$ LANGUAGE SQL IMMUTABLE;
```

## 📝 Now open `practice/day14_exercises.sql`!

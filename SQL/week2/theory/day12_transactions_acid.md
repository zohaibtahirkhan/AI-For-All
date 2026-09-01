# transactions_acid — Transactions & ACID

## 🎯 Learning Goals
Write safe, atomic SQL operations and understand isolation levels.

---

## 1. ACID Properties
- **Atomicity**: All or nothing — if any step fails, all roll back
- **Consistency**: DB moves from valid state to valid state
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed data survives crashes

## 2. Transaction Syntax
```sql
BEGIN;  -- or START TRANSACTION

INSERT INTO yellow_taxi_trips (vendor_id, pickup_datetime, fare_amount) 
VALUES (1, '2023-01-15 10:00:00', 25.50);

UPDATE some_summary_table 
SET total_trips = total_trips + 1 
WHERE date = '2023-01-15';

COMMIT;    -- saves both changes atomically
-- or ROLLBACK;  -- undoes everything since BEGIN
```

## 3. Savepoints
```sql
BEGIN;
INSERT INTO table_a VALUES (1);
SAVEPOINT sp1;
INSERT INTO table_b VALUES (2);
-- Oops, table_b insert failed logic
ROLLBACK TO SAVEPOINT sp1;   -- undo table_b insert only
COMMIT;  -- keeps table_a insert
```

## 4. Isolation Levels
```sql
-- READ COMMITTED (default): see committed data at time of each statement
-- REPEATABLE READ: snapshot at start of transaction
-- SERIALIZABLE: full isolation, slowest

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN;
-- ...
COMMIT;
```

## 5. UPSERT (INSERT or UPDATE)
```sql
-- Critical pattern for idempotent pipelines
INSERT INTO daily_zone_summary (zone_id, trip_date, trip_count, revenue)
VALUES (161, '2023-01-15', 500, 12500.00)
ON CONFLICT (zone_id, trip_date)  
DO UPDATE SET
    trip_count = EXCLUDED.trip_count,
    revenue = EXCLUDED.revenue,
    updated_at = NOW();
```

## 📝 Now open `practice/day12_exercises.sql`!

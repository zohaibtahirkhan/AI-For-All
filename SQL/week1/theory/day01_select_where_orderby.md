# Day 1 — SELECT, WHERE, ORDER BY

## 🎯 Learning Goals
By the end of today, you can write queries that retrieve, filter, and sort data from a single table.

---

## 1. The SELECT Statement

`SELECT` is the entry point to every data retrieval operation. It tells the database *what* to return.

### Basic Syntax
```sql
SELECT column1, column2, ...
FROM table_name;
```

### Selecting All Columns
```sql
SELECT * FROM yellow_taxi_trips;
```
> ⚠️ **DE Note:** Never use `SELECT *` in production pipelines. Always name your columns explicitly — schemas change, and `*` can break downstream jobs silently.

### Selecting Specific Columns
```sql
SELECT 
    pickup_datetime,
    dropoff_datetime,
    fare_amount,
    tip_amount,
    total_amount
FROM yellow_taxi_trips;
```

### Column Aliases
```sql
SELECT 
    pickup_datetime  AS pickup,
    fare_amount      AS fare,
    tip_amount       AS tip,
    fare_amount + tip_amount AS fare_plus_tip   -- Derived column
FROM yellow_taxi_trips;
```

### Literal Values and Expressions
```sql
SELECT 
    trip_id,
    'NYC Taxi'                          AS source,
    fare_amount * 1.1                   AS fare_with_markup,
    ROUND(trip_distance, 1)             AS distance_rounded
FROM yellow_taxi_trips;
```

---

## 2. The WHERE Clause

`WHERE` filters rows — only rows that satisfy the condition are returned.

### Comparison Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=`  | Equal | `payment_type = 1` |
| `<>` or `!=` | Not equal | `payment_type <> 2` |
| `>`  | Greater than | `fare_amount > 50` |
| `<`  | Less than | `trip_distance < 1` |
| `>=` | Greater or equal | `passenger_count >= 3` |
| `<=` | Less or equal | `total_amount <= 100` |

```sql
-- Trips with fare over $50
SELECT pickup_datetime, dropoff_datetime, fare_amount
FROM yellow_taxi_trips
WHERE fare_amount > 50;
```

### Logical Operators: AND, OR, NOT

```sql
-- Credit card payments AND fare over $20
SELECT *
FROM yellow_taxi_trips
WHERE payment_type = 1
  AND fare_amount > 20;

-- Cash OR dispute payments
SELECT *
FROM yellow_taxi_trips
WHERE payment_type = 2
   OR payment_type = 4;

-- Not cash payments
SELECT *
FROM yellow_taxi_trips
WHERE NOT payment_type = 2;
```

> ⚠️ **Operator Precedence:** `AND` binds tighter than `OR`. Use parentheses to be explicit:
```sql
-- BAD — ambiguous intent
WHERE payment_type = 1 OR payment_type = 2 AND fare_amount > 20

-- GOOD — clear intent
WHERE (payment_type = 1 OR payment_type = 2) AND fare_amount > 20
```

### IN and NOT IN

```sql
-- Multiple values elegantly
SELECT *
FROM yellow_taxi_trips
WHERE payment_type IN (1, 2);          -- Credit card or cash

-- Exclude specific rate codes
SELECT *
FROM yellow_taxi_trips
WHERE rate_code_id NOT IN (2, 3);      -- Not JFK or Newark routes
```

### BETWEEN

```sql
-- Inclusive range filter
SELECT *
FROM yellow_taxi_trips
WHERE fare_amount BETWEEN 10 AND 50;

-- Date range
SELECT *
FROM yellow_taxi_trips
WHERE pickup_datetime BETWEEN '2023-01-01' AND '2023-01-07';
```

### LIKE — Pattern Matching

```sql
-- Starts with pattern (useful for string columns)
SELECT *
FROM taxi_zones
WHERE zone LIKE 'East%';              -- East Village, East Harlem, etc.

-- Contains pattern
SELECT *
FROM taxi_zones
WHERE zone LIKE '%Airport%';

-- Single character wildcard
SELECT *
FROM taxi_zones
WHERE borough LIKE 'Brookl_n';       -- Matches Brooklyn
```

> **ILIKE** (PostgreSQL-specific) is case-insensitive LIKE.

### IS NULL / IS NOT NULL

```sql
-- Rows with missing passenger count
SELECT COUNT(*)
FROM yellow_taxi_trips
WHERE passenger_count IS NULL;

-- Rows with valid data only
SELECT *
FROM yellow_taxi_trips
WHERE passenger_count IS NOT NULL
  AND trip_distance IS NOT NULL;
```

---

## 3. ORDER BY

`ORDER BY` sorts the result set. Without it, row order is *not guaranteed* in SQL.

```sql
-- Single column, ascending (default)
SELECT pickup_datetime, fare_amount
FROM yellow_taxi_trips
ORDER BY fare_amount;

-- Descending
SELECT pickup_datetime, fare_amount
FROM yellow_taxi_trips
ORDER BY fare_amount DESC;

-- Multiple columns: sort by date, then fare within the same date
SELECT pickup_datetime, dropoff_datetime, fare_amount
FROM yellow_taxi_trips
ORDER BY pickup_datetime ASC, fare_amount DESC;
```

### ORDER BY with Column Position (avoid in production)

```sql
-- This works but is brittle — if column order changes, behavior changes
SELECT pickup_datetime, fare_amount
FROM yellow_taxi_trips
ORDER BY 2 DESC;  -- 2nd column = fare_amount
```

---

## 4. LIMIT and OFFSET

```sql
-- Return only first 10 rows (preview)
SELECT *
FROM yellow_taxi_trips
LIMIT 10;

-- Skip first 100 rows, get next 10 (pagination)
SELECT *
FROM yellow_taxi_trips
ORDER BY pickup_datetime
LIMIT 10 OFFSET 100;
```

> ⚠️ **DE Note:** `LIMIT` without `ORDER BY` returns *arbitrary* rows. Always use `ORDER BY` with `LIMIT` for reproducible results.

---

## 5. DISTINCT

Returns only unique values:

```sql
-- All unique payment types in the data
SELECT DISTINCT payment_type
FROM yellow_taxi_trips
ORDER BY payment_type;

-- Unique borough + zone combinations
SELECT DISTINCT borough, zone
FROM taxi_zones
ORDER BY borough, zone;
```

---

## 6. Query Execution Order (Mental Model)

Even though you *write* SQL in this order:
```
SELECT → FROM → WHERE → ORDER BY → LIMIT
```

The database *executes* it in this order:
```
FROM → WHERE → SELECT → ORDER BY → LIMIT
```

This matters because you **cannot** reference a SELECT alias in WHERE:
```sql
-- ❌ WRONG — alias not yet available in WHERE
SELECT fare_amount + tip_amount AS total_earned
FROM yellow_taxi_trips
WHERE total_earned > 30;

-- ✅ CORRECT — repeat the expression
SELECT fare_amount + tip_amount AS total_earned
FROM yellow_taxi_trips
WHERE fare_amount + tip_amount > 30;
```

---

## 7. Comments in SQL

```sql
-- Single-line comment

/*
  Multi-line comment
  Use these to document complex queries
*/

SELECT
    pickup_datetime,
    fare_amount  -- Always check for nulls before using this in calculations
FROM yellow_taxi_trips;
```

---

## Key Takeaways

- `SELECT` specifies columns; use aliases for clarity
- `WHERE` filters rows before they're returned — use `AND`/`OR`/`IN`/`BETWEEN`/`LIKE`/`IS NULL`
- `ORDER BY` guarantees sort order — always pair with `LIMIT`
- `DISTINCT` removes duplicate rows
- Understand execution order to avoid alias-in-WHERE bugs
- Never use `SELECT *` in production pipelines

---

## 📝 Now open `practice/day01_exercises.sql` and complete the exercises!
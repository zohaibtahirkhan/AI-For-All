# SQL for AI and Data Engineers — Quick Reference Cheatsheet

---

## Query Execution Order
```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT
```

---

## Aggregations
```sql
COUNT(*), COUNT(col), COUNT(DISTINCT col)
SUM(col), AVG(col), MIN(col), MAX(col)
STDDEV(col), VARIANCE(col)
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY col)

-- Conditional aggregate
COUNT(*) FILTER (WHERE condition)          -- PostgreSQL
SUM(CASE WHEN condition THEN 1 ELSE 0 END) -- All databases
```

---

## Window Functions
```sql
-- Syntax
func() OVER (PARTITION BY col ORDER BY col ROWS BETWEEN ... AND ...)

-- Ranking
ROW_NUMBER()    -- unique: 1,2,3,4
RANK()          -- gaps on ties: 1,2,2,4
DENSE_RANK()    -- no gaps: 1,2,2,3
NTILE(n)        -- n equal buckets

-- Offset
LAG(col, n)     -- n rows before current
LEAD(col, n)    -- n rows after current
FIRST_VALUE(col)
LAST_VALUE(col)

-- Aggregate windows
SUM(col) OVER (...)
AVG(col) OVER (...)
COUNT(*) OVER (...)

-- Frames
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW   -- running total
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW            -- 7-day window
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING  -- whole partition
```

---

## Date Functions (PostgreSQL)
```sql
DATE_TRUNC('day|week|month|year', ts)
EXTRACT(YEAR|MONTH|DOW|HOUR FROM ts)
ts::DATE                         -- strip time
INTERVAL '1 day'                 -- add/subtract
AGE(ts1, ts2)                   -- interval between
EXTRACT(EPOCH FROM interval)/60  -- interval to minutes
TO_CHAR(ts, 'YYYY-MM-DD')       -- format
TO_DATE('2023-01-15', 'YYYY-MM-DD')  -- parse
generate_series(start, end, step)    -- date/int series
```

---

## NULL Handling
```sql
COALESCE(a, b, c)          -- first non-null
NULLIF(a, b)               -- NULL if a=b (divide-by-zero safe)
IS NULL / IS NOT NULL
IS DISTINCT FROM           -- NULL-safe equality
```

---

## String Functions
```sql
UPPER(s) / LOWER(s) / INITCAP(s)
TRIM(s) / LTRIM(s) / RTRIM(s)
LENGTH(s)
SUBSTRING(s, start, len) / LEFT(s,n) / RIGHT(s,n)
REPLACE(s, from, to)
SPLIT_PART(s, delimiter, n)
s || ' ' || s              -- concatenate
LIKE / ILIKE              -- pattern matching
REGEXP_REPLACE(s, pattern, replacement, flags)
```

---

## CTEs
```sql
WITH cte1 AS (SELECT ...),
     cte2 AS (SELECT ... FROM cte1),
     cte3 AS MATERIALIZED (SELECT ...)  -- cached
SELECT * FROM cte3;

-- Recursive
WITH RECURSIVE cte AS (
    SELECT ... -- anchor
    UNION ALL
    SELECT ... FROM cte WHERE condition  -- recursive
)
SELECT * FROM cte;
```

---

## Data Engineering Patterns

### Idempotent Refresh
```sql
BEGIN;
DELETE FROM target WHERE date = :date;
INSERT INTO target SELECT ... FROM source WHERE date = :date;
COMMIT;
```

### UPSERT
```sql
INSERT INTO t (pk, col1) VALUES (...)
ON CONFLICT (pk)
DO UPDATE SET col1 = EXCLUDED.col1, updated_at = NOW();
```

### SCD Type 2 Update
```sql
-- Close old record
UPDATE dim SET valid_to = CURRENT_DATE - 1, is_current = FALSE
WHERE natural_key = :key AND is_current = TRUE;
-- Insert new version
INSERT INTO dim (natural_key, ..., valid_from, is_current)
VALUES (:key, ..., CURRENT_DATE, TRUE);
```

### Incremental Load Pattern
```sql
-- Get watermark
SELECT last_processed_at FROM watermarks WHERE pipeline = 'name';
-- Process new data
INSERT INTO target SELECT * FROM source WHERE created_at > :watermark;
-- Update watermark
UPDATE watermarks SET last_processed_at = NOW() WHERE pipeline = 'name';
```

### Data Quality Check
```sql
SELECT
    'check_name' AS check,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE condition_fails) AS failed,
    COUNT(*) FILTER (WHERE condition_fails)::NUMERIC / COUNT(*) AS fail_rate
FROM table;
```

---

## Performance Checklist
- [ ] Index on JOIN columns and WHERE filters
- [ ] No functions wrapping indexed columns in WHERE
- [ ] UNION ALL not UNION (unless dedup needed)
- [ ] Filter before joining large tables
- [ ] NUMERIC not FLOAT for money
- [ ] EXPLAIN ANALYZE before optimizing
- [ ] Partition pruning: filter on partition column

---

## Common Interview Patterns
| Problem | Solution |
|---------|---------|
| Top-N per group | ROW_NUMBER() + WHERE rn <= N |
| Running total | SUM() OVER (ORDER BY ... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) |
| Previous period comparison | LAG(col) OVER (ORDER BY date) |
| Fill date gaps | Recursive CTE / generate_series LEFT JOIN |
| Gaps and Islands | date - ROW_NUMBER() as group key |
| Pivot | SUM(CASE WHEN cat = 'a' THEN val END) AS a |
| Median | PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY col) |
| Safe division | col / NULLIF(denominator, 0) |

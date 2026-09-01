# Day 30 — Interview Prep & Common DE SQL Questions

## 🎯 What Data Engineering SQL Interviews Look For

1. **Correctness**: Does the query return the right answer?
2. **Edge cases**: NULL handling, empty sets, duplicates
3. **Performance awareness**: Would this scale to 10B rows?
4. **Readability**: Is it maintainable?
5. **DE-specific patterns**: Can you write idempotent, incremental pipelines?

---

## Top 10 Interview Question Categories

### 1. Window Functions
*"Rank employees by salary within each department"*
```sql
SELECT *, RANK() OVER (PARTITION BY dept ORDER BY salary DESC) AS dept_rank FROM employees;
```

### 2. Running Totals / Moving Averages
*"Calculate 7-day moving average of daily sales"*
```sql
SELECT date, sales, AVG(sales) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ma7
FROM daily_sales;
```

### 3. Top-N per Group
*"Find the top 3 products by revenue in each category"*
```sql
WITH ranked AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn FROM products)
SELECT * FROM ranked WHERE rn <= 3;
```

### 4. Self-Join / Gaps and Islands
*"Find consecutive days where a user was active"*
```sql
WITH islands AS (
    SELECT user_id, activity_date,
           activity_date - ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY activity_date)::INTEGER AS grp
    FROM user_activity
)
SELECT user_id, MIN(activity_date) AS start_date, MAX(activity_date) AS end_date, COUNT(*) AS days
FROM islands GROUP BY user_id, grp HAVING COUNT(*) >= 3;
```

### 5. Incremental/Idempotent Pipeline
*"How would you design a daily refresh of a summary table?"*
```sql
-- DELETE + INSERT in a transaction, or UPSERT
BEGIN;
DELETE FROM daily_summary WHERE summary_date = :target_date;
INSERT INTO daily_summary SELECT ... FROM source WHERE date = :target_date;
COMMIT;
```

### 6. SCD Type 2
*"How do you track changes in a dimension table?"*
→ Explain: close old record (valid_to = today-1), insert new record (valid_from = today)

### 7. Data Quality
*"How do you ensure data quality in a SQL pipeline?"*
→ NULL checks, range validation, referential integrity, volume anomaly detection, automated dq_results logging

### 8. CTEs vs Subqueries
*"When would you use a CTE vs a subquery?"*
→ CTE for readability, reuse, multi-step logic; subquery for simple single-use filters

### 9. EXPLAIN ANALYZE
*"This query is slow. How do you debug it?"*
→ EXPLAIN ANALYZE → look for Seq Scans on large tables → add indexes → verify plan changes

### 10. UNION vs JOIN
*"Difference between UNION and JOIN?"*
→ UNION stacks rows (same columns, different sources); JOIN combines columns (same source, different tables)

---

## Quick Self-Assessment Checklist

Before your interview, make sure you can write from memory:

- [ ] ROW_NUMBER / RANK / DENSE_RANK / NTILE
- [ ] LAG / LEAD with PARTITION BY
- [ ] Running SUM with ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
- [ ] Top-N per group pattern
- [ ] SCD Type 2 update (close + insert)
- [ ] UPSERT with ON CONFLICT
- [ ] DELETE + INSERT in a transaction (idempotent refresh)
- [ ] Data quality check pattern (COUNT FILTER)
- [ ] Recursive CTE for date series
- [ ] EXPLAIN ANALYZE interpretation

---

## Common Gotchas to Mention

1. `NULL != NULL` — use `IS NULL` / `IS NOT NULL`
2. `UNION` deduplicates; `UNION ALL` doesn't — always prefer `UNION ALL` in pipelines
3. `FLOAT` is imprecise for money — always use `NUMERIC`
4. `SELECT *` is bad in production — schema changes break pipelines silently
5. `RANK` has gaps; `DENSE_RANK` doesn't
6. `ORDER BY` without `LIMIT` adds cost with no benefit
7. Functions on indexed columns break index usage

---

## 🎉 Congratulations! You've completed the 30-Day SQL for AI and Data Engineers Roadmap!

You now have:
- 30 days of theory covering every SQL skill a DE needs
- 200+ practice exercises on real NYC Taxi data
- A complete GitHub portfolio project
- Interview prep for SQL-heavy DE roles

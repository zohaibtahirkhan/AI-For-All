# Day 18 — Partitioning & Bucketing

## 🎯 Learning Goals
Design tables that scale to billions of rows using partitioning strategies.

---

## 1. What Is Partitioning?

Partitioning splits a large table into smaller sub-tables (partitions) by a key. Queries that filter on the partition key only read relevant partitions — called **partition pruning**.

---

## 2. Range Partitioning (most common for time-series)

```sql
-- Create a partitioned table by month
CREATE TABLE yellow_taxi_trips_partitioned (
    LIKE yellow_taxi_trips INCLUDING ALL
) PARTITION BY RANGE (pickup_datetime);

-- Create monthly partitions
CREATE TABLE trips_2023_01 PARTITION OF yellow_taxi_trips_partitioned
    FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');

CREATE TABLE trips_2023_02 PARTITION OF yellow_taxi_trips_partitioned
    FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');

-- Queries automatically prune to relevant partition:
SELECT COUNT(*) FROM yellow_taxi_trips_partitioned
WHERE pickup_datetime BETWEEN '2023-01-01' AND '2023-01-31';
-- Only scans trips_2023_01!
```

---

## 3. List Partitioning (by category)

```sql
CREATE TABLE trips_by_borough PARTITION BY LIST (pickup_borough);

CREATE TABLE trips_manhattan PARTITION OF trips_by_borough FOR VALUES IN ('Manhattan');
CREATE TABLE trips_brooklyn  PARTITION OF trips_by_borough FOR VALUES IN ('Brooklyn');
CREATE TABLE trips_queens    PARTITION OF trips_by_borough FOR VALUES IN ('Queens');
CREATE TABLE trips_other     PARTITION OF trips_by_borough DEFAULT;
```

---

## 4. Hash Partitioning (for even distribution)

```sql
-- Distribute by hash of location_id (8 buckets)
CREATE TABLE trips_hash PARTITION BY HASH (pickup_location_id);

CREATE TABLE trips_hash_0 PARTITION OF trips_hash FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE trips_hash_1 PARTITION OF trips_hash FOR VALUES WITH (MODULUS 8, REMAINDER 1);
-- ... through REMAINDER 7
```

---

## 5. Partition Pruning — Verify It Works

```sql
EXPLAIN SELECT * FROM yellow_taxi_trips_partitioned
WHERE pickup_datetime = '2023-01-15';
-- Should show: "Partitions selected: 1 out of N"

-- Partition pruning FAILS when you wrap the column in a function:
EXPLAIN SELECT * FROM yellow_taxi_trips_partitioned
WHERE DATE_TRUNC('day', pickup_datetime) = '2023-01-15';
-- Scans ALL partitions! Use range instead.
```

---

## 6. BigQuery / Snowflake Partitioning (Cloud)

```sql
-- BigQuery: partition by DATE column
CREATE TABLE project.dataset.trips
PARTITION BY DATE(pickup_datetime)
OPTIONS (partition_expiration_days = 365);

-- Cluster by frequently-filtered columns (like indexes)
CREATE TABLE project.dataset.trips
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, payment_type;
```

---

## Key Takeaways
- Range partitioning: best for time-series data (partition by month/year)
- List partitioning: best for categorical data with known values
- Hash partitioning: best for even distribution across nodes
- Always filter on the partition column to get partition pruning
- Never wrap partition column in functions (breaks pruning)

## 📝 Now open `practice/day18_exercises.sql`!

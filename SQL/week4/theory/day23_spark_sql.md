# Day 23 — Spark SQL Essentials

## 🎯 Learning Goals
Write Spark SQL for distributed processing — standard for large-scale data engineering.

---

## 1. Spark SQL Basics

Most ANSI SQL works unchanged in Spark. The key is how you register tables and read data.

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("TaxiAnalysis").getOrCreate()

# Register DataFrame as SQL view
df = spark.read.parquet("yellow_tripdata_2023-01.parquet")
df.createOrReplaceTempView("yellow_taxi_trips")

# Run SQL exactly like PostgreSQL
result = spark.sql("""
    SELECT
        DATE_TRUNC('day', tpep_pickup_datetime) AS trip_date,
        COUNT(*) AS trips,
        ROUND(SUM(total_amount), 2) AS revenue
    FROM yellow_taxi_trips
    GROUP BY 1
    ORDER BY trip_date
""")

result.show(10)
result.write.mode("overwrite").parquet("output/daily_summary/")
```

---

## 2. Spark-Specific SQL Features

```sql
-- Partitioned tables (Hive metastore)
CREATE TABLE trips_partitioned
USING PARQUET
PARTITIONED BY (trip_year INT, trip_month INT)
AS SELECT *, YEAR(pickup_datetime) AS trip_year, MONTH(pickup_datetime) AS trip_month
FROM yellow_taxi_trips;

-- Bucketing for join optimization (reduces shuffle)
CREATE TABLE trips_bucketed
USING PARQUET
CLUSTERED BY (pickup_location_id) INTO 8 BUCKETS
AS SELECT * FROM yellow_taxi_trips;
```

---

## 3. Delta Lake (Modern Lake Format)

Used in Databricks and open-source environments:

```sql
-- Create Delta table
CREATE TABLE trips_delta
USING DELTA
LOCATION 's3://bucket/trips-delta/'
AS SELECT * FROM yellow_taxi_trips;

-- MERGE INTO: upsert for incremental pipelines
MERGE INTO trips_delta AS target
USING staging_trips AS source
ON target.trip_id = source.trip_id
WHEN MATCHED THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;

-- Time travel: read historical snapshot
SELECT COUNT(*) FROM trips_delta TIMESTAMP AS OF '2023-06-01';
SELECT COUNT(*) FROM trips_delta VERSION AS OF 5;
```

---

## 4. Spark SQL Functions

```sql
-- Spark-specific built-ins
SELECT
    to_date(tpep_pickup_datetime) AS trip_date,
    datediff(tpep_dropoff_datetime, tpep_pickup_datetime) AS duration_days,
    collect_list(fare_amount) AS all_fares,              -- array aggregation
    explode(array(1, 2, 3)) AS exploded_val,             -- like UNNEST
    regexp_extract(store_and_fwd_flag, '(Y|N)', 1) AS flag
FROM yellow_taxi_trips;
```

## 📝 Now open `practice/day23_exercises.sql`!

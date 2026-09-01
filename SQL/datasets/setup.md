# 🗄️ Dataset Setup — NYC Taxi Data

This guide walks you through loading the NYC Taxi dataset into **PostgreSQL** (local) and **BigQuery** (cloud).

---

## Option A: PostgreSQL (Recommended for Weeks 1–3)

### Step 1: Install PostgreSQL

```bash
# macOS
brew install postgresql@15
brew services start postgresql@15

# Ubuntu/Debian
sudo apt update && sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql

# Windows — use installer at https://www.postgresql.org/download/windows/
```

### Step 2: Create the Database

```sql
-- Connect as superuser
psql -U postgres

-- Create database and user
CREATE DATABASE nyc_taxi;
CREATE USER taxi_user WITH PASSWORD 'taxi_pass';
GRANT ALL PRIVILEGES ON DATABASE nyc_taxi TO taxi_user;
\q
```

### Step 3: Create the Schema

Connect to the database and run the schema file:

```bash
psql -U taxi_user -d nyc_taxi -f datasets/schema.sql
```

Or paste this directly:

```sql
-- ============================================================
-- NYC Taxi Dataset Schema
-- ============================================================

-- Yellow Taxi Trips (primary table used throughout this course)
CREATE TABLE yellow_taxi_trips (
    trip_id          SERIAL PRIMARY KEY,
    vendor_id        INTEGER,                    -- 1=Creative Mobile, 2=VeriFone
    pickup_datetime  TIMESTAMP NOT NULL,
    dropoff_datetime TIMESTAMP NOT NULL,
    passenger_count  INTEGER,
    trip_distance    NUMERIC(8,2),
    pickup_location_id  INTEGER,               -- TLC zone ID
    dropoff_location_id INTEGER,
    rate_code_id     INTEGER,                  -- 1=Standard, 2=JFK, 3=Newark, etc.
    store_and_fwd_flag CHAR(1),               -- Y/N
    payment_type     INTEGER,                  -- 1=CC, 2=Cash, 3=No charge, 4=Dispute
    fare_amount      NUMERIC(10,2),
    extra            NUMERIC(10,2),
    mta_tax          NUMERIC(10,2),
    tip_amount       NUMERIC(10,2),
    tolls_amount     NUMERIC(10,2),
    improvement_surcharge NUMERIC(10,2),
    total_amount     NUMERIC(10,2),
    congestion_surcharge  NUMERIC(10,2)
);

-- Green Taxi Trips
CREATE TABLE green_taxi_trips (
    trip_id          SERIAL PRIMARY KEY,
    vendor_id        INTEGER,
    pickup_datetime  TIMESTAMP NOT NULL,
    dropoff_datetime TIMESTAMP NOT NULL,
    passenger_count  INTEGER,
    trip_distance    NUMERIC(8,2),
    pickup_location_id  INTEGER,
    dropoff_location_id INTEGER,
    rate_code_id     INTEGER,
    store_and_fwd_flag CHAR(1),
    payment_type     INTEGER,
    fare_amount      NUMERIC(10,2),
    extra            NUMERIC(10,2),
    mta_tax          NUMERIC(10,2),
    tip_amount       NUMERIC(10,2),
    tolls_amount     NUMERIC(10,2),
    improvement_surcharge NUMERIC(10,2),
    total_amount     NUMERIC(10,2),
    trip_type        INTEGER                    -- 1=Street-hail, 2=Dispatch
);

-- TLC Taxi Zones (lookup table)
CREATE TABLE taxi_zones (
    location_id  INTEGER PRIMARY KEY,
    borough      VARCHAR(50),
    zone         VARCHAR(100),
    service_zone VARCHAR(50)
);

-- Payment Type Lookup
CREATE TABLE payment_types (
    payment_type_id  INTEGER PRIMARY KEY,
    description      VARCHAR(50)
);

INSERT INTO payment_types VALUES
    (1, 'Credit Card'),
    (2, 'Cash'),
    (3, 'No Charge'),
    (4, 'Dispute'),
    (5, 'Unknown'),
    (6, 'Voided Trip');

-- Rate Code Lookup
CREATE TABLE rate_codes (
    rate_code_id  INTEGER PRIMARY KEY,
    description   VARCHAR(100)
);

INSERT INTO rate_codes VALUES
    (1, 'Standard rate'),
    (2, 'JFK'),
    (3, 'Newark'),
    (4, 'Nassau or Westchester'),
    (5, 'Negotiated fare'),
    (6, 'Group ride');

-- Vendor Lookup
CREATE TABLE vendors (
    vendor_id    INTEGER PRIMARY KEY,
    name         VARCHAR(100),
    description  VARCHAR(200)
);

INSERT INTO vendors VALUES
    (1, 'Creative Mobile Technologies', 'CMT'),
    (2, 'VeriFone Inc.', 'VTS');
```

### Step 4: Download the Data

Download from Kaggle or the TLC website. For this course, we recommend the **2023 Yellow Taxi** sample (~500K rows):

```bash
# If you have Kaggle CLI set up:
kaggle datasets download -d elemento/nyc-yellow-taxi-trip-data

# Or download the Parquet files directly from TLC:
# https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
# Download yellow_tripdata_2023-01.parquet
```

### Step 5: Convert & Load

```bash
# Convert Parquet to CSV using Python
pip install pandas pyarrow

python3 - <<'EOF'
import pandas as pd

df = pd.read_parquet('yellow_tripdata_2023-01.parquet')

# Rename columns to match our schema
df = df.rename(columns={
    'VendorID': 'vendor_id',
    'tpep_pickup_datetime': 'pickup_datetime',
    'tpep_dropoff_datetime': 'dropoff_datetime',
    'RatecodeID': 'rate_code_id',
    'PULocationID': 'pickup_location_id',
    'DOLocationID': 'dropoff_location_id',
    'payment_type': 'payment_type',
})

df.to_csv('yellow_taxi_2023_01.csv', index=False)
print(f"Exported {len(df):,} rows")
EOF

# Load into PostgreSQL
psql -U taxi_user -d nyc_taxi -c "\COPY yellow_taxi_trips (vendor_id, pickup_datetime, dropoff_datetime, passenger_count, trip_distance, pickup_location_id, dropoff_location_id, rate_code_id, store_and_fwd_flag, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount, congestion_surcharge) FROM 'yellow_taxi_2023_01.csv' CSV HEADER;"
```

### Step 6: Load Taxi Zones

```bash
# Download taxi zone lookup CSV from TLC
curl -O https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv

# Load it
psql -U taxi_user -d nyc_taxi -c "\COPY taxi_zones FROM 'taxi+_zone_lookup.csv' CSV HEADER;"
```

### Step 7: Verify

```sql
psql -U taxi_user -d nyc_taxi

SELECT COUNT(*) FROM yellow_taxi_trips;
-- Should be ~3 million rows for one month

SELECT * FROM yellow_taxi_trips LIMIT 5;
SELECT * FROM taxi_zones LIMIT 5;
```

---

## Option B: BigQuery (For Week 4 Exercises)

Google provides the NYC Taxi data as a public dataset in BigQuery — no download needed!

```sql
-- In BigQuery console, reference the public dataset:
SELECT * 
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
LIMIT 100;
```

Tables available:
- `tlc_yellow_trips_2022` — Yellow taxi 2022
- `tlc_green_trips_2022` — Green taxi 2022
- `tlc_fhv_trips_2022` — For-hire vehicles 2022

---

## Option C: DuckDB (Zero-Setup, Fastest Start)

DuckDB can query Parquet files directly without a server — great for Weeks 1–2.

```bash
pip install duckdb
```

```python
import duckdb

conn = duckdb.connect()

# Query Parquet files directly — no loading needed!
conn.execute("""
    CREATE VIEW yellow_taxi_trips AS 
    SELECT * FROM read_parquet('yellow_tripdata_2023-01.parquet')
""")

result = conn.execute("SELECT COUNT(*) FROM yellow_taxi_trips").fetchone()
print(f"Rows: {result[0]:,}")
```

---

## Quick Sanity Check Queries

Run these after loading to confirm everything is working:

```sql
-- Row count
SELECT COUNT(*) AS total_trips FROM yellow_taxi_trips;

-- Date range
SELECT 
    MIN(pickup_datetime) AS earliest_trip,
    MAX(pickup_datetime) AS latest_trip
FROM yellow_taxi_trips;

-- Sample fare stats
SELECT 
    ROUND(AVG(fare_amount), 2)   AS avg_fare,
    ROUND(AVG(tip_amount), 2)    AS avg_tip,
    ROUND(AVG(trip_distance), 2) AS avg_distance
FROM yellow_taxi_trips
WHERE fare_amount > 0 AND trip_distance > 0;

-- Borough breakdown (requires taxi_zones loaded)
SELECT 
    z.borough,
    COUNT(*) AS trips
FROM yellow_taxi_trips t
JOIN taxi_zones z ON t.pickup_location_id = z.location_id
GROUP BY z.borough
ORDER BY trips DESC;
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `permission denied` on COPY | Use `\COPY` (client-side) instead of `COPY` |
| Parquet read error | `pip install pyarrow fastparquet` |
| Slow load | Add `--single-transaction` to psql or use `COPY` without logging |
| Date format mismatch | Ensure PostgreSQL `datestyle` is ISO |
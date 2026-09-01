-- ============================================================
-- day29_capstone.sql
-- ============================================================

-- ============================================================
-- Day 29 CAPSTONE: NYC Taxi Analytics Data Warehouse
-- ============================================================
-- Build a complete pipeline from raw data to BI-ready tables.
-- This is your portfolio project.
-- ============================================================

-- ---- PART 1: STAGING LAYER --------------------------------

-- 1a. Create stg_yellow_trips (cleaned raw data + metadata columns)
-- YOUR QUERY:

-- 1b. Create stg_taxi_zones with SCD2 structure (surrogate_key, valid_from, valid_to, is_current)
-- YOUR QUERY:


-- ---- PART 2: INTERMEDIATE LAYER ---------------------------

-- 2a. Create int_trips_enriched (trips + both zone names + trip_minutes + fare_category)
-- YOUR QUERY:

-- 2b. Create int_trip_features (ML feature table — see Day 28)
-- YOUR QUERY:


-- ---- PART 3: FACT TABLES ----------------------------------

-- 3a. Create fct_daily_zone_revenue (date, zone_id, zone, borough, trips, revenue, avg_fare, avg_tip_pct)
-- YOUR QUERY:

-- 3b. Create fct_hourly_demand (hour_of_day, zone_id, zone, trips, avg_fare)
-- YOUR QUERY:


-- ---- PART 4: DATA QUALITY ---------------------------------

-- 4a. Create dq_results table and run a full suite of checks
-- YOUR QUERY:

-- 4b. Create pipeline_watermarks table and implement incremental load tracking
-- YOUR QUERY:


-- ---- PART 5: ANALYTICAL VIEWS ----------------------------

-- 5a. Create v_zone_performance: current 7 days vs prior 7 days with pct_change and trend classification
-- YOUR QUERY:

-- 5b. Create v_hourly_heatmap: hour × borough trip counts with rank_within_borough
-- YOUR QUERY:


-- ---- PART 6: BONUS ----------------------------------------

-- 6a. Recursive CTE date spine: fill any gaps in daily trip data with 0s
-- YOUR QUERY:

-- 6b. Volume anomaly detection: flag days with trips > 2 stddevs from 14-day rolling mean
-- YOUR QUERY:

-- 6c. JSON output: function that returns zone stats as a JSONB object
-- YOUR QUERY:

-- ============================================================
-- 🎉 Submit your capstone by creating a PR to the repo!
-- ============================================================

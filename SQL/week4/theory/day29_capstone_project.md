# Day 29 — Capstone Project

## 🎯 The Challenge
Build a complete, production-grade analytics pipeline for NYC Taxi data using everything you've learned.

---

## Project: NYC Taxi Analytics Data Warehouse

You will build a complete pipeline from raw data to BI-ready tables.

### Deliverables

**1. Staging Layer**
- `stg_yellow_trips`: cleaned raw data with metadata columns
- `stg_taxi_zones`: zone dimension with SCD2 structure

**2. Intermediate Layer**
- `int_trips_enriched`: trips + zone names + computed fields
- `int_trip_features`: ML feature set

**3. Fact Tables**
- `fct_daily_zone_revenue`: daily aggregates per zone
- `fct_hourly_demand`: hourly trip counts per zone

**4. Dimension Tables**
- `dim_taxi_zones`: SCD Type 2 zone dimension
- `dim_payment_types`: static lookup

**5. Data Quality Layer**
- `dq_results`: automated quality check results
- `pipeline_watermarks`: incremental load tracking

**6. Analytical Views**
- `v_zone_performance`: current period vs prior period
- `v_hourly_heatmap`: demand by hour × borough

### Requirements
- All pipelines must be **idempotent**
- All fact tables must be **incrementally loadable**
- Include **data quality checks** that fail loudly on bad data
- Use **CTEs** for readability, not nested subqueries
- All monetary columns must use **NUMERIC, not FLOAT**

---

## Scoring Rubric

| Area | Points |
|------|--------|
| Correct staging/intermediate/fact layer separation | 20 |
| Idempotent load procedures | 20 |
| SCD Type 2 implementation | 15 |
| Data quality checks passing | 15 |
| Window function usage in analytics | 15 |
| Performance (indexes, partition awareness) | 15 |

---

## Bonus Challenges
- Add a recursive CTE to generate a full date spine with no gaps
- Add geospatial distance calculation between pickup and dropoff centroids
- Implement a volume anomaly detection alert
- Build a JSON output function for API consumption

---

## 📝 See `practice/day29_capstone.sql` for the exercise template!

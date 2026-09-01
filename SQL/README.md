# 🚕 SQL for AI and Data Engineers — 30-Day Roadmap
### Hands-on learning with the NYC Taxi Dataset

> A structured, practical guide to mastering SQL skills required for a Data Engineering role — from foundational queries to production-grade pipeline patterns.

---

## 📁 Repository Structure

```
SQL/
│
├── README.md                        ← You are here
├── datasets/
│   └── setup.md                     ← How to load the NYC Taxi dataset
│
├── week1/                           ← Days 1–7: SQL Foundations
│   ├── theory/
│   │   ├── day01_select_where_orderby.md
│   │   ├── day02_aggregations_groupby.md
│   │   ├── day03_joins.md
│   │   ├── day04_subqueries_ctes.md
│   │   ├── day05_string_date_functions.md
│   │   ├── day06_null_handling_case.md
│   │   └── day07_set_operations.md
│   └── practice/
│       ├── day01_exercises.sql
│       ├── day02_exercises.sql
│       ├── day03_exercises.sql
│       ├── day04_exercises.sql
│       ├── day05_exercises.sql
│       ├── day06_exercises.sql
│       └── day07_exercises.sql
│
├── week2/                           ← Days 8–14: Intermediate SQL
│   ├── theory/
│   │   ├── day08_window_functions_basics.md
│   │   ├── day09_window_functions_advanced.md
│   │   ├── day10_indexes_query_planning.md
│   │   ├── day11_data_types_casting.md
│   │   ├── day12_transactions_acid.md
│   │   ├── day13_views_materialized_views.md
│   │   └── day14_stored_procedures_functions.md
│   └── practice/
│       ├── day08_exercises.sql
│       ├── day09_exercises.sql
│       ├── day10_exercises.sql
│       ├── day11_exercises.sql
│       ├── day12_exercises.sql
│       ├── day13_exercises.sql
│       └── day14_exercises.sql
│
├── week3/                           ← Days 15–21: DE-Specific SQL Patterns
│   ├── theory/
│   │   ├── day15_etl_patterns.md
│   │   ├── day16_incremental_loading.md
│   │   ├── day17_scd_slowly_changing_dimensions.md
│   │   ├── day18_partitioning_bucketing.md
│   │   ├── day19_data_quality_checks.md
│   │   ├── day20_performance_optimization.md
│   │   └── day21_analytical_patterns.md
│   └── practice/
│       ├── day15_exercises.sql
│       ├── day16_exercises.sql
│       ├── day17_exercises.sql
│       ├── day18_exercises.sql
│       ├── day19_exercises.sql
│       ├── day20_exercises.sql
│       └── day21_exercises.sql
│
├── week4/                           ← Days 22–30: Advanced & Cloud SQL
│   ├── theory/
│   │   ├── day22_bigquery_sql.md
│   │   ├── day23_spark_sql.md
│   │   ├── day24_dbt_patterns.md
│   │   ├── day25_recursive_ctes_graphs.md
│   │   ├── day26_json_semi_structured.md
│   │   ├── day27_geospatial_sql.md
│   │   ├── day28_sql_for_ml_features.md
│   │   ├── day29_capstone_project.md
│   │   └── day30_interview_prep.md
│   └── practice/
│       ├── day22_exercises.sql
│       ├── day23_exercises.sql
│       ├── day24_exercises.sql
│       ├── day25_exercises.sql
│       ├── day26_exercises.sql
│       ├── day27_exercises.sql
│       ├── day28_exercises.sql
│       ├── day29_capstone.sql
│       └── day30_interview_questions.sql
│
├── solutions/
│   └── README.md                    ← Solutions (attempt first!)
│
└── resources/
    └── cheatsheet.md                ← Quick SQL reference
```

---

## 🗺️ The 30-Day Plan at a Glance

| Week | Theme | Key Skills |
|------|-------|-----------|
| **Week 1** | SQL Foundations | SELECT, JOINs, Aggregations, CTEs, Functions |
| **Week 2** | Intermediate SQL | Window Functions, Indexes, Transactions, Views |
| **Week 3** | DE Patterns | ETL/ELT, SCD, Partitioning, Data Quality, Performance |
| **Week 4** | Advanced & Cloud | BigQuery, Spark SQL, dbt, JSON, Geospatial, ML Features |

---

## 🚀 Getting Started

### 1. Load the Dataset
Follow instructions in [`datasets/setup.md`](datasets/setup.md) to load the NYC Taxi data into PostgreSQL (local) or BigQuery (cloud).

### 2. Pick Your Database
All exercises work with **PostgreSQL**. Notes for BigQuery/Snowflake differences are included in theory files where syntax differs.

### 3. Daily Routine
```
📖 Read the theory file (20–30 min)
✍️  Attempt the exercises (45–60 min)
✅ Check solutions only after attempting
📝 Add your own notes/variations
```

### 4. Track Your Progress
Use the checklist below — check off each day as you complete it.

---

## ✅ Progress Tracker

### Week 1 — Foundations
- [ ] Day 01 — SELECT, WHERE, ORDER BY
- [ ] Day 02 — Aggregations & GROUP BY
- [ ] Day 03 — JOINs (INNER, LEFT, RIGHT, FULL, CROSS)
- [ ] Day 04 — Subqueries & CTEs
- [ ] Day 05 — String & Date Functions
- [ ] Day 06 — NULL Handling & CASE WHEN
- [ ] Day 07 — Set Operations (UNION, INTERSECT, EXCEPT)

### Week 2 — Intermediate
- [ ] Day 08 — Window Functions Basics (ROW_NUMBER, RANK, LAG/LEAD)
- [ ] Day 09 — Window Functions Advanced (Frames, NTILE, Running Totals)
- [ ] Day 10 — Indexes & Query Planning (EXPLAIN ANALYZE)
- [ ] Day 11 — Data Types & Casting
- [ ] Day 12 — Transactions & ACID
- [ ] Day 13 — Views & Materialized Views
- [ ] Day 14 — Stored Procedures & Functions

### Week 3 — Data Engineering Patterns
- [ ] Day 15 — ETL vs ELT Patterns in SQL
- [ ] Day 16 — Incremental Loading & Change Detection
- [ ] Day 17 — Slowly Changing Dimensions (SCD Types 1, 2, 3)
- [ ] Day 18 — Partitioning & Bucketing
- [ ] Day 19 — Data Quality Checks in SQL
- [ ] Day 20 — Query Performance Optimization
- [ ] Day 21 — Analytical Patterns (Cohort, Funnel, Retention)

### Week 4 — Advanced & Cloud
- [ ] Day 22 — BigQuery SQL (Partitioned Tables, Arrays, Structs)
- [ ] Day 23 — Spark SQL Essentials
- [ ] Day 24 — dbt Patterns (Models, Tests, Macros)
- [ ] Day 25 — Recursive CTEs & Graph Queries
- [ ] Day 26 — JSON & Semi-Structured Data
- [ ] Day 27 — Geospatial SQL
- [ ] Day 28 — SQL for ML Feature Engineering
- [ ] Day 29 — Capstone Project
- [ ] Day 30 — Interview Prep & Mock Questions

---

## 🎯 Skills You'll Have After 30 Days

**Query Writing**
- Complex multi-table JOINs and self-JOINs
- Window functions for analytics
- Recursive CTEs for hierarchical data

**Data Engineering**
- Writing idempotent, incremental SQL pipelines
- Implementing SCD Type 2 in pure SQL
- Partition-aware queries for performance

**Performance**
- Reading and interpreting EXPLAIN ANALYZE
- Index design for DE workloads
- Query optimization techniques

**Cloud & Modern Stack**
- BigQuery arrays and structs
- dbt model patterns
- SQL for feature stores

---

## 📊 About the Dataset

The [NYC Taxi & Limousine Commission (TLC) dataset](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) is one of the most widely used public datasets in data engineering education. It contains:

- **Millions of rows** of trip records (Yellow, Green, FHV cabs)
- **Rich schema**: pickup/dropoff timestamps, locations, fare amounts, payment types
- **Real-world messiness**: nulls, outliers, data quality issues to clean
- **Temporal depth**: years of historical data for trend analysis

This makes it perfect for practicing everything from basic SELECTs to complex ETL pipelines.

---

## 🛠️ Prerequisites

- Basic programming familiarity (any language)
- A computer with internet access
- PostgreSQL installed (or a free cloud DB account)
- ~1–2 hours per day

No prior SQL experience required for Week 1. By Week 4, you'll be writing production-grade SQL.

---

## 📬 Contributing

Found a bug or have a better solution? PRs welcome! Please follow the existing file naming convention.

To Collaborate,<br> email: zohaibtahir2011@gmail.com
---

*Built for aspiring AI and Data Engineers who learn by doing. Star ⭐ the repo if it helped you!*
-- ============================================================
-- Day 17: SCD Type 2
-- ============================================================

-- Q1. Create taxi_zones_scd2 with: surrogate_key (SERIAL), location_id, borough, zone,
--     service_zone, valid_from, valid_to (NULL = current), is_current BOOLEAN.
--     Load current taxi_zones data as initial version (valid_from = '2020-01-01').
-- YOUR QUERY:

-- Q2. Simulate a zone change: location_id 161 changes from 'Yellow Zone' to 'Boro Zone'.
--     Apply SCD Type 2: close old record, insert new one. Verify with SELECT.
-- YOUR QUERY:

-- Q3. Point-in-time query: what was the service_zone for location_id 161 on 2022-06-15?
--     (Before the change you simulated in Q2)
-- YOUR QUERY:

-- Q4. Join yellow_taxi_trips to taxi_zones_scd2 so each trip gets the zone record
--     that was active at the time of pickup_datetime.
-- YOUR QUERY:

-- Q5. CHALLENGE: Write a bulk SCD Type 2 merge procedure:
--     Given a staging_zone_changes table (location_id, new_service_zone, change_date):
--     a) Close old records for changed zones
--     b) Insert new versions
--     c) Leave unchanged zones untouched
--     Test with 5 changed zones.
-- YOUR QUERY:

-- ============================================================
-- Check solutions/week3/ for answers
-- ============================================================

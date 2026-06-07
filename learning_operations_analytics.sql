-- =====================================================
-- Learning Operations Analytics Project
-- Author: Grace Rebeca Verghese
-- Tools: PostgreSQL, DBeaver, Tableau
-- =====================================================

-- NOTE:
-- Run CREATE DATABASE from the default postgres database.
-- Then connect to ld_portfolio_analytics before running the rest.

-- =====================================================
-- 1. DATABASE SETUP
-- =====================================================

CREATE DATABASE ld_portfolio_analytics;

-- Connect to ld_portfolio_analytics before continuing.

CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA analytics;

-- =====================================================
-- 2. RAW TABLE CREATION
-- =====================================================

CREATE TABLE raw.raw_business_units (
    business_unit_id INTEGER PRIMARY KEY,
    business_unit_name VARCHAR(100)
);

CREATE TABLE raw.raw_ld_consultants (
    consultant_id INTEGER PRIMARY KEY,
    consultant_name VARCHAR(100),
    specialty VARCHAR(100)
);

CREATE TABLE raw.raw_learning_requests (
    request_id INTEGER PRIMARY KEY,
    title VARCHAR(200),
    request_type VARCHAR(50),
    priority VARCHAR(20),
    business_unit_id INTEGER,
    consultant_id INTEGER,
    intake_date DATE,
    target_launch_date DATE,
    actual_launch_date DATE,
    status VARCHAR(30)
);

CREATE TABLE raw.raw_request_stage_history (
    stage_history_id INTEGER PRIMARY KEY,
    request_id INTEGER,
    stage_name VARCHAR(50),
    stage_start_date DATE,
    stage_end_date DATE
);

CREATE TABLE raw.raw_stakeholder_feedback (
    feedback_id INTEGER PRIMARY KEY,
    request_id INTEGER,
    satisfaction_rating NUMERIC(3,2),
    revision_count INTEGER
);

-- =====================================================
-- 3. RAW DATA PROFILING
-- =====================================================

SELECT DISTINCT priority
FROM raw.raw_learning_requests
ORDER BY priority;

SELECT DISTINCT status
FROM raw.raw_learning_requests
ORDER BY status;

SELECT DISTINCT request_type
FROM raw.raw_learning_requests
ORDER BY request_type;

-- =====================================================
-- 4. STAGING TRANSFORMATION
-- Standardize priority, status, and request type values
-- =====================================================

DROP TABLE IF EXISTS staging.stg_learning_requests;

CREATE TABLE staging.stg_learning_requests AS
SELECT
    request_id,
    title,

    CASE
        WHEN request_type IN ('E Learning', 'E-Learning', 'Elearning', 'eLearning')
            THEN 'E-Learning'
        WHEN request_type IN ('ILT', 'Instructor Led', 'Instructor-Led Workshop', 'Workshop')
            THEN 'Instructor-Led Workshop'
        WHEN request_type IN ('Job Aid', 'JobAid', 'Reference Guide')
            THEN 'Job Aid'
        WHEN request_type IN ('Compliance Refresh', 'Compliance Update', 'Regulatory Update')
            THEN 'Compliance Update'
        WHEN request_type IN ('Leadership', 'Leadership Program', 'Manager Enablement')
            THEN 'Leadership Program'
        WHEN request_type IN ('Micro Learning', 'Microlearning', 'Quick Learn')
            THEN 'Microlearning'
        WHEN request_type IN ('Platform Training', 'System Training', 'Tool Training')
            THEN 'System Training'
        WHEN request_type IN ('Procedure Training', 'Process Training', 'SOP Training')
            THEN 'Process Training'
        ELSE request_type
    END AS request_type,

    CASE
        WHEN priority IN ('HIGH', 'High', 'high', 'H')
            THEN 'High'
        WHEN priority IN ('MED', 'Med', 'Medium', 'medium')
            THEN 'Medium'
        WHEN priority IN ('LOW', 'Low', 'low', 'L')
            THEN 'Low'
        WHEN priority IN ('CRIT', 'Critical', 'critical', 'Urgent')
            THEN 'Critical'
        ELSE priority
    END AS priority,

    business_unit_id,
    consultant_id,
    intake_date,
    target_launch_date,
    actual_launch_date,

    CASE
        WHEN status IN ('Active', 'active', 'In Progress', 'in-progress')
            THEN 'Active'
        WHEN status IN ('Completed', 'complete', 'Closed', 'Done')
            THEN 'Completed'
        WHEN status IN ('Cancelled', 'Canceled', 'cancelled', 'Dropped')
            THEN 'Cancelled'
        WHEN status IN ('On Hold', 'on hold', 'HOLD', 'Paused')
            THEN 'On Hold'
        ELSE status
    END AS status

FROM raw.raw_learning_requests;

-- =====================================================
-- 5. STAGING VALIDATION
-- =====================================================

SELECT DISTINCT priority
FROM staging.stg_learning_requests
ORDER BY priority;

SELECT DISTINCT status
FROM staging.stg_learning_requests
ORDER BY status;

SELECT DISTINCT request_type
FROM staging.stg_learning_requests
ORDER BY request_type;

-- =====================================================
-- 6. ANALYTICS MODEL
-- Fact and dimension tables
-- =====================================================

DROP TABLE IF EXISTS analytics.fact_learning_requests;

CREATE TABLE analytics.fact_learning_requests AS
SELECT
    request_id,
    business_unit_id,
    consultant_id,
    request_type,
    priority,
    status,
    intake_date,
    target_launch_date,
    actual_launch_date,

    CASE
        WHEN actual_launch_date IS NOT NULL
            THEN actual_launch_date - intake_date
        ELSE NULL
    END AS cycle_time_days

FROM staging.stg_learning_requests;

DROP TABLE IF EXISTS analytics.dim_business_units;

CREATE TABLE analytics.dim_business_units AS
SELECT
    business_unit_id,
    business_unit_name
FROM raw.raw_business_units;

DROP TABLE IF EXISTS analytics.dim_consultants;

CREATE TABLE analytics.dim_consultants AS
SELECT
    consultant_id,
    consultant_name,
    specialty
FROM raw.raw_ld_consultants;

-- =====================================================
-- 7. BUSINESS ANALYSIS QUERIES
-- =====================================================

-- Request demand by business unit
SELECT
    b.business_unit_name,
    COUNT(*) AS request_count
FROM analytics.fact_learning_requests r
INNER JOIN analytics.dim_business_units b
    ON r.business_unit_id = b.business_unit_id
GROUP BY b.business_unit_name
ORDER BY request_count DESC;

-- Active workload by consultant
SELECT
    c.consultant_name,
    COUNT(*) AS active_requests
FROM analytics.fact_learning_requests r
INNER JOIN analytics.dim_consultants c
    ON r.consultant_id = c.consultant_id
WHERE r.status = 'Active'
GROUP BY c.consultant_name
ORDER BY active_requests DESC;

-- Average cycle time by request type
SELECT
    request_type,
    ROUND(AVG(cycle_time_days), 1) AS avg_cycle_time_days
FROM analytics.fact_learning_requests
WHERE status = 'Completed'
GROUP BY request_type
ORDER BY avg_cycle_time_days DESC;

-- Average cycle time by priority
SELECT
    priority,
    ROUND(AVG(cycle_time_days), 1) AS avg_cycle_time_days
FROM analytics.fact_learning_requests
WHERE status = 'Completed'
GROUP BY priority
ORDER BY avg_cycle_time_days DESC;

-- Average satisfaction by request type
SELECT
    r.request_type,
    ROUND(AVG(f.satisfaction_rating), 2) AS avg_satisfaction
FROM analytics.fact_learning_requests r
INNER JOIN raw.raw_stakeholder_feedback f
    ON r.request_id = f.request_id
GROUP BY r.request_type
ORDER BY avg_satisfaction DESC;

-- Priority, cycle time, and satisfaction
SELECT
    r.priority,
    ROUND(AVG(r.cycle_time_days), 1) AS avg_cycle_time_days,
    ROUND(AVG(f.satisfaction_rating), 2) AS avg_satisfaction
FROM analytics.fact_learning_requests r
INNER JOIN raw.raw_stakeholder_feedback f
    ON r.request_id = f.request_id
GROUP BY r.priority
ORDER BY avg_cycle_time_days DESC;

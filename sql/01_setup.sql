-- =====================================================
-- Project: Learning Operations Analytics
-- Purpose: Database setup and schema creation
-- Author: Grace Rebeca Verghese
-- =====================================================

-- =====================================================
-- Create Project Database
-- NOTE:
-- Run this statement once from the default postgres database.
-- =====================================================

CREATE DATABASE ld_portfolio_analytics;

-- =====================================================
-- Connect to:
-- ld_portfolio_analytics
--
-- All statements below should be executed inside the
-- ld_portfolio_analytics database.
-- =====================================================

-- =====================================================
-- Create Schemas
-- =====================================================

CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA analytics;

-- =====================================================
-- RAW TABLES
-- Source-system style tables
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
-- Verification Queries
-- =====================================================

SELECT schema_name
FROM information_schema.schemata
ORDER BY schema_name;

SELECT table_schema,
       table_name
FROM information_schema.tables
WHERE table_schema IN ('raw','staging','analytics')
ORDER BY table_schema,
         table_name;

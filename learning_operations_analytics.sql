# Learning Operations Analytics Dashboard

## Project Overview

This project is an end-to-end Learning & Development analytics microproject built to simulate how an HR/L&D reporting team could analyze learning request demand, consultant workload, delivery cycle time, and stakeholder satisfaction.

The project uses synthetic L&D portfolio data and demonstrates a simple analytics workflow from raw data ingestion to SQL-based transformation, dimensional modeling, business analysis, and Tableau dashboarding.

## Tools Used

- PostgreSQL
- DBeaver
- SQL
- Tableau

## Business Problem

Learning & Development teams often receive a high volume of requests from multiple business units, but leadership may lack visibility into:

- Which business units generate the most learning demand
- Which consultants are carrying the highest active workload
- Which request types take the longest to deliver
- Whether delivery speed impacts stakeholder satisfaction

This project models those questions using a synthetic L&D request portfolio.

## Data Model

The project follows a simple raw-staging-analytics structure.

### Raw Layer

Raw source-style tables loaded from CSV files:

- `raw.raw_business_units`
- `raw.raw_ld_consultants`
- `raw.raw_learning_requests`
- `raw.raw_request_stage_history`
- `raw.raw_stakeholder_feedback`

### Staging Layer

Cleaned and standardized table:

- `staging.stg_learning_requests`

This layer standardizes inconsistent values for:

- Priority
- Status
- Request Type

### Analytics Layer

Reporting-ready fact and dimension tables:

- `analytics.fact_learning_requests`
- `analytics.dim_business_units`
- `analytics.dim_consultants`

## Key SQL Concepts Demonstrated

- Database and schema creation
- Raw data loading
- Data profiling
- Data standardization using `CASE`
- Fact and dimension modeling
- Joins
- Aggregations
- KPI calculations
- Business analysis queries

## Key Metrics

The dashboard analyzes:

- Total Requests
- Completed Requests
- Average Cycle Time
- Average Stakeholder Satisfaction
- Requests by Business Unit
- Active Requests by Consultant
- Average Cycle Time by Request Type
- Average Satisfaction by Request Type

## Dashboard Overview

The Tableau dashboard is structured around four business questions:

1. **Demand:** Which business units generate the most L&D requests?
2. **Capacity:** Which consultants are carrying the most active workload?
3. **Performance:** Which request types take the longest to deliver?
4. **Outcomes:** Which request types have the highest stakeholder satisfaction?

## Key Insights

- Retail Banking generated the highest learning request demand.
- Consultant workload varied across the L&D team, with some consultants carrying significantly more active requests.
- Leadership Programs had the longest average delivery cycle time.
- Critical requests moved through the portfolio faster than lower-priority requests and had higher average satisfaction scores.
- Stakeholder satisfaction remained relatively strong across request types, suggesting that longer delivery timelines do not necessarily imply lower satisfaction.

## What I Learned

This project helped me strengthen my understanding of:

- SQL fundamentals
- ETL and ELT-style workflows
- Data quality and business rule definition
- Fact and dimension tables
- Star schema concepts
- BI dashboard design
- Translating operational data into business insights

## AI and Analytics Reflection

While AI can now generate SQL, dashboards, and technical scripts quickly, this project reinforced that human value remains in understanding the business problem, defining the right metrics, validating the data, interpreting results, and translating insights into action.

In this project, the most important decisions were not just technical. They involved defining business rules, choosing meaningful KPIs, structuring the model, and interpreting what the numbers meant for L&D operations.

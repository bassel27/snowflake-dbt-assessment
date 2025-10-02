# Snowflake dbt Assessment

This project demonstrates using dbt (data build tool) with Snowflake to transform TPC-H sample data into analytics-ready tables following a medallion-style approach (staging → analytics).

## Setup Instructions

#### 1. Clone the Repository
`https://github.com/bassel27/snowflake-dbt-assessment`
`cd snowflake-dbt-assessment`


#### 2. Install dbt with Snowflake Adapter
`pip install dbt-snowflake`

#### 3. Prepare Snowflake Environment 
Before configuring profiles.yml, you need to create a warehouse, database, and schema in your Snowflake trial account.
Run the following SQL in your Snowflake console or worksheet:
```
CREATE WAREHOUSE dev_wh
WITH WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE;

CREATE OR REPLACE DATABASE TPCH_TRANSFORMED;
```

#### 4. Configure Snowflake Connection
Update your `profiles.yml` (CLI) or dbt Cloud connection settings with:

```yaml
snowflake_tpch_demo:
  outputs:
    dev:
      account: your-snowflake-account
      database: TPCH_TRANSFORMED
      password: your-password
      role: ACCOUNTADMIN
      schema: dev   
      threads: 4
      type: snowflake
      user: your-username
      warehouse: dev_wh
  target: dev
```

#### 5. Run Models
```bash
dbt run
```

#### 6. Run Tests
```bash
dbt test
```

#### 7. Generate Documentation
```bash
dbt docs generate
dbt docs serve
```

## Models

### Staging Layer (Silver)
	•	stg_orders
  	•	Source: orders table joined with customer.
  	•	Purpose: Creates a cleaned, enriched version of orders with customer information.
  	•	Derived columns:
    	•	order_year → extracted from o_orderdate.
    	•	total_price → carried from TPCH base table.
    	•	Tests:
      	•	o_orderkey is unique.
      	•	o_orderkey is not null.

### Analytics Layer (Gold)
	•	customer_revenue
  	•	Source: Joins orders with lineitem.
  	•	Purpose: Aggregates total revenue per customer.
  	•	Business logic:
    	•	Revenue = SUM(l_extendedprice * (1 - l_discount)).
    	•	Grouped by: c_custkey (customer key).
    	•	Includes: Customer name for readability in downstream analytics.
    	•	Tests:
      	•	c_custkey is not null (ensures valid customers).

## Deployment / Scheduling
**In dbt Cloud:**
- The project is linked to GitHub.
- A scheduled job runs daily to:
  1. `dbt run` → rebuild models
  2. `dbt test` → validate data
<img width="718"  alt="image" src="https://github.com/user-attachments/assets/a171c83a-6005-4f21-bc4d-3d11f4764ee9" />

This ensures transformed tables/views in Snowflake are always up-to-date.

## Assumptions

- Snowflake sample data (TPC-H) is available via `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`
- Transformations are written to a dedicated database (`TPCH_TRANSFORMED`) and schema (`DEV` or `PROD`) depending on environment
- Models are materialized as views by default (can be overridden in `dbt_project.yml`)

## Source Tables

The project uses the following source tables from TPC-H:
- `customer` - Customer information
- `orders` - Order headers
- `lineitem` - Order line items

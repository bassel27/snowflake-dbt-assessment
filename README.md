# Snowflake dbt Assessment

This project demonstrates using dbt (data build tool) with Snowflake to transform TPC-H sample data into analytics-ready tables following a medallion-style approach (staging → analytics).

## Setup Instructions

#### 1. Clone the Repository
`git clone https://github.com/bassel27/snowflake-dbt-assessment`
`cd snowflake-dbt-assessment`


#### 2. Install Dependenices With Poetry
Dependenices include dbt-snowflake which will be installed using Poetry. If you don't have Poetry, you can use `pip install dbt-snowflake`
`poetry install`
`poetry shell`

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
Locate your profiles.yml file at ~/.dbt/profiles.yml (Mac/Linux) or C:\Users\<username>\.dbt\profiles.yml (Windows). Update it with your Snowflake credentials:

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

# dbt Models Documentation

This document describes the structure and purpose of the models in the Snowflake dbt project.

## Models

### Staging Layer (Silver)

**Model:** `stg_orders`  
**Source:** `orders` table joined with `customer` table  
**Purpose:** Creates a cleaned and enriched version of orders with customer information  

**Columns & Tests:**
| Column | Description | Tests |
|--------|-------------|-------|
| o_orderkey | Primary key of the orders table (TPCH.orders.o_orderkey). Uniquely identifies each order. | unique, not_null |
| o_custkey | Foreign key referencing TPCH.customer.c_custkey. Links an order to the customer who placed it. | relationships → validates every order references an existing customer  (enforcing referential integrity) |
| c_name | Customer name from the TPCH.customer table. Joined via o_custkey = c_custkey. | None |
| order_year | Year extracted from o_orderdate.  | None |
| total_price | Alias for the total price of the order carried forward from TPCH.orders.o_totalprice. | None |

### Analytics Layer (Gold)

**Model:** `customer_revenue`  
**Source:** Joins `orders` with `lineitem`  
**Purpose:** Aggregates total revenue per customer  

**Columns & Tests:**

| Column | Description | Tests |
|--------|-------------|-------|
| c_custkey | Primary key of the customer. Sourced from TPCH.customer.c_custkey and used to uniquely identify each customer. | not_null |
| customer_name | Full name of the customer (from TPCH.customer.c_name) for readability. | None |
| total_revenue | Total revenue per customer. Calculated as the SUM(l_extendedprice * (1 - l_discount)) across all associated orders. | None |

## Deployment / Scheduling
**In dbt Cloud:**
- The project is linked to GitHub.
- A scheduled job runs daily to:
  1. `dbt run` → rebuild models
  2. `dbt test` → validate data
This ensures transformed tables/views in Snowflake are always up-to-date. 
<img width="418"  alt="image" src="https://github.com/user-attachments/assets/a171c83a-6005-4f21-bc4d-3d11f4764ee9" />

## Assumptions

- Snowflake sample data (TPC-H) is available via `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`
- Transformations are written to a dedicated database (`TPCH_TRANSFORMED`) and schema (`DEV` or `PROD`) depending on environment
- Models are materialized as views by default (can be overridden in `dbt_project.yml`)

## Source Tables

The project uses the following source tables from TPC-H:
- `customer` - Customer information
- `orders` - Order headers
- `lineitem` - Order line items

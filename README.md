# Snowflake dbt Assessment

This project demonstrates using dbt (data build tool) with Snowflake to transform TPC-H sample data into analytics-ready tables following a medallion-style approach (staging → analytics).

## Setup Instructions

#### 1. Clone the Repository
`git clone https://github.com/<your-username>/snowflake-dbt-assessment.git`
`cd snowflake-dbt-assessment`


#### 2. Install dbt with Snowflake Adapter
`pip install dbt-snowflake`

#### 3. Configure Snowflake Connection
Update your `profiles.yml` (CLI) or dbt Cloud connection settings with:

```yaml
snowflake-dbt-assessment:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your-snowflake-account
      user: your-username
      password: your-password
      role: your-role
      warehouse: DEV_WH
      database: TPCH_TRANSFORMED
      schema: DEV
      threads: 4
```

#### 4. Run Models
```bash
dbt run
```

#### 5. Run Tests
```bash
dbt test
```

#### 6. Generate Documentation
```bash
dbt docs generate
dbt docs serve
```

## Models

### Staging Layer (Silver)
- **stg_orders** - Selects from orders and joins with customer to add customer name
- Adds derived fields: `order_year`, `total_price`
- **Tests**: `o_orderkey` is unique and not null

### Analytics Layer (Gold)
- **customer_revenue** - Aggregates revenue per customer by joining orders and lineitem
- Revenue calculation: `SUM(l_extendedprice * (1 - l_discount))`
- Grouped by `c_custkey`
- **Tests**: Customer key is not null

## Deployment / Scheduling

**In dbt Cloud:**
- The project is linked to GitHub (`snowflake-dbt-assessment`)
- A scheduled job runs daily to:
  1. `dbt run` → rebuild models
  2. `dbt test` → validate data

This ensures transformed tables/views in Snowflake are always up-to-date.

## Assumptions

- Snowflake sample data (TPC-H) is available via `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`
- Transformations are written to a dedicated database (`TPCH_TRANSFORMED`) and schema (`DEV` or `PROD`) depending on environment
- For demonstration, a daily schedule is used, but in production the cadence should match data refresh frequency
- Models are materialized as views by default (can be overridden in `dbt_project.yml`)

## Source Tables

The project uses the following source tables from TPC-H:
- `customer` - Customer information
- `orders` - Order headers
- `lineitem` - Order line items

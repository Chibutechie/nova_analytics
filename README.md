# NovaTrade Group — Analytics Engineering Pipeline

## Navigation

---

Quickly move to the session you want.

- [Overview](#overview)
- [Project Objective](#project-objective)
- [Pipeline Overview](#pipeline-overview)
- [Project Structure](#project-structure)
- [Architecture Flow](#architecture-flow)
- [How It Works](#how-it-works)
- [Source Dataset](#source-dataset)
- [Technologies](#technologies)
- [Setup Instructions](#setup-instructions)
- [Dashboard](#dashboard)

## Overview

This project transforms raw transactional, customer, product, store, and budget data from NovaTrade Group's three source systems into a clean, tested, analysis-ready star schema using dbt. The output feeds a Power BI reporting layer (Global Trade & Performance Dashboard) covering Revenue Performance, Category & Region, Customer Intelligence, and Operations.

NovaTrade Group is a multinational retail conglomerate operating across five regions (Europe, North America, Middle East, Africa, Asia-Pacific) and one online channel (NovaTrade Direct), selling across four categories (Electronics, Fashion, Home & Garden, Sports & Outdoors) spanning three pricing tiers (Budget, Mid-Market, Premium).

Data coverage: January 2022 – December 2024 · 50,000 transactions · 8,000 customers · 327 products · 116 stores (115 physical + 1 online) · 720 monthly budget records

---

## Project Objective

This pipeline extracts raw data from local storage, converts it to the Parquet format, loads it into a relational database, and transforms it into analytics-ready models using dbt.

---

## Pipeline Overview

| Step | Stage         | Description                                                     |
| ---- | ------------- | --------------------------------------------------------------- |
| 1    | **Extract**   | Read raw CSV files from local storage                           |
| 2    | **Convert**   | Serialize data to Parquet format for efficient columnar storage |
| 3    | **Load**      | Ingest Parquet files into the target database                   |
| 4    | **Transform** | Apply business logic and cleaning rules via dbt                 |
| 5    | **Model**     | Produce staging, intermediate, and mart dbt models              |
| 6    | **Reporting** | Create Power BI reports                                         |

---

## Project Structure

```
nova_analytics/
│
├── BI Report/
│   └── NTG.pbix                          # Power BI report file
│
├── data/
│   └── parquet/                          # Raw source data files
│       ├── NTG_Customers.parquet
│       ├── NTG_Products.parquet
│       ├── NTG_Sales.parquet
│       └── NTG_Stores.parquet
│
├── pipeline/
│   ├── config.py
│   ├── convert.py
│   ├── extract.py
│   ├── load.py
│   └── main.py
│
├── novatrade/                            # dbt project root
│   ├── dbt_project.yml                   # dbt project configuration
│   │
│   ├── models/
│   │   ├── staging/                      # Source cleaning & casting
│   │   │   ├── sources.yml               # Source definitions + freshness
│   │   │   ├── properties.yml            # Staging model docs & tests
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_products.sql
│   │   │   ├── stg_sales.sql
│   │   │   └── stg_stores.sql
│   │   │
│   │   ├── intermediate/
│   │   │   ├── schema.yml
│   │   │   ├── int_customer.sql
│   │   │   ├── int_products.sql
│   │   │   └── int_sales.sql
│   │   │
│   │   └── marts/
│   │       ├── schema.yml
│   │       ├── fct_revenue.sql
│   │       ├── dim_customer_revenue.sql
│   │       ├── dim_date.sql
│   │       ├── dim_discount_impact.sql
│   │       ├── dim_returns.sql
│   │       └── dim_revenue_monthly.sql
│   │
│   ├── analyses/
│   │   └── customers/
│   │       └── customer_value_distribution.sql
│   │
│   ├── macros/
│   │   └── generate_schema_name.sql
│   │
│   ├── tests/
│   │   ├── assert_discount_range.sql
│   │   ├── cost_price_less_than_unit_price.sql
│   │   ├── customer_order_check.sql
│   │   └── no_negative_revenue.sql
│   │
│   ├── seeds/
│   └── snapshots/
│
├── logs/
│   └── dbt.log
├── pyproject.toml
└── .gitignore
```

## Architecture Flow

---

## Data Flow

The pipeline follows a particular pattern from source to BI reporting.

- **Extraction:** The data is extracted from the local machine using python-pandas library.
- **Conversion:** The files are then converted from CSV to Parquet, and then saved on the local machine.
- **Load:** Converted files are then loaded into Postgres as raw data.
- **Transformation:** dbt connects to the loaded data in Postgres for transformation and modeling.

#### Low-level DAG Pipeline Diagram

<img width="913" height="409" alt="image" src="https://github.com/user-attachments/assets/cfc3e3ea-77ad-49cd-adae-b8bf708fe7ea" />

---

## How It Works

### dbt Modelling Layers

The dbt project follows a three-layer modelling architecture. Each layer has a distinct responsibility and feeds into the next.

```
raw (PostgreSQL)
     │
     ▼
 staging          # Clean, cast, and rename — 1:1 with raw tables
     │
     ▼
 intermediate     # Enrich and derive — business logic before final models
     │
     ▼
 marts            # Star schema — facts and dimensions ready for reporting
```

---

#### Staging — `models/staging/`

Materialised as **views**. One model per source table. No business logic — only cleaning, renaming, type casting, and deduplication. All column names are standardised to `snake_case` at this layer.

| Model           | Source Table        | Description                                                             |
| --------------- | ------------------- | ----------------------------------------------------------------------- |
| `stg_sales`     | `raw.ntg_sales`     | Transactions cleaned — types cast, nulls filtered, discount validated   |
| `stg_customers` | `raw.ntg_customers` | Customer records cleaned — name formatted, email lowercased, dates cast |
| `stg_products`  | `raw.ntg_products`  | Product catalogue cleaned — price and cost cast, category standardised  |
| `stg_stores`    | `raw.ntg_stores`    | Store records cleaned — region and store type standardised              |

Data quality tests defined in `properties.yml` cover uniqueness, not-null constraints, referential integrity, and accepted values across all staging models.

---

#### Intermediate — `models/intermediate/`

Materialised as **views**. Enriches staging models with derived fields and business logic before mart construction. These models exist to keep marts clean and focused.

| Model          | Description                                                                                                                  |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `int_sales`    | Joins `stg_sales` with product cost data; derives `gross_revenue`, `net_revenue`, `cogs`, and `gross_profit` per transaction |
| `int_customer` | Enriches `stg_customers` with `tenure_band` derived from `join_date` and a `channel_type` flag (Online vs. In-Store)         |
| `int_products` | Enriches `stg_products` with margin calculations and product tier classifications ready for dimension use                    |

---

#### Marts — `models/marts/`

Materialised as **tables**. The final analytics layer — a star schema consumed directly by Power BI. All business metrics are pre-computed here so the reporting layer performs no transformations.

| Model                  | Type      | Description                                                                          |
| ---------------------- | --------- | ------------------------------------------------------------------------------------ |
| `fct_revenue`          | Fact      | One row per transaction — revenue, COGS, gross profit, net profit, ship cost         |
| `dim_customer_revenue` | Dimension | Customer-level revenue summary — LTV, order count, avg order value, segment          |
| `dim_date`             | Dimension | Full date spine from 2022–2024 — year, quarter, month, week, weekend flag            |
| `dim_discount_impact`  | Dimension | Discount band analysis — revenue and margin impact by discount range                 |
| `dim_returns`          | Dimension | Return transactions — return rate, revenue lost, return reason by product and region |
| `dim_revenue_monthly`  | Dimension | Monthly revenue aggregated by region, category, and channel                          |

---

#### Custom Tests — `tests/`

In addition to generic dbt tests in `schema.yml`, four singular SQL tests enforce business rules that generic tests cannot cover:

| Test                                  | Description                                                |
| ------------------------------------- | ---------------------------------------------------------- |
| `assert_discount_range.sql`           | Fails if any discount falls outside the 0–1 range          |
| `cost_price_less_than_unit_price.sql` | Fails if cost price is greater than or equal to unit price |
| `customer_order_check.sql`            | Fails if any customer has no associated transactions       |
| `no_negative_revenue.sql`             | Fails if any transaction produces a negative revenue value |

Run all tests with:

```bash
dbt test
```

#### Macros — `macros/`

| Macro                      | Description                                                                                                                                           |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `generate_schema_name.sql` | Overrides dbt's default schema naming to use exact schema names (`staging`, `intermediate`, `marts`) instead of prefixed names like `dbt_dev_staging` |

---

## Source Dataset

Five CSV source files covering January 2022 to December 2024.

| File                | Rows   | Description                                                                                              |
| ------------------- | ------ | -------------------------------------------------------------------------------------------------------- |
| `NTG_Sales.csv`     | 50,000 | Transaction records — order date, product, store, quantity, unit price, discount, ship cost, return flag |
| `NTG_Customers.csv` | 8,000  | Customer master — name, email, segment, loyalty tier, region, join date, channel                         |
| `NTG_Products.csv`  | 327    | Product catalogue — category, sub-category, tier, unit price, cost price                                 |
| `NTG_Stores.csv`    | 116    | Store directory — store type, region, country (115 physical + 1 online)                                  |

All source files are read from the local machine path configured in `pipeline/config.py`.

---

## Technologies

| Tool             | Version | Purpose                                                      |
| ---------------- | ------- | ------------------------------------------------------------ |
| Python           | 3.13    | Pipeline orchestration — extraction, conversion, and loading |
| pandas           | latest  | CSV reading and DataFrame operations                         |
| PyArrow          | latest  | Parquet conversion and reading                               |
| SQLAlchemy       | latest  | Database engine and loading interface                        |
| psycopg2-binary  | latest  | PostgreSQL adapter                                           |
| PostgreSQL       | 15+     | Relational data warehouse — hosts raw and dbt schemas        |
| dbt-core         | 1.8.0   | Data transformation and modelling framework                  |
| dbt-postgres     | 1.8.0   | dbt adapter for PostgreSQL                                   |
| Power BI Desktop | latest  | Dashboard and reporting layer                                |

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/Chibutechie/nova_analytics.git
cd nova_analytics
```

### 2. Create and activate a virtual environment

```bash
python -m venv .venv
source .venv/Scripts/activate    # Windows (Git Bash)
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure environment variables

Copy `.env.example` to `.env` and fill in your credentials:

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=novatrade
DB_USER=postgres
DB_PASSWORD=your_password
LOCAL_DATA_PATH=C:\Users\LENOVO\OneDrive\Documents\novatrade
```

### 5. Configure dbt profile

Add the following to `~/.dbt/profiles.yml`:

```yaml
novatrade:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      dbname: novatrade
      user: postgres
      password: your_password
      schema: dbt_dev
      threads: 4
```

### 6. Run the pipeline

Run the full pipeline — extract, convert, load, and transform:

```bash
python pipeline/main.py
```

Or run the dbt layer independently after loading:

```bash
cd novatrade
dbt deps
dbt run
dbt test
```

### 7. Connect Power BI

Open `BI Report/NTG.pbix` in Power BI Desktop and update the PostgreSQL connection to point to your local instance. All visuals draw from the `marts` schema.

---

## Dashboard

The Power BI report (`NTG.pbix`) is structured across four pages:

| Page                      | Description                                                                            |
| ------------------------- | -------------------------------------------------------------------------------------- |
| **Revenue Performance**   | Total revenue, gross profit, net profit trends by year, quarter, and month             |
| **Category & Region**     | Revenue and margin breakdown by product category, sub-category, tier, and region       |
| **Customer Intelligence** | Customer segmentation, loyalty tier distribution, LTV, and channel performance         |
| **Operations**            | Return rates, discount impact on margin, shipping cost analysis, and store performance |

All pages connect directly to the `marts` schema in PostgreSQL and require no manual data refresh configuration beyond the initial connection setup.

# NovaTrade Group — Analytics Engineering Projec

## Navigation

---

Quickly move to the session you want.

- [Overview](#overview)
- [Project Objective](#project-objective)
- [Pipeline Overview](#pipeline-overview)
- [Project Structure](#project-structure)
- [Architecture Flow](#architecture-flow)
- [How It Works](#how-it-works)
- [Dataset Schema](#dataset-schema)
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
|   ├── convert.py
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

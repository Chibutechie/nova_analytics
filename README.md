# NovaTrade Group — Analytics Engineering Project

## Overview

This project transforms raw transactional, customer, product, store, and budget data from NovaTrade Group's three source systems into a clean, tested, analysis-ready star schema using dbt. The output feeds a Power BI reporting layer (Global Trade & Performance Dashboard) covering Revenue Performance, Category & Region, Customer Intelligence, and Operations.

NovaTrade Group is a multinational retail conglomerate operating across five regions (Europe, North America, Middle East, Africa, Asia-Pacific) and one online channel (NovaTrade Direct), selling across four categories (Electronics, Fashion, Home & Garden, Sports & Outdoors) spanning three pricing tiers (Budget, Mid-Market, Premium).

**Data coverage:** January 2022 – December 2024 · 50,000 transactions · 8,000 customers · 327 products · 116 stores (115 physical + 1 online) · 720 monthly budget records

---

## Source Systems

| Raw Table           | Source System                  | Description                                                                             |
| ------------------- | ------------------------------ | --------------------------------------------------------------------------------------- |
| `raw.ntg_sales`     | POS / E-commerce Engine        | 50,000 transaction rows — quantity, unit price, discount %, return flag/date, ship cost |
| `raw.ntg_products`  | Product Information Management | 327 products — category, sub-category, brand, tier, cost price                          |
| `raw.ntg_customers` | CRM (Salesforce)               | 8,000 customers — loyalty tier, segment, region, join date, channel preference          |
| `raw.ntg_stores`    | Facilities Management System   | 116 stores — region, country, square footage, open date, store type                     |
| `raw.ntg_budget`    | Finance ERP (SAP)              | 720 monthly budget targets — region × category × month × year                           |

---

## Project Architecture

```
models/
├── staging/
│   ├── stg_sales.sql
│   ├── stg_products.sql
│   ├── stg_customers.sql
│   ├── stg_stores.sql
│   └── stg_budget.sql
├── intermediate/
│   ├── int_sales_enriched.sql
│   ├── int_customers_enriched.sql
│   ├── int_products_enriched.sql
│   ├── int_budget_aligned.sql
│   └── int_returns.sql
└── marts/
    ├── dim_date.sql
    ├── fct_revenue.sql
    ├── fct_revenue_monthly.sql
    ├── fct_budget_vs_actual.sql
    ├── fct_customer_revenue.sql
    ├── fct_returns.sql
    └── fct_discount_impact.sql

analyses/
├── revenue/
├── customers/
├── returns/
└── operations/
```

### Layer Responsibilities

| Layer        | Responsibility                                | Aggregation? | References                                             |
| ------------ | --------------------------------------------- | ------------ | ------------------------------------------------------ |
| Staging      | Type casting, renaming, no business logic     | No           | Raw sources only                                       |
| Intermediate | Joins, enrichment, business logic definitions | No           | Staging only                                           |
| Marts        | Aggregation, one fixed grain per model        | Yes          | Intermediate models (one mart references another mart) |
| Analyses     | Ad hoc investigation, not materialised        | Either       | Marts only                                             |

**Core rule:** business logic is defined exactly once, in the intermediate layer, and consumed everywhere downstream. No mart recalculates a column that already exists upstream.

---

## Business Logic — Core Definitions

All defined in `int_sales_enriched`, the central enrichment model joining `stg_sales` to `stg_products` (on `product_id`) and `stg_stores` (on `store_id`).

### Revenue — Three Definitions

| Column               | Formula                                        | Answers                                  |
| -------------------- | ---------------------------------------------- | ---------------------------------------- |
| `revenue_gross`      | `unit_price * quantity`                        | What could we have earned at full price? |
| `revenue_net`        | `unit_price * quantity * (1 - discount)`       | What did we actually charge?             |
| `revenue_recognised` | `revenue_net` if `return_flag = 'N'`, else `0` | What did we actually keep?               |

Invariant tested in CI: `revenue_gross >= revenue_net >= revenue_recognised`

`revenue_net` is the primary figure used across all downstream measures unless explicitly stated otherwise.

### Cost & Profitability

| Column                        | Formula                                            | Notes                                               |
| ----------------------------- | -------------------------------------------------- | --------------------------------------------------- |
| `cogs`                        | `cost_price * quantity`                            | Product cost only — excludes shipping               |
| `gross_profit`                | `revenue_net - cogs`                               |                                                     |
| `gross_profit_margin`         | `1 - (cost_price / (unit_price * (1 - discount)))` | Stored as a ratio (e.g. `0.4671`), not a percentage |
| `cogs_including_shipping`     | `cogs + ship_cost`                                 | Used for online channel margin analysis             |
| `gross_profit_after_shipping` | `gross_profit - ship_cost`                         | Contribution margin                                 |

**Important:** at the mart layer, margin must be recomputed from aggregated totals — never averaged at the row level:

```sql
sum(gross_profit) / nullif(sum(revenue_net), 0)
```

Averaging row-level ratios produces an unweighted figure that misrepresents the true blended margin.

**Net profit** is explicitly out of scope. This dataset supports gross profit and contribution margin (after shipping) only. True net profit requires operating expenses, depreciation, interest, and tax — none of which exist in these five source tables.

### Discount Classification

| Band          | Condition                 |
| ------------- | ------------------------- |
| `No Discount` | `discount = 0`            |
| `Low`         | `0 < discount <= 0.10`    |
| `Moderate`    | `0.10 < discount <= 0.25` |
| `Heavy`       | `discount > 0.25`         |

`revenue_lost_to_discount = revenue_gross - revenue_net`

### Returns

| Column                   | Formula                                           |
| ------------------------ | ------------------------------------------------- |
| `is_return`              | `return_flag = 'Y'`                               |
| `days_to_return`         | `return_date - order_date` (null if not returned) |
| `revenue_lost_to_return` | `revenue_gross` if returned, else `0`             |

### Product Tier

`tier` (`Budget` / `Mid-Market` / `Premium`) is sourced directly from `stg_products`. It is the primary driver of both price range and margin profile — Premium products carry ~50% margin vs ~25% for Budget. Across the dataset, Premium represents 78–80% of revenue uniformly across every region, meaning regional revenue differences are **not** explained by tier mix.

### Customer Tenure & Value Tier

```sql
case
    when age('2024-12-31', join_date) < interval '1 year'  then 'New'
    when age('2024-12-31', join_date) < interval '3 years' then 'Developing'
    else 'Established'
end as tenure_band
```

Customer Value Tier (mart-layer, based on cumulative `revenue_net` per customer):

| Tier     | Threshold           |
| -------- | ------------------- |
| Platinum | `> $50,000`         |
| Gold     | `$20,001 – $50,000` |
| Silver   | `$5,001 – $20,000`  |
| Bronze   | `$1,001 – $5,000`   |
| Prospect | `<= $1,000`         |

---

## Intermediate Models

### `int_sales_enriched`

**Grain:** one row per transaction (50,000 rows)
Joins `stg_sales` to `stg_products` and `stg_stores`. Defines all revenue, cost, profit, discount, and return logic above. This is the single source of truth for transaction-level business logic.

```sql
from stg_sales s
left join stg_products p  on s.product_id = p.product_id
left join stg_stores   st on s.store_id   = st.store_id
```

Left joins are mandatory — an inner join would silently drop any transaction whose `product_id` or `store_id` has no match, understating revenue with no error raised.

### `int_customers_enriched`

**Grain:** one row per customer (8,000 rows)
Adds `tenure_band`. No joins to sales — pure attribute enrichment.

### `int_products_enriched`

**Grain:** one row per product (327 rows)
Adds `tier_rank` and `is_premium` flag derived from `tier`.

### `int_budget_aligned`

**Grain:** one row per budget record (720 rows)
Normalises `region` and `category` naming so the finance ERP's labels exactly match the conventions used in `int_sales_enriched`. This is the only place category/region name mismatches between SAP and the POS system are resolved — without it, `fct_budget_vs_actual` would silently produce null budget values for mismatched rows, making variance appear 100% unfavourable.

### `int_returns`

**Grain:** one row per returned transaction (~3,888 rows)
Filtered subset of `int_sales_enriched` where `return_flag = 'Y'`. Kept as a separate intermediate model so returns logic is defined once and reused by both `fct_returns` and any model needing return-specific filtering.

---

## Marts

### `dim_date`

**Grain:** one row per calendar day (2022-01-01 to 2024-12-31)
Built via `CALENDAR()` / `date_spine`. Marked as the model's date table. Columns: `date_day`, `year`, `quarter`, `month_num`, `month_name` (sorted by `month_num`), `week_num`, `is_weekend`, `fiscal_quarter`.

### `fct_revenue`

**Grain:** one row per transaction (50,000 rows)
The primary fact table. Carries every column from `int_sales_enriched` plus all foreign keys. Powers `DISTINCTCOUNT(transaction_id)` based measures (AOV, transaction counts) in Power BI.

### `fct_revenue_monthly`

**Grain:** one row per Region × Category × Year × Month
Pre-aggregated revenue, COGS, gross profit, margin, return rate, and discount loss. Exists to avoid scanning 50,000 rows for every trend/category visual.

### `fct_budget_vs_actual`

**Grain:** one row per Region × Category × Year × Month
Left joins `int_budget_aligned` to `fct_revenue_monthly`. Left join from budget preserves every budgeted line even where actual revenue is zero — an inner join would make a budget target for a quiet region simply disappear from the variance report rather than showing it as a 100% miss.

Exposes `revenue_variance`, `gross_profit_variance`, `revenue_attainment`.

### `fct_customer_revenue`

**Grain:** one row per customer, including the 16 customers with zero purchases (8,000 rows)
Left join from `int_customers_enriched` to `int_sales_enriched` — preserves all 8,000 CRM customers. An inner join would drop the 16 inactive customers, causing the mart's customer count (7,984) to silently mismatch the CRM's count (8,000). Computes `customer_value_tier` via the thresholds above.

### `fct_returns`

**Grain:** one row per returned transaction (~3,888 rows)
Sourced from `int_returns`. Adds `revenue_lost` and `gross_profit_lost` as the financial impact of each return.

### `fct_discount_impact`

**Grain:** one row per Discount Band × Category × Region × Year × Month
Aggregates `revenue_gross`, `revenue_net`, `revenue_lost_to_discount`, `gross_profit_margin`, and `avg_discount_pct` to support discount-vs-margin analysis without scanning the full fact table.

---

## Data Quality Decisions

| Issue                                                               | Resolution Layer                    | Decision                                                                                                    |
| ------------------------------------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `discount` stored inconsistently (decimal vs. integer) in raw sales | Staging                             | Normalised to decimal in `stg_sales` before any calculation                                                 |
| 16 customers with no sales history                                  | Mart (`fct_customer_revenue`)       | Preserved via left join; revenue shows as `0`/`null`, not dropped                                           |
| Budget category/region naming mismatch vs. POS                      | Intermediate (`int_budget_aligned`) | Naming aligned before the budget-to-actual join, never inside the mart                                      |
| `return_date` null for non-returns                                  | Intermediate (`int_sales_enriched`) | `days_to_return` explicitly guarded with `CASE WHEN return_flag = 'Y'`                                      |
| `ship_cost` only populated for online orders under $100             | Intermediate / Mart                 | Kept as a separate column; never blanket-summed into COGS — channel margin comparisons explicitly note this |

---

## Key Findings From the Model (Validated Against the Marts)

These are the headline results the marts are built to surface — useful for validating that a fresh build is producing correct numbers.

| Metric          | 2022    | 2023    | 2024    |
| --------------- | ------- | ------- | ------- |
| Total Revenue   | $22.99M | $22.39M | $21.97M |
| Gross Margin %  | 46.8%   | 46.7%   | 46.6%   |
| Avg Order Value | $1,374  | $1,347  | $1,320  |
| Transactions    | 16,737  | 16,619  | 16,644  |
| Return Rate %   | 8.0%    | 7.8%    | 7.5%    |

**Revenue decline driver:** transaction count is flat (~16,600/yr) while AOV fell 3.9% — the decline is driven by customers spending less per order, not by fewer customers transacting.

**New customer acquisition collapsed:** 6,975 (2022) → 894 (2023) → 115 (2024), an ~87% YoY drop in the most recent period — a leading indicator not visible in revenue or customer-count totals alone.

**Tier mix is uniform across regions:** Premium represents 78–80% of revenue in every region. Regional revenue gaps are not explained by product mix.

**Discounting correlates with returns:** Heavy discount band has a 8.4% return rate vs. 7.4% for No Discount — discounting is associated with a meaningfully higher return rate.

**Channel return rate is inverted vs. typical retail:** Physical (7.9%) > Online (7.5%) — flagged for investigation as it runs counter to the expected pattern.

**2024 budget attainment:** every category missed target; April was the worst month (76.4% attainment), May the only month to exceed 100% (101.2%).

---

## Testing Strategy

- `not_null` and `unique` on all primary keys (`transaction_id`, `customer_id`, `product_id`, `store_id`, `date_day`)
- `relationships` tests on all foreign keys in `int_sales_enriched` against their respective staging dimensions
- Custom test asserting `revenue_gross >= revenue_net >= revenue_recognised` for every row in `fct_revenue`
- Custom test asserting `fct_customer_revenue` row count equals `stg_customers` row count (8,000) — catches any accidental inner join regression
- Custom test asserting no null `region`/`category` combinations in `fct_budget_vs_actual` after the join to `int_budget_aligned`

---

## Power BI Layer

Star schema: `fct_revenue` at the centre, surrounded by `dim_date`, `dim_customers` (from `fct_customer_revenue`), `dim_products` (from `int_products_enriched`), `dim_stores`. Additional fact tables (`fct_revenue_monthly`, `fct_budget_vs_actual`, `fct_customer_revenue`, `fct_returns`, `fct_discount_impact`) form a galaxy schema sharing the same dimensions.

Measures live in a dedicated `_NTG Measures` table, organised into display folders: Revenue, Profitability, Returns, Discounts, Customers, Budget. All time-based comparisons (`PY`, `YoY`, `PM`, `MoM`) use `SAMEPERIODLASTYEAR` / `DATEADD` against `dim_date[date_day]`, which must be marked as the model's date table for these to resolve correctly.

Report pages: Revenue Performance Overview, Category & Region Deep Dive, Customer Intelligence, Operations & Returns — each with a persistent left-hand navigation panel (bookmark-driven) and a Year slicer in the header.

---

## How to Run

```bash
dbt deps
dbt seed
dbt run
dbt test
```

Build order is enforced by `ref()` dependencies: staging → intermediate → marts. `dim_date` has no upstream dependencies and can build independently; every fact mart depends on it for time intelligence to function in the BI layer.

select
    order_year,
    order_month,
    region,
    category,
    discount_band,

    count(distinct transaction_id)      as total_transactions,
    round(sum(revenue_gross)::numeric, 2)    as revenue_gross,
    round(sum(revenue_net)::numeric, 2)      as revenue_net,
    round(sum(revenue_lost_to_discount)::numeric, 2)    as revenue_lost_to_discount,
    round(sum(gross_profit)::numeric, 2)  as gross_profit,
    round(sum(gross_profit)/ nullif(sum(revenue_net), 0)::numeric, 4)   as gross_profit_margin,
    round(avg(discount)::numeric, 4)   as avg_discount_pct

from {{ ref('int_sales') }}

group by 1, 2, 3, 4, 5
select
    order_year,
    order_month,
    region,
    category,

    count(distinct transaction_id)                                     as total_transactions,
    count(distinct customer_id)                                        as total_customers,

    round(sum(revenue_gross)::numeric, 2)                             as revenue_gross,
    round(sum(revenue_net)::numeric, 2)                               as revenue_net,
    round(sum(cogs)::numeric, 2)                                      as total_cogs,
    round(sum(gross_profit)::numeric, 2)                              as gross_profit,
    round(sum(gross_profit)
        / nullif(sum(revenue_net), 0)::numeric, 4)                    as gross_profit_margin,
    round(sum(ship_cost)::numeric, 2)                                 as total_ship_cost,
    round(sum(revenue_lost_to_discount)::numeric, 2)                  as revenue_lost_to_discount,

    sum(case when is_return then 1 else 0 end)                        as total_returns,
    round(sum(case when is_return then 1 else 0 end)
        / nullif(count(*), 0)::numeric, 4)                            as return_rate

from {{ ref('int_sales') }}

group by 1, 2, 3, 4
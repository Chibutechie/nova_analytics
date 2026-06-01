select
    customer_value_tier,
    count(distinct customer_id)                                        as total_customers,
    round(sum(revenue_net)::numeric, 2)                               as total_revenue,
    round(avg(revenue_net)::numeric, 2)                               as avg_revenue_per_customer,
    round(avg(total_transactions)::numeric, 1)                        as avg_transactions,
    round(avg(avg_order_value)::numeric, 2)                           as avg_order_value,
    round(avg(return_rate)::numeric, 4)                               as avg_return_rate,

    round(sum(revenue_net)/ sum(sum(revenue_net)) over ()::numeric, 4)                  as pct_of_total_revenue,
 
    round(count(distinct customer_id) / sum(count(distinct customer_id)) over ()::numeric, 4)       as pct_of_total_customers

from {{ ref('fct_customer_revenue') }}

group by customer_value_tier
order by total_revenue desc
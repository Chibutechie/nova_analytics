select
        c.customer_id,
        c.customer_name,
        c.segment,
        c.tier,
        c.region,
        c.country,
        c.channel,
        c.tenure_band,
        c.join_date,

    count(distinct s.transaction_id) as total_transactions,
    round(sum(s.revenue_gross)::numeric, 2) as revenue_gross,
    round(sum(s.revenue_net)::numeric, 2) as revenue_net,
    round(sum(s.gross_profit)::numeric, 2) as gross_profit,
    round(sum(s.ship_cost)::numeric, 2) as total_ship_cost,

    round(sum(s.revenue_net) / nullif(count(distinct s.transaction_id), 0)::numeric, 2)    as avg_order_value,

    round(sum(case when is_return then 1 else 0 end) / nullif(count(*), 0)::numeric, 4)      as return_rate,


    round(sum(s.gross_profit) / nullif(sum(s.revenue_net), 0)::numeric, 4)  as gross_profit_margin,

    sum(case when s.is_return then 1 else 0 end)    as total_returns,

    case
        when sum(s.revenue_net) > 3000 then 'Platinum'
        when sum(s.revenue_net) > 1000 then 'Gold'
        when sum(s.revenue_net) > 500 then 'Silver'
        when sum(s.revenue_net) > 300 then 'Bronze'
    else                                    'Prospect'
    end as customer_value_tier

    from {{ ref('int_customer') }} c

    left join {{ ref('int_sales') }} s
        on c.customer_id = s.customer_id

group by
        c.customer_id,
        c.customer_name,
        c.segment,
        c.tier,
        c.segment,
        c.region,
        c.country,
        c.channel,
        c.tenure_band,
        c.join_date
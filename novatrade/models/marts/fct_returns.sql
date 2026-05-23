select
    r.transaction_id,
    r.order_date,
    r.return_date,
    r.customer_id,
    r.product_id,
    r.store_id,
    r.region,
    r.category,
    r.sub_category,
    r.tier,
    r.quantity,
    r.unit_price,
    r.revenue_gross,
    r.revenue_net,
    r.cogs,
    r.gross_profit,
    r.days_to_return,

    round(r.revenue_net::numeric, 2)  as revenue_lost,
    round(r.gross_profit::numeric, 2)  as gross_profit_lost

from {{ ref('int_returns') }} r
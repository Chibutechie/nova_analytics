select
    s.transaction_id,
    s.order_date,
    s.return_date,
    s.customer_id,
    p.product_id,
    s.store_id,
    s.region,
    p.category,
    p.sub_category,
    p.tier,
    s.quantity,
    s.unit_price,
    s.discount,
    s.revenue_gross,
    s.revenue_net,
    s.cogs,
    s.gross_profit,
    s.days_to_return,

    
    case 
    when s.days_to_return <= 30 then 'within_return_window'
    else 'return_window_expired'
end as return_window_status,

    round(s.revenue_net::numeric, 2)  as revenue_lost,
    round(s.gross_profit::numeric, 2)  as gross_profit_lost

from {{ ref('int_sales') }} s

left join {{ ref('int_products') }} p
    on s.product_id = p.product_id

where s.return_flag = 1
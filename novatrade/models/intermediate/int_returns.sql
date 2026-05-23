select
    transaction_id,
    order_date,
    return_date,
    customer_id,
    product_id,
    store_id,
    region,
    category,
    sub_category,
    tier,
    quantity,
    unit_price,
    discount,
    revenue_gross,
    revenue_net,
    cogs,
    gross_profit,
    days_to_return,

case 
    when days_to_return <= 30 then 'within_return_window'
    else 'return_window_expired'
end as return_window_status

from {{ ref('int_sales') }}

where return_flag = 1
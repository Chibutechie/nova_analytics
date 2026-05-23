select
    s.transaction_id,
    s.order_date,
    s.return_date,
    s.customer_id,
    s.product_id,
    s.store_id,

    p.category,
    p.sub_category,
    p.brand,
    p.tier,
    p.cost_price,

    st.store_type,
    st.country,
    st.region,

    s.quantity,
    s.unit_price,
    s.discount,
    s.ship_cost,
    s.return_flag,

    round((s.unit_price * s.quantity)::numeric, 2)                       as revenue_gross,
    round((s.unit_price * s.quantity * (1 - s.discount::numeric))::numeric, 2) as revenue_net,

    round((p.cost_price * s.quantity)::numeric, 2)                       as cogs,
    round(
        (
            ((s.unit_price * (1 - s.discount::numeric)) - p.cost_price)
            * s.quantity
        )::numeric,
        2
    )                                                                    as gross_profit,

    round(
        (
            1::numeric
            - (
                p.cost_price
                / nullif((s.unit_price * (1 - s.discount::numeric))::numeric, 0)
            )
        ),
        4
    )                                                                    as gross_profit_margin,

    case
        when s.discount = 0         then 'No Discount'
        when s.discount <= 0.10     then 'Low'
        when s.discount <= 0.25     then 'Moderate'
        else   'Heavy'
    end    as discount_band,

    round(
        (
            (s.unit_price * s.quantity)
            - (s.unit_price * s.quantity * (1 - s.discount::numeric))
        )::numeric,
        2
    )                                                                    as revenue_lost_to_discount,

    case
        when s.return_flag = 1 then true else false
    end                                                                   as is_return,

    case
        when s.return_flag = 1 then s.return_date - s.order_date
    end                                                                   as days_to_return,

    extract(year  from s.order_date)::int                                 as order_year,
    extract(month from s.order_date)::int                                 as order_month

from {{ ref('stg_sales') }} s
left join {{ ref('stg_products') }} p  on s.product_id = p.product_id
left join {{ ref('stg_stores') }}  st  on s.store_id   = st.store_id

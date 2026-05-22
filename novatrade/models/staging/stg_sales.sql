with source as (
    select * from {{ source('novatrade', 'ntg_sales') }}
),

cleaned as (
    select
        "TransactionID"::varchar as transaction_id,
        "OrderDate"::date as order_date,
        "ProductID"::varchar as product_id,
        "CustomerID"::varchar as customer_id,
        "StoreID"::varchar as store_id,
        "Quantity"::numeric as quantity,
        "UnitPrice"::numeric(10,2) as unit_price,

        case
            when "DiscountPct" > 1 then "DiscountPct" / 100.0
            else "DiscountPct"
        end as discount,

        "ReturnDate"::date as return_date,

        case
            when "ReturnFlag" = 'Y' or "ReturnDate" is not null then 1
            else 0
        end as return_flag,

        case
            when "ReturnFlag" = 'Y' or "ReturnDate" is not null then true
            else false
        end as is_return,

        "ShipCost"::numeric(10,2) as ship_cost

    from source
    where "TransactionID" is not null
)

select * from cleaned
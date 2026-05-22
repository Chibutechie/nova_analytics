with source as (
    select * from {{ source('novatrade','ntg_products') }}
),

final as (
    select
        "ProductID"::varchar        as product_id,
        "ProductName"::varchar      as product_name,
        "Category"::varchar         as category,
        "SubCategory"::varchar      as sub_category,
        "Brand"::varchar            as brand,
        "CostPrice"::numeric(10,2)  as cost_price,
        "Tier"::varchar             as tier
    from source
    where "ProductID" is not null
)

select * from final
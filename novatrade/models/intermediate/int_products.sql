select
    product_id,
    product_name,
    category,
    sub_category,
    brand,
    cost_price,
    tier,

    case
        when tier = 'Premium'    then 3
        when tier = 'Mid-Market' then 2
        when tier = 'Budget'     then 1
    end     as tier_rank,

    case
        when tier = 'Premium'    then true
        else                          false
    end      as is_premium

from {{ ref('stg_products') }}
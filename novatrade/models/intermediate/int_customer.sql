select
    customer_id,
    customer_name,
    segment,
    tier,
    region,
    country,
    join_date,
    channel,

    case
        when age ('2024-12-31', join_date) < interval '1 Year' then 'New'
        when age ('2024-12-31', join_date) < interval '3 Years' then 'Developing'
        else  'Established'
        end as tenure_band

    
    from {{ ref('stg_customers') }}
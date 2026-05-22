with source as (

    select * from {{ source('novatrade', 'ntg_customers') }}

),

final as (

    select
        "CustomerID"::varchar       as customer_id,
        concat("FirstName", ' ', "LastName") as customer_name,
        "Segment"::varchar          as segment,
        "LoyaltyTier"::varchar      as tier,
        "Country"::varchar          as country,
        "Region"::varchar           as region,
        "JoinDate"::date            as join_date,
        "Channel"::varchar          as channel

    from source

    where "CustomerID" is not null

)

select * from final
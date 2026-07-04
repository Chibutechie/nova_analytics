with
    source as (select * from {{ source('novatrade', 'ntg_stores') }}),

    cleaned as (
        select
            "StoreID"::varchar as store_id,
            "StoreName"::varchar as store_name,
            "StoreType"::varchar as store_type,
            "Country"::varchar as country,
            "Region"::varchar as region,
            "OpenDate"::date as open_date,
            "SquareFootage"::numeric as square_footage,
            "StoreManager"::varchar as store_manager,
            coalesce(city_mappings.normalized_city, "City") as city
        from source
        left join
            {{ ref('city_name_mappings') }} as city_mappings
            on source."City" = city_mappings.source_city
        where "StoreID" is not null
        order by "Country"
    )

select *
from cleaned

with date_spine as (



    select generate_series(

        '2022-01-01'::date,

        '2024-12-31'::date,

        interval '1 day'

    )::date as date_day



),



final as (



    select

        date_day                                                as date_day,

        extract(year  from date_day)::int                       as year,

        extract(month from date_day)::int                       as month,

        extract(day   from date_day)::int                       as day,

        extract(quarter from date_day)::int                     as quarter,

        to_char(date_day, 'Month')                              as month_name,

        to_char(date_day, 'Mon')                                as month_short,

        to_char(date_day, 'Day')                                as day_name,

        extract(dow from date_day)::int                         as day_of_week,

        extract(week from date_day)::int                        as week_of_year,

        case when extract(dow from date_day) in (0, 6)

             then true else false end                           as is_weekend,

        date_trunc('month', date_day)::date                     as first_day_of_month,

        (date_trunc('month', date_day)

            + interval '1 month - 1 day')::date                as last_day_of_month,

        date_trunc('year', date_day)::date                      as first_day_of_year,

        date_trunc('quarter', date_day)::date                   as first_day_of_quarter,

        to_char(date_day, 'YYYYMMDD')::int                      as date_key   -- surrogate key



    from date_spine



)



select * from final
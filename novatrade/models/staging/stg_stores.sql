with source as (
    select * from {{ source('novatrade', 'ntg_stores') }}
),

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
        case
            -- Australia
            when "City" = 'Australia City 12' then 'Sydney'
            when "City" = 'Australia City 2' then 'Melbourne'
            when "City" = 'Australia City 9' then 'Brisbane'
            when "City" = 'Australia City 10' then 'Perth'

            -- Canada
            when "City" = 'Canada City 10' then 'Toronto'
            when "City" = 'Canada City 16' then 'Vancouver'
            when "City" = 'Canada City 6' then 'Montreal'
            when "City" = 'Canada City 18' then 'Calgary'
            when "City" = 'Canada City 19' then 'Ottawa'
            when "City" = 'Canada City 11' then 'Edmonton'

            -- Egypt
            when "City" = 'Egypt City 3' then 'Cairo'
            when "City" = 'Egypt City 15' then 'Alexandria'
            when "City" = 'Egypt City 12' then 'Giza'
            when "City" = 'Egypt City 7' then 'Luxor'
            when "City" = 'Egypt City 1' then 'Aswan'

            -- France
            when "City" = 'France City 9' then 'Paris'
            when "City" = 'France City 26' then 'Lyon'
            when "City" = 'France City 20' then 'Marseille'
            when "City" = 'France City 23' then 'Toulouse'
            when "City" = 'France City 35' then 'Nice'

            -- Germany
            when "City" = 'Germany City 6' then 'Berlin'
            when "City" = 'Germany City 27' then 'Munich'
            when "City" = 'Germany City 7' then 'Hamburg'
            when "City" = 'Germany City 22' then 'Frankfurt'

            -- Ghana
            when "City" = 'Ghana City 14' then 'Accra'
            when "City" = 'Ghana City 2' then 'Kumasi'
            when "City" = 'Ghana City 22' then 'Tamale'
            when "City" = 'Ghana City 4' then 'Takoradi'
            when "City" = 'Ghana City 20' then 'Cape Coast'
            when "City" = 'Ghana City 5' then 'Sunyani'
            when "City" = 'Ghana City 9' then 'Ho'

            -- India
            when "City" = 'India City 6' then 'Mumbai'
            when "City" = 'India City 4' then 'Delhi'
            when "City" = 'India City 15' then 'Bangalore'
            when "City" = 'India City 18' then 'Hyderabad'

            -- Italy
            when "City" = 'Italy City 33' then 'Rome'
            when "City" = 'Italy City 3' then 'Milan'
            when "City" = 'Italy City 25' then 'Naples'
            when "City" = 'Italy City 21' then 'Turin'
            when "City" = 'Italy City 8' then 'Florence'
            when "City" = 'Italy City 5' then 'Venice'

            -- Japan
            when "City" = 'Japan City 19' then 'Tokyo'
            when "City" = 'Japan City 17' then 'Osaka'
            when "City" = 'Japan City 5' then 'Kyoto'

            -- Kenya
            when "City" = 'Kenya City 21' then 'Nairobi'
            when "City" = 'Kenya City 16' then 'Mombasa'
            when "City" = 'Kenya City 17' then 'Kisumu'
            when "City" = 'Kenya City 19' then 'Nakuru'

            -- Kuwait
            when "City" = 'Kuwait City 4' then 'Kuwait City'
            when "City" = 'Kuwait City 5' then 'Hawalli'
            when "City" = 'Kuwait City 7' then 'Salmiya'
            when "City" = 'Kuwait City 8' then 'Jahra'
            when "City" = 'Kuwait City 10' then 'Farwaniya'
            when "City" = 'Kuwait City 11' then 'Ahmadi'
            when "City" = 'Kuwait City 12' then 'Fahaheel'
            when "City" = 'Kuwait City 14' then 'Mangaf'
            when "City" = 'Kuwait City 17' then 'Sabah Al Salem'

            -- Mexico
            when "City" = 'Mexico City 5' then 'Mexico City'
            when "City" = 'Mexico City 7' then 'Guadalajara'
            when "City" = 'Mexico City 2' then 'Monterrey'
            when "City" = 'Mexico City 4' then 'Puebla'
            when "City" = 'Mexico City 14' then 'Cancun'
            when "City" = 'Mexico City 3' then 'Tijuana'

            -- Nigeria
            when "City" = 'Nigeria City 10' then 'Lagos'
            when "City" = 'Nigeria City 6' then 'Abuja'

            -- Poland
            when "City" = 'Poland City 12' then 'Warsaw'
            when "City" = 'Poland City 24' then 'Krakow'
            when "City" = 'Poland City 15' then 'Gdansk'
            when "City" = 'Poland City 16' then 'Wroclaw'
            when "City" = 'Poland City 32' then 'Poznan'
            when "City" = 'Poland City 31' then 'Lodz'
            when "City" = 'Poland City 29' then 'Szczecin'

            -- Qatar
            when "City" = 'Qatar City 16' then 'Doha'
            when "City" = 'Qatar City 6' then 'Al Wakrah'
            when "City" = 'Qatar City 1' then 'Al Khor'
            when "City" = 'Qatar City 2' then 'Lusail'
            when "City" = 'Qatar City 9' then 'Dukhan'
            when "City" = 'Qatar City 18' then 'Mesaieed'

            -- Saudi Arabia
            when "City" = 'Saudi Arabia City 13' then 'Riyadh'

            -- Singapore
            when "City" = 'Singapore City 7' then 'Tampines'
            when "City" = 'Singapore City 14' then 'Jurong East'
            when "City" = 'Singapore City 20' then 'Woodlands'
            when "City" = 'Singapore City 11' then 'Bedok'
            when "City" = 'Singapore City 16' then 'Yishun'

            -- South Africa
            when "City" = 'South Africa City 11' then 'Johannesburg'
            when "City" = 'South Africa City 8' then 'Cape Town'
            when "City" = 'South Africa City 18' then 'Durban'
            when "City" = 'South Africa City 13' then 'Pretoria'

            -- South Korea
            when "City" = 'South Korea City 13' then 'Seoul'
            when "City" = 'South Korea City 1' then 'Busan'
            when "City" = 'South Korea City 3' then 'Incheon'
            when "City" = 'South Korea City 8' then 'Daegu'

            -- Spain
            when "City" = 'Spain City 1' then 'Madrid'
            when "City" = 'Spain City 34' then 'Barcelona'
            when "City" = 'Spain City 30' then 'Valencia'
            when "City" = 'Spain City 28' then 'Seville'
            when "City" = 'Spain City 19' then 'Bilbao'
            when "City" = 'Spain City 18' then 'Malaga'
            when "City" = 'Spain City 14' then 'Granada'
            when "City" = 'Spain City 13' then 'Zaragoza'

            -- Sweden
            when "City" = 'Sweden City 17' then 'Stockholm'
            when "City" = 'Sweden City 2' then 'Gothenburg'

            -- UAE
            when "City" = 'United Arab Emirates City 15' then 'Dubai'
            when "City" = 'United Arab Emirates City 3' then 'Abu Dhabi'

            -- UK
            when "City" = 'United Kingdom City 10' then 'London'
            when "City" = 'United Kingdom City 4' then 'Manchester'
            when "City" = 'United Kingdom City 11' then 'Birmingham'

            -- United States
            when "City" = 'United States City 8' then 'New York'
            when "City" = 'United States City 1' then 'Los Angeles'
            when "City" = 'United States City 9' then 'Chicago'
            when "City" = 'United States City 12' then 'Houston'
            when "City" = 'United States City 15' then 'Miami'
            when "City" = 'United States City 17' then 'Dallas'
            when "City" = 'United States City 13' then 'Seattle'
            when "City" = 'United States City 20' then 'Atlanta'

            else "City"
        end as city
    from source
    where "StoreID" is not null
    order by "Country"
)

select * from cleaned

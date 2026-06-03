with source as (
    select * from {{ source('novatrade', 'ntg_stores') }}
),

cleaned as (
    select
        "StoreID"::varchar as store_id,
        "StoreName"::varchar as store_name,
        "StoreType"::varchar as store_type,
        "Country"::varchar as country,
CASE
    -- Australia
    WHEN "City" = 'Australia City 12' THEN 'Sydney'
    WHEN "City" = 'Australia City 2' THEN 'Melbourne'
    WHEN "City" = 'Australia City 9' THEN 'Brisbane'
    WHEN "City" = 'Australia City 10' THEN 'Perth'
 
    -- Canada
    WHEN "City" = 'Canada City 10' THEN 'Toronto'
    WHEN "City" = 'Canada City 16' THEN 'Vancouver'
    WHEN "City" = 'Canada City 6' THEN 'Montreal'
    WHEN "City" = 'Canada City 18' THEN 'Calgary'
    WHEN "City" = 'Canada City 19' THEN 'Ottawa'
    WHEN "City" = 'Canada City 11' THEN 'Edmonton'

    -- Egypt
    WHEN "City" = 'Egypt City 3' THEN 'Cairo'
    WHEN "City" = 'Egypt City 15' THEN 'Alexandria'
    WHEN "City" = 'Egypt City 12' THEN 'Giza'
    WHEN "City" = 'Egypt City 7' THEN 'Luxor'
    WHEN "City" = 'Egypt City 1' THEN 'Aswan'

    -- France
    WHEN "City" = 'France City 9' THEN 'Paris'
    WHEN "City" = 'France City 26' THEN 'Lyon'
    WHEN "City" = 'France City 20' THEN 'Marseille'
    WHEN "City" = 'France City 23' THEN 'Toulouse'
    WHEN "City" = 'France City 35' THEN 'Nice'

    -- Germany
    WHEN "City" = 'Germany City 6' THEN 'Berlin'
    WHEN "City" = 'Germany City 27' THEN 'Munich'
    WHEN "City" = 'Germany City 7' THEN 'Hamburg'
    WHEN "City" = 'Germany City 22' THEN 'Frankfurt'

    -- Ghana
    WHEN "City" = 'Ghana City 14' THEN 'Accra'
    WHEN "City" = 'Ghana City 2' THEN 'Kumasi'
    WHEN "City" = 'Ghana City 22' THEN 'Tamale'
    WHEN "City" = 'Ghana City 4' THEN 'Takoradi'
    WHEN "City" = 'Ghana City 20' THEN 'Cape Coast'
    WHEN "City" = 'Ghana City 5' THEN 'Sunyani'
    WHEN "City" = 'Ghana City 9' THEN 'Ho'

    -- India
    WHEN "City" = 'India City 6' THEN 'Mumbai'
    WHEN "City" = 'India City 4' THEN 'Delhi'
    WHEN "City" = 'India City 15' THEN 'Bangalore'
    WHEN "City" = 'India City 18' THEN 'Hyderabad'

    -- Italy
    WHEN "City" = 'Italy City 33' THEN 'Rome'
    WHEN "City" = 'Italy City 3' THEN 'Milan'
    WHEN "City" = 'Italy City 25' THEN 'Naples'
    WHEN "City" = 'Italy City 21' THEN 'Turin'
    WHEN "City" = 'Italy City 8' THEN 'Florence'
    WHEN "City" = 'Italy City 5' THEN 'Venice'

    -- Japan
    WHEN "City" = 'Japan City 19' THEN 'Tokyo'
    WHEN "City" = 'Japan City 17' THEN 'Osaka'
    WHEN "City" = 'Japan City 5' THEN 'Kyoto'

    -- Kenya
    WHEN "City" = 'Kenya City 21' THEN 'Nairobi'
    WHEN "City" = 'Kenya City 16' THEN 'Mombasa'
    WHEN "City" = 'Kenya City 17' THEN 'Kisumu'
    WHEN "City" = 'Kenya City 19' THEN 'Nakuru'

    -- Kuwait
    WHEN "City" = 'Kuwait City 4' THEN 'Kuwait City'
    WHEN "City" = 'Kuwait City 5' THEN 'Hawalli'
    WHEN "City" = 'Kuwait City 7' THEN 'Salmiya'
    WHEN "City" = 'Kuwait City 8' THEN 'Jahra'
    WHEN "City" = 'Kuwait City 10' THEN 'Farwaniya'
    WHEN "City" = 'Kuwait City 11' THEN 'Ahmadi'
    WHEN "City" = 'Kuwait City 12' THEN 'Fahaheel'
    WHEN "City" = 'Kuwait City 14' THEN 'Mangaf'
    WHEN "City" = 'Kuwait City 17' THEN 'Sabah Al Salem'

    -- Mexico
    WHEN "City" = 'Mexico City 5' THEN 'Mexico City'
    WHEN "City" = 'Mexico City 7' THEN 'Guadalajara'
    WHEN "City" = 'Mexico City 2' THEN 'Monterrey'
    WHEN "City" = 'Mexico City 4' THEN 'Puebla'
    WHEN "City" = 'Mexico City 14' THEN 'Cancun'
    WHEN "City" = 'Mexico City 3' THEN 'Tijuana'

    -- Nigeria
    WHEN "City" = 'Nigeria City 10' THEN 'Lagos'
    WHEN "City" = 'Nigeria City 6' THEN 'Abuja'

    -- Poland
    WHEN "City" = 'Poland City 12' THEN 'Warsaw'
    WHEN "City" = 'Poland City 24' THEN 'Krakow'
    WHEN "City" = 'Poland City 15' THEN 'Gdansk'
    WHEN "City" = 'Poland City 16' THEN 'Wroclaw'
    WHEN "City" = 'Poland City 32' THEN 'Poznan'
    WHEN "City" = 'Poland City 31' THEN 'Lodz'
    WHEN "City" = 'Poland City 29' THEN 'Szczecin'

    -- Qatar
    WHEN "City" = 'Qatar City 16' THEN 'Doha'
    WHEN "City" = 'Qatar City 6' THEN 'Al Wakrah'
    WHEN "City" = 'Qatar City 1' THEN 'Al Khor'
    WHEN "City" = 'Qatar City 2' THEN 'Lusail'
    WHEN "City" = 'Qatar City 9' THEN 'Dukhan'
    WHEN "City" = 'Qatar City 18' THEN 'Mesaieed'

    -- Saudi Arabia
    WHEN "City" = 'Saudi Arabia City 13' THEN 'Riyadh'

    -- Singapore
    WHEN "City" = 'Singapore City 7' THEN 'Tampines'
    WHEN "City" = 'Singapore City 14' THEN 'Jurong East'
    WHEN "City" = 'Singapore City 20' THEN 'Woodlands'
    WHEN "City" = 'Singapore City 11' THEN 'Bedok'
    WHEN "City" = 'Singapore City 16' THEN 'Yishun'

    -- South Africa
    WHEN "City" = 'South Africa City 11' THEN 'Johannesburg'
    WHEN "City" = 'South Africa City 8' THEN 'Cape Town'
    WHEN "City" = 'South Africa City 18' THEN 'Durban'
    WHEN "City" = 'South Africa City 13' THEN 'Pretoria'

    -- South Korea
    WHEN "City" = 'South Korea City 13' THEN 'Seoul'
    WHEN "City" = 'South Korea City 1' THEN 'Busan'
    WHEN "City" = 'South Korea City 3' THEN 'Incheon'
    WHEN "City" = 'South Korea City 8' THEN 'Daegu'

    -- Spain
    WHEN "City" = 'Spain City 1' THEN 'Madrid'
    WHEN "City" = 'Spain City 34' THEN 'Barcelona'
    WHEN "City" = 'Spain City 30' THEN 'Valencia'
    WHEN "City" = 'Spain City 28' THEN 'Seville'
    WHEN "City" = 'Spain City 19' THEN 'Bilbao'
    WHEN "City" = 'Spain City 18' THEN 'Malaga'
    WHEN "City" = 'Spain City 14' THEN 'Granada'
    WHEN "City" = 'Spain City 13' THEN 'Zaragoza'

    -- Sweden
    WHEN "City" = 'Sweden City 17' THEN 'Stockholm'
    WHEN "City" = 'Sweden City 2' THEN 'Gothenburg'

    -- UAE
    WHEN "City" = 'United Arab Emirates City 15' THEN 'Dubai'
    WHEN "City" = 'United Arab Emirates City 3' THEN 'Abu Dhabi'

    -- UK
    WHEN "City" = 'United Kingdom City 10' THEN 'London'
    WHEN "City" = 'United Kingdom City 4' THEN 'Manchester'
    WHEN "City" = 'United Kingdom City 11' THEN 'Birmingham'

    -- United States
    WHEN "City" = 'United States City 8' THEN 'New York'
    WHEN "City" = 'United States City 1' THEN 'Los Angeles'
    WHEN "City" = 'United States City 9' THEN 'Chicago'
    WHEN "City" = 'United States City 12' THEN 'Houston'
    WHEN "City" = 'United States City 15' THEN 'Miami'
    WHEN "City" = 'United States City 17' THEN 'Dallas'
    WHEN "City" = 'United States City 13' THEN 'Seattle'
    WHEN "City" = 'United States City 20' THEN 'Atlanta'

    ELSE "City"
END as city,
        "Region"::varchar as region,
        "OpenDate"::date as open_date,
        "SquareFootage"::numeric as square_footage,
        "StoreManager"::varchar as store_manager
    from source
    where "StoreID" is not null
    order by "Country"
)

select * from cleaned
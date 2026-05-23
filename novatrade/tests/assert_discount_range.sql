select transaction_id
from {{ ref('stg_sales') }}
where discount < 0 or discount > 1
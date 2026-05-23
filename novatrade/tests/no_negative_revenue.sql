select transaction_id
from {{ ref('fct_sales') }}
where net_revenue < 0
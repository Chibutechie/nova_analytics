select transaction_id
from {{ ref('fct_revenue') }}
where revenue_net < 0
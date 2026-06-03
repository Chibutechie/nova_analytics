select *
from {{ ref('fct_revenue')}}
where transaction_id is null
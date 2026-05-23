select *
from {{ ref('fct_sales')}}
where transaction_id is null
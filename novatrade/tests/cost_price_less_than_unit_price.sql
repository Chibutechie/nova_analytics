select product_id
from {{ ref('int_products') }}
where cost_price >= unit_price
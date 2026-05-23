select product_id
from {{ ref('products_int') }}
where cost_price >= unit_price
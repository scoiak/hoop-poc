SELECT id, name, price, stock
FROM   products
WHERE  stock < {{ .threshold
               | description "show products with stock below this number"
               | required "threshold is required"
               | type "number"
               | pattern "^[0-9]+$"
               | default "50" }}
ORDER BY stock ASC

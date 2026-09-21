SELECT o.id,
       o.total,
       o.status,
       o.created_at,
       COUNT(oi.id) AS item_count
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE o.customer_id = {{ .customer_id
                        | description "the customer ID"
                        | required "customer_id is required"
                        | type "number"
                        | pattern "^[0-9]+$"
                        | squote }}
GROUP BY o.id
ORDER BY o.created_at DESC

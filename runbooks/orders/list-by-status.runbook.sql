SELECT o.id,
       c.name  AS customer,
       o.total,
       o.status,
       o.created_at
FROM orders o
JOIN customers c ON c.id = o.customer_id
WHERE o.status = {{ .status
                  | description "order status: pending, shipped, or completed"
                  | required "status is required"
                  | type "text"
                  | pattern "^(pending|shipped|completed)$"
                  | squote }}
ORDER BY o.created_at DESC

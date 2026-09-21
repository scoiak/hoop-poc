UPDATE orders
SET    status = {{ .new_status
                | description "new status: pending, shipped, or completed"
                | required "new_status is required"
                | type "text"
                | pattern "^(pending|shipped|completed)$"
                | squote }}
WHERE  id     = {{ .order_id
                | description "the order ID to update"
                | required "order_id is required"
                | type "number"
                | pattern "^[0-9]+$"
                | squote }}
RETURNING id, status

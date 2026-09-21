SELECT id, name, email, phone, created_at
FROM customers
WHERE id = {{ .id
            | description "the customer ID"
            | required "id is required"
            | type "number"
            | pattern "^[0-9]+$"
            | squote }}

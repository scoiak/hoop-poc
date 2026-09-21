INSERT INTO customers (name, email, phone) VALUES
    ('Alice Martin',   'alice@example.com',   '+1-555-0101'),
    ('Bob Silva',      'bob@example.com',     '+1-555-0102'),
    ('Carol Johnson',  'carol@example.com',   '+1-555-0103'),
    ('David Lee',      'david@example.com',   '+1-555-0104'),
    ('Eve Nakamura',   'eve@example.com',     '+1-555-0105');

INSERT INTO products (name, description, price, stock) VALUES
    ('Widget Pro',   'Heavy-duty widget',         29.99, 200),
    ('Gadget Lite',  'Lightweight gadget',         14.49, 350),
    ('Doohickey',    'Multi-purpose doohickey',    49.00,  80),
    ('Thingamajig',  'Industrial thingamajig',     99.95,  40),
    ('Whatchamacallit', 'Compact whatchamacallit', 7.99,  500);

INSERT INTO orders (customer_id, total, status) VALUES
    (1, 59.98,  'completed'),
    (2, 14.49,  'pending'),
    (3, 148.95, 'completed'),
    (4, 99.95,  'shipped'),
    (5, 23.97,  'pending');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 2, 29.99),
    (2, 2, 1, 14.49),
    (3, 3, 1, 49.00),
    (3, 4, 1, 99.95),
    (4, 4, 1, 99.95),
    (5, 5, 3,  7.99);

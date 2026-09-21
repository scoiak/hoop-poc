# Hoop PoC

A proof-of-concept for the [Hoop](https://hoop.dev) platform running in **sidecar mode**: a single proxy that sits between clients and a PostgreSQL database, enforcing masking and policy rules defined in `hoop/config.yaml`.

## Architecture

```
Client (psql / GUI)
        │
        ▼ :15432
   ┌─────────┐       ┌──────────────┐
   │  Hoop   │──────▶│  PostgreSQL  │
   │ sidecar │       │  :5432       │
   └─────────┘       │              │
                     │  appdb       │
                     └──────────────┘
                           ▲
                      Flyway migrations
```

## Guardrails (`hoop/config.yaml`)

| Rule | Behaviour |
|------|-----------|
| `mask` — `EMAIL_ADDRESS` | Email addresses in query output are redacted |
| `policy` — `no-destructive-sql` | `DROP`, `DELETE`, and `TRUNCATE` are blocked |

---

## Getting started

```bash
docker compose up -d
```

That's it. PostgreSQL starts, Flyway applies the migrations, and the Hoop sidecar is ready on port `15432`.

---

## Connecting through Hoop

Use port **15432** instead of 5432. Everything else stays the same.

**psql**

```bash
psql -h 127.0.0.1 -p 15432 -U appuser -d appdb
# password: apppass
```

**GUI tools (TablePlus, DBeaver, DataGrip…)**

| Field    | Value     |
|----------|-----------|
| Host     | 127.0.0.1 |
| Port     | 15432     |
| User     | appuser   |
| Password | apppass   |
| Database | appdb     |
| SSL      | disable   |

---

## Runbooks

Parameterised query templates live in `runbooks/`. Each `.runbook.sql` file uses [Go template](https://pkg.go.dev/text/template) syntax with Hoop's pipe functions for input validation and SQL-injection prevention. The sidecar picks them up automatically from the path set in `hoop/config.yaml`.

```
runbooks/
├── customers/
│   ├── fetch-by-id.runbook.sql      — look up a customer by ID
│   └── list-orders.runbook.sql      — all orders for a customer
├── orders/
│   ├── list-by-status.runbook.sql   — filter orders by status
│   └── update-status.runbook.sql    — change an order's status
└── products/
    └── low-stock.runbook.sql        — products below a stock threshold
```

### Template functions reference

| Function | Purpose |
|----------|---------|
| `description` | Human-readable label shown in the UI / CLI prompt |
| `required` | Reject execution if the value is missing |
| `type` | `"number"` or `"text"` — controls form input type |
| `pattern` | Regex guard; blocks values that do not match (SQL-injection prevention) |
| `default` | Fallback value when none is supplied |
| `squote` | Wraps the rendered value in single quotes for safe SQL interpolation |

### Prerequisites

Install the Hoop CLI:

```bash
# macOS
brew tap hoophq/brew https://github.com/hoophq/brew.git && brew install hoop

# Linux
curl -s -L https://releases.hoop.dev/release/install-cli.sh | sh
```

Point the CLI at the sidecar admin API:

```bash
hoop config create --api-url http://localhost:19000
```

List all discovered runbooks:

```bash
hoop runbooks list
```

---

### `customers/fetch-by-id`

Fetches a single customer by primary key.

**Input:** `id` — customer ID (required, numeric)

```bash
hoop runbooks exec appdb customers/fetch-by-id --id 1
```

Expected output:

```
 id │ name         │ email                │ phone        │ created_at
────┼──────────────┼──────────────────────┼──────────────┼────────────
  1 │ Alice Martin │ [REDACTED]           │ +1-555-0101  │ …
```

> Email is masked by the `mask` guardrail in `hoop/config.yaml`.

---

### `customers/list-orders`

Lists all orders placed by a customer, with item count per order.

**Input:** `customer_id` — customer ID (required, numeric)

```bash
hoop runbooks exec appdb customers/list-orders --customer_id 3
```

Expected output:

```
 id │  total  │  status   │ item_count
────┼─────────┼───────────┼────────────
  3 │  148.95 │ completed │          2
```

---

### `orders/list-by-status`

Returns all orders matching a given lifecycle status, joined with the customer name.

**Input:** `status` — one of `pending`, `shipped`, `completed` (required)

```bash
hoop runbooks exec appdb orders/list-by-status --status pending
```

Expected output:

```
 id │ customer     │  total │  status  │ created_at
────┼──────────────┼────────┼──────────┼────────────
  2 │ Bob Silva    │  14.49 │ pending  │ …
  5 │ Eve Nakamura │  23.97 │ pending  │ …
```

Passing an invalid value is rejected before the query runs:

```bash
hoop runbooks exec appdb orders/list-by-status --status cancelled
# Error: input "status" does not match pattern ^(pending|shipped|completed)$
```

---

### `orders/update-status`

Moves an order to a new status. Returns the updated row.

**Inputs:** `order_id` (required, numeric) · `new_status` (required, `pending|shipped|completed`)

```bash
hoop runbooks exec appdb orders/update-status --order_id 2 --new_status shipped
```

Expected output:

```
 id │  status
────┼─────────
  2 │ shipped
```

Verify the change:

```bash
hoop runbooks exec appdb orders/list-by-status --status shipped
```

---

### `products/low-stock`

Lists products whose stock level is below a given threshold, ordered by quantity ascending. Defaults to `50` if no threshold is provided.

**Input:** `threshold` — maximum stock level to include (default `50`)

```bash
# Use the default threshold (50)
hoop runbooks exec appdb products/low-stock

# Override the threshold
hoop runbooks exec appdb products/low-stock --threshold 100
```

Expected output (default threshold):

```
 id │     name     │ price │ stock
────┼──────────────┼───────┼───────
  4 │ Thingamajig  │ 99.95 │    40
```

---

## Guardrail demonstration

**Email masking**

```sql
SELECT name, email FROM customers;
-- The email column is returned as [REDACTED].
```

**Blocked statement**

```sql
DROP TABLE customers;
-- ERROR: destructive statements are not permitted
```

---

## Seed data

| Table | Contents |
|-------|---------|
| `customers` | 5 rows with name, email, phone |
| `products` | 5 rows with name, price, stock |
| `orders` | 5 orders linked to customers |
| `order_items` | line items per order |

---

## Useful commands

```bash
# Follow all logs
docker compose logs -f

# Stop (keeps data)
docker compose down

# Stop and wipe all data
docker compose down -v
```
# hoop-poc

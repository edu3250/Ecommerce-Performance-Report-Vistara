# VISTARA — PostgreSQL Database Setup Guide

Mexican Premium Clothing E-Commerce · RFM & Churn Analysis Schema

---

## Prerequisites

| Requirement | Minimum Version | Notes |
|---|---|---|
| PostgreSQL | 14+ | 15 or 16 recommended |
| Python | 3.8+ | For the import script |
| psycopg2 | 2.9+ | `pip install psycopg2-binary` |
| psql CLI | Bundled with PostgreSQL | Used to run `.sql` files |

---

## Directory Structure

```
D:\DataScience\Sql and powerBI proyect\
├── datasets\
│   ├── Dates.csv
│   ├── Customers.csv
│   ├── Products.csv
│   ├── Sales_Outlet.csv
│   ├── Sales_Receipts.csv
│   ├── Order_Details.csv
│   ├── Inventory.csv
│   └── Returns.csv
└── sql\
    ├── schema.sql             ← DDL: tables, PKs, FKs, comments
    ├── indexes.sql            ← Performance indexes for RFM/Churn queries
    ├── import_data.py         ← Bulk CSV loader (psycopg2 COPY)
    ├── analytical_views.sql   ← 5 views for Power BI
    └── README_SQL.md          ← This file
```

---

## Step-by-Step Setup

### Step 1 — Create the Database

Connect to PostgreSQL as a superuser and create the target database:

```sql
CREATE DATABASE vistara_db;
```

Verify it was created:

```sql
\l vistara_db
```

### Step 2 — Apply the Schema (DDL)

Run `schema.sql` to create the `vistara` schema with all dimension and fact tables:

```bash
psql -U postgres -d vistara_db -f "D:\DataScience\Sql and powerBI proyect\sql\schema.sql"
```

Expected output: a series of `CREATE TABLE` and `COMMENT` messages with no errors.

Verify the schema was created:

```sql
\dn vistara
```

Verify the tables were created:

```sql
\dt vistara.*
```

### Step 3 — Configure and Run the Import Script

Open `import_data.py` and update the `DB_CONFIG` dictionary at the top of the file:

```python
DB_CONFIG = {
    "host":     "localhost",
    "port":     5432,
    "dbname":   "vistara_db",
    "user":     "postgres",       # your PostgreSQL username
    "password": "your_password",  # your PostgreSQL password
}
```

Install the Python driver if you have not already:

```bash
pip install psycopg2-binary
```

Run the import:

```bash
python "D:\DataScience\Sql and powerBI proyect\sql\import_data.py"
```

Expected output:

```
============================================================
VISTARA — PostgreSQL bulk data import
============================================================

[1/8] Importing Dates.csv → vistara.dim_dates ...          OK — 366 rows  (0.05s)
[2/8] Importing Sales_Outlet.csv → vistara.dim_sales_outlet ... OK — 5 rows  (0.01s)
[3/8] Importing Customers.csv → vistara.dim_customers ...  OK — 10,000 rows  (0.21s)
[4/8] Importing Products.csv → vistara.dim_products ...    OK — 40 rows  (0.01s)
[5/8] Importing Sales_Receipts.csv → vistara.fact_sales_receipts ... OK — 219,824 rows  (8.42s)
[6/8] Importing Order_Details.csv → vistara.fact_order_details ... OK — 219,824 rows  (8.55s)
[7/8] Importing Inventory.csv → vistara.fact_inventory ... OK — 58,560 rows  (2.14s)
[8/8] Importing Returns.csv → vistara.fact_returns ...     OK — 5,909 rows  (0.23s)

============================================================
Import complete — all tables committed successfully.
```

### Step 4 — Create Performance Indexes

Run `indexes.sql` after the data has been imported (indexes build significantly faster on a populated table):

```bash
psql -U postgres -d vistara_db -f "D:\DataScience\Sql and powerBI proyect\sql\indexes.sql"
```

### Step 5 — Create Analytical Views

Run `analytical_views.sql` to build the five views that Power BI will connect to:

```bash
psql -U postgres -d vistara_db -f "D:\DataScience\Sql and powerBI proyect\sql\analytical_views.sql"
```

Verify the views were created:

```sql
\dv vistara.*
```

Expected output:

```
              List of relations
 Schema  |        Name         | Type | Owner
---------+---------------------+------+-------
 vistara | v_churn_analysis    | view | postgres
 vistara | v_monthly_revenue   | view | postgres
 vistara | v_rfm_base          | view | postgres
 vistara | v_rfm_scores        | view | postgres
 vistara | v_rfm_segments      | view | postgres
```

---

## Validation Queries

Run these queries after completing all five steps to confirm data integrity.

### Row Count Verification

```sql
SET search_path TO vistara;

SELECT 'dim_dates'            AS table_name, COUNT(*) AS row_count FROM vistara.dim_dates
UNION ALL
SELECT 'dim_sales_outlet',    COUNT(*) FROM vistara.dim_sales_outlet
UNION ALL
SELECT 'dim_customers',       COUNT(*) FROM vistara.dim_customers
UNION ALL
SELECT 'dim_products',        COUNT(*) FROM vistara.dim_products
UNION ALL
SELECT 'fact_sales_receipts', COUNT(*) FROM vistara.fact_sales_receipts
UNION ALL
SELECT 'fact_order_details',  COUNT(*) FROM vistara.fact_order_details
UNION ALL
SELECT 'fact_inventory',      COUNT(*) FROM vistara.fact_inventory
UNION ALL
SELECT 'fact_returns',        COUNT(*) FROM vistara.fact_returns
ORDER BY table_name;
```

Expected results:

| table_name | row_count |
|---|---|
| dim_customers | 10,000 |
| dim_dates | 366 |
| dim_products | 40 |
| dim_sales_outlet | 5 |
| fact_inventory | 58,560 |
| fact_order_details | 219,824 |
| fact_returns | ~5,909 |
| fact_sales_receipts | 219,824 |

### Foreign Key Integrity Check

These queries should return zero rows. Any row returned indicates an orphaned FK reference.

```sql
-- Orphaned customers (home_store not in dim_sales_outlet)
SELECT COUNT(*) AS orphaned_customers
FROM vistara.dim_customers c
WHERE NOT EXISTS (
    SELECT 1 FROM vistara.dim_sales_outlet o
    WHERE o.sales_outlet_id = c.home_store
);

-- Orphaned receipts (customer_id not in dim_customers)
SELECT COUNT(*) AS orphaned_receipts_customer
FROM vistara.fact_sales_receipts r
WHERE NOT EXISTS (
    SELECT 1 FROM vistara.dim_customers c
    WHERE c.customer_id = r.customer_id
);

-- Orphaned order details (transaction_id not in fact_sales_receipts)
SELECT COUNT(*) AS orphaned_order_details
FROM vistara.fact_order_details od
WHERE NOT EXISTS (
    SELECT 1 FROM vistara.fact_sales_receipts r
    WHERE r.transaction_id = od.transaction_id
);

-- Orphaned returns (original_transaction_id not in fact_sales_receipts)
SELECT COUNT(*) AS orphaned_returns
FROM vistara.fact_returns rt
WHERE NOT EXISTS (
    SELECT 1 FROM vistara.fact_sales_receipts r
    WHERE r.transaction_id = rt.original_transaction_id
);
```

### Analytical Views Smoke Test

```sql
-- RFM base: confirm all 10,000 customers appear
SELECT COUNT(*) AS customer_count FROM vistara.v_rfm_base;

-- RFM scores: spot-check score range (must be 1–5)
SELECT
    MIN(recency_score)   AS r_min, MAX(recency_score)   AS r_max,
    MIN(frequency_score) AS f_min, MAX(frequency_score) AS f_max,
    MIN(monetary_score)  AS m_min, MAX(monetary_score)  AS m_max
FROM vistara.v_rfm_scores;

-- RFM segments: distribution across segments
SELECT customer_segment, COUNT(*) AS customer_count
FROM vistara.v_rfm_segments
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- Churn analysis: distribution across churn statuses
SELECT churn_status, COUNT(*) AS customer_count
FROM vistara.v_churn_analysis
GROUP BY churn_status
ORDER BY customer_count DESC;

-- Monthly revenue: confirm all 12 months present
SELECT year_id, month_id, month_name, net_revenue
FROM vistara.v_monthly_revenue
ORDER BY year_id, month_id;
```

---

## Entity Relationship Overview

```
                     ┌─────────────────┐
                     │   dim_dates     │
                     │ PK: transaction_│
                     │     date        │
                     └────────┬────────┘
                              │ 1:N (transaction_date)
           ┌──────────────────┼──────────────────┐
           │                  │                  │
    ┌──────┴──────┐    ┌──────┴──────┐   ┌───────┴──────┐
    │dim_sales_   │    │fact_sales_  │   │fact_inventory│
    │outlet       │    │receipts     │   │              │
    │PK: outlet_id│◄───│FK: outlet_id│   │FK: outlet_id │
    └──────┬──────┘    │FK: customer │   │FK: product_id│
           │           │FK: product  │   │FK: date      │
           │ 1:N       │FK: date     │   └──────────────┘
    ┌──────┴──────┐    └──────┬──────┘
    │dim_customers│           │ 1:1 (transaction_id)
    │PK: cust_id  │    ┌──────┴──────┐
    │FK: home_    │    │fact_order_  │
    │    store    │    │details      │
    └──────┬──────┘    │FK: txn_id   │
           │           │FK: product  │
           │           └─────────────┘
           │ 1:N (customer_id)
    ┌──────┴──────┐    ┌─────────────┐
    │fact_returns │    │dim_products │
    │FK: cust_id  │    │PK: prod_id  │
    │FK: txn_id   │◄───┤             │
    │FK: prod_id  │    └─────────────┘
    └─────────────┘
```

**Star Schema Design:**
- `dim_` tables: dimension tables (descriptive attributes, slowly changing)
- `fact_` tables: fact tables (transactional events, high row counts)
- `fact_sales_receipts` is the central fact table joining all dimensions
- `fact_order_details` extends receipts with monetary detail (1:1 on transaction_id)
- `fact_inventory` is an independent fact (outlet × product × date grain)
- `fact_returns` links back to receipts via `original_transaction_id`

---

## Power BI Connection

Connect Power BI Desktop to PostgreSQL:

1. Get Data > PostgreSQL database
2. Server: `localhost` (or your host), Port: `5432`
3. Database: `vistara_db`
4. Data Connectivity mode: DirectQuery (for large fact tables) or Import (for smaller datasets)
5. Schema filter: `vistara`

Recommended tables/views to import for the RFM dashboard:

| Power BI Table Name | Source |
|---|---|
| RFM Segments | `vistara.v_rfm_segments` |
| Churn Analysis | `vistara.v_churn_analysis` |
| Monthly Revenue | `vistara.v_monthly_revenue` |
| Customers | `vistara.dim_customers` |
| Products | `vistara.dim_products` |
| Dates | `vistara.dim_dates` |

---

## Troubleshooting

**"password authentication failed"**
Verify the `user` and `password` in `DB_CONFIG` inside `import_data.py`. Also check `pg_hba.conf` allows password authentication for localhost.

**"database vistara_db does not exist"**
Run `CREATE DATABASE vistara_db;` in psql before executing any scripts.

**"relation vistara.dim_dates does not exist"**
Run `schema.sql` before running `import_data.py` or `analytical_views.sql`.

**Import script exits with "CSV file not found"**
Verify `DATASETS_DIR` in `import_data.py` points to the folder containing the eight CSV files.

**BOM / encoding errors in CSV**
The import script uses `encoding='utf-8-sig'` which automatically strips the UTF-8 BOM (`\xef\xbb\xbf`) present in all eight CSV files.

-- =============================================================================
-- VISTARA — Mexican Premium Clothing E-Commerce
-- indexes.sql  |  Performance indexes for RFM, Churn, and Analytical Queries
-- PostgreSQL 14+
-- =============================================================================
-- Run AFTER schema.sql and AFTER data has been imported (indexes build faster
-- on populated tables than before import for bulk loads).
-- Run with:  psql -d vistara_db -f indexes.sql
-- =============================================================================

SET search_path TO vistara;

-- ---------------------------------------------------------------------------
-- Drop existing indexes before re-creating (safe re-run)
-- ---------------------------------------------------------------------------
DROP INDEX IF EXISTS vistara.idx_receipts_customer_id;
DROP INDEX IF EXISTS vistara.idx_receipts_transaction_date;
DROP INDEX IF EXISTS vistara.idx_receipts_sales_outlet_id;
DROP INDEX IF EXISTS vistara.idx_receipts_product_id;
DROP INDEX IF EXISTS vistara.idx_receipts_order_number;
DROP INDEX IF EXISTS vistara.idx_receipts_customer_date;

DROP INDEX IF EXISTS vistara.idx_od_order_number;
DROP INDEX IF EXISTS vistara.idx_od_transaction_id;
DROP INDEX IF EXISTS vistara.idx_od_product_id;

DROP INDEX IF EXISTS vistara.idx_returns_customer_id;
DROP INDEX IF EXISTS vistara.idx_returns_return_date;
DROP INDEX IF EXISTS vistara.idx_returns_original_transaction_id;
DROP INDEX IF EXISTS vistara.idx_returns_product_id;

DROP INDEX IF EXISTS vistara.idx_inventory_outlet_product_date;
DROP INDEX IF EXISTS vistara.idx_inventory_product_id;
DROP INDEX IF EXISTS vistara.idx_inventory_date;

DROP INDEX IF EXISTS vistara.idx_customers_customer_since;
DROP INDEX IF EXISTS vistara.idx_customers_home_store;
DROP INDEX IF EXISTS vistara.idx_customers_gender;

DROP INDEX IF EXISTS vistara.idx_dates_year_month;
DROP INDEX IF EXISTS vistara.idx_dates_quarter;

-- =============================================================================
-- fact_sales_receipts  (~219 k rows)
-- Heaviest table — drives RFM recency, frequency, and churn queries.
-- =============================================================================

-- RFM: finding each customer's last purchase date and order count
CREATE INDEX idx_receipts_customer_id
    ON vistara.fact_sales_receipts (customer_id);

-- Time-based filtering for cohort, trend, and churn window queries
CREATE INDEX idx_receipts_transaction_date
    ON vistara.fact_sales_receipts (transaction_date);

-- Store-level sales analysis (Power BI store comparisons)
CREATE INDEX idx_receipts_sales_outlet_id
    ON vistara.fact_sales_receipts (sales_outlet_id);

-- Product-level sales frequency queries
CREATE INDEX idx_receipts_product_id
    ON vistara.fact_sales_receipts (product_id);

-- Basket/order reconstruction — groups all lines within an order
CREATE INDEX idx_receipts_order_number
    ON vistara.fact_sales_receipts (order_number);

-- Composite: covers the most common RFM filter pattern
--   WHERE customer_id = X  (or GROUP BY customer_id)
--   + ORDER BY / range on transaction_date
CREATE INDEX idx_receipts_customer_date
    ON vistara.fact_sales_receipts (customer_id, transaction_date DESC);

-- =============================================================================
-- fact_order_details  (~219 k rows)
-- Joined to receipts for monetary (M) dimension of RFM and discount analysis.
-- =============================================================================

-- Primary join key from receipts → order details
CREATE INDEX idx_od_order_number
    ON vistara.fact_order_details (order_number);

-- 1:1 direct join path to receipt header
CREATE INDEX idx_od_transaction_id
    ON vistara.fact_order_details (transaction_id);

-- Product-level revenue aggregations
CREATE INDEX idx_od_product_id
    ON vistara.fact_order_details (product_id);

-- =============================================================================
-- fact_returns  (~5,909 rows)
-- Used to calculate net_spend (gross - refunds) in RFM and churn views.
-- =============================================================================

-- Customer-level refund aggregation (deducted from gross spend in v_rfm_base)
CREATE INDEX idx_returns_customer_id
    ON vistara.fact_returns (customer_id);

-- Time-window queries for return rate trends
CREATE INDEX idx_returns_return_date
    ON vistara.fact_returns (return_date);

-- Linking a return back to its originating receipt (audit / drill-through)
CREATE INDEX idx_returns_original_transaction_id
    ON vistara.fact_returns (original_transaction_id);

-- Product-level return rate analysis
CREATE INDEX idx_returns_product_id
    ON vistara.fact_returns (product_id);

-- =============================================================================
-- fact_inventory  (58,560 rows)
-- Composite PK already serves as a clustered lookup; add supporting indexes.
-- =============================================================================

-- Primary analytical grain: outlet → product → date
-- (The PK index already covers this exact order; this explicit index
--  is created for clarity and to allow INCLUDE columns in the future.)
CREATE INDEX idx_inventory_outlet_product_date
    ON vistara.fact_inventory (sales_outlet_id, product_id, transaction_date);

-- Product-centric inventory drill-downs across all outlets
CREATE INDEX idx_inventory_product_id
    ON vistara.fact_inventory (product_id);

-- Date-range inventory snapshots (e.g. month-end stock reports)
CREATE INDEX idx_inventory_date
    ON vistara.fact_inventory (transaction_date);

-- =============================================================================
-- dim_customers  (10,000 rows)
-- Drives cohort segmentation by acquisition date and home store.
-- =============================================================================

-- Cohort analysis: group / filter by first purchase date
CREATE INDEX idx_customers_customer_since
    ON vistara.dim_customers (customer_since);

-- Store-affinity segmentation
CREATE INDEX idx_customers_home_store
    ON vistara.dim_customers (home_store);

-- Gender-based demographic segmentation in Power BI
CREATE INDEX idx_customers_gender
    ON vistara.dim_customers (gender);

-- =============================================================================
-- dim_dates  (366 rows — small, but used in every time-based join)
-- =============================================================================

-- Time-intelligence joins in Power BI (year + month hierarchies)
CREATE INDEX idx_dates_year_month
    ON vistara.dim_dates (year_id, month_id);

-- Quarter-level aggregations
CREATE INDEX idx_dates_quarter
    ON vistara.dim_dates (year_id, quarter_id);

-- =============================================================================
-- ANALYZE — update planner statistics after index creation
-- =============================================================================
ANALYZE vistara.dim_dates;
ANALYZE vistara.dim_sales_outlet;
ANALYZE vistara.dim_customers;
ANALYZE vistara.dim_products;
ANALYZE vistara.fact_sales_receipts;
ANALYZE vistara.fact_order_details;
ANALYZE vistara.fact_inventory;
ANALYZE vistara.fact_returns;

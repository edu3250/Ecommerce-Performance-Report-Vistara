-- =============================================================================
-- VISTARA — Mexican Premium Clothing E-Commerce
-- schema.sql  |  Full DDL — Star Schema (dim_ / fact_ naming for Power BI)
-- PostgreSQL 14+
-- =============================================================================
-- Re-runnable: drops all tables in reverse FK order before re-creating them.
-- Run with:  psql -d vistara_db -f schema.sql
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 0. Schema
-- ---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS vistara;
SET search_path TO vistara;

-- ---------------------------------------------------------------------------
-- 1. Drop tables in reverse dependency order (safe re-run)
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS vistara.fact_returns      CASCADE;
DROP TABLE IF EXISTS vistara.fact_inventory    CASCADE;
DROP TABLE IF EXISTS vistara.fact_order_details CASCADE;
DROP TABLE IF EXISTS vistara.fact_sales_receipts CASCADE;
DROP TABLE IF EXISTS vistara.dim_products      CASCADE;
DROP TABLE IF EXISTS vistara.dim_customers     CASCADE;
DROP TABLE IF EXISTS vistara.dim_sales_outlet  CASCADE;
DROP TABLE IF EXISTS vistara.dim_dates         CASCADE;

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 2. dim_dates
--    One row per calendar day covering the full data range (2024-01-01 …).
--    Acts as the time dimension for all fact tables.
-- ---------------------------------------------------------------------------
CREATE TABLE vistara.dim_dates (
    transaction_date  DATE          NOT NULL,
    date_id           INTEGER       NOT NULL,   -- YYYYMMDD integer key
    week_id           SMALLINT      NOT NULL,   -- ISO week number within year
    year_id           SMALLINT      NOT NULL,
    month_id          SMALLINT      NOT NULL,   -- 1–12
    month_name        VARCHAR(20)   NOT NULL,   -- Spanish month name, e.g. 'Enero'
    quarter_id        SMALLINT      NOT NULL,   -- 1–4
    quarter_name      VARCHAR(20)   NOT NULL,   -- e.g. 'T1 2024'

    CONSTRAINT pk_dim_dates PRIMARY KEY (transaction_date)
);

COMMENT ON TABLE vistara.dim_dates IS
    'Calendar dimension — one row per day. Used to join all fact tables on transaction_date.';
COMMENT ON COLUMN vistara.dim_dates.transaction_date IS
    'Natural date key (YYYY-MM-DD). PK and FK target for all fact tables.';
COMMENT ON COLUMN vistara.dim_dates.date_id IS
    'Integer surrogate in YYYYMMDD format, useful for range filters in Power BI.';
COMMENT ON COLUMN vistara.dim_dates.quarter_name IS
    'Human-readable quarter label in Spanish, e.g. "T1 2024".';

-- ---------------------------------------------------------------------------
-- 3. dim_sales_outlet
--    Physical or online store locations (5 outlets).
-- ---------------------------------------------------------------------------
CREATE TABLE vistara.dim_sales_outlet (
    sales_outlet_id    VARCHAR(20)  NOT NULL,
    sales_outlet_type  VARCHAR(50)  NOT NULL,   -- 'Retail', 'Online', etc.
    store_city         VARCHAR(100) NOT NULL,
    store_postal_code  VARCHAR(10)  NOT NULL,

    CONSTRAINT pk_dim_sales_outlet PRIMARY KEY (sales_outlet_id)
);

COMMENT ON TABLE vistara.dim_sales_outlet IS
    'Sales channel / store dimension. Each row represents a physical retail location or online channel.';
COMMENT ON COLUMN vistara.dim_sales_outlet.sales_outlet_id IS
    'Natural PK, format OUT-NNN. Referenced by dim_customers.home_store and all fact tables.';
COMMENT ON COLUMN vistara.dim_sales_outlet.sales_outlet_type IS
    'Channel type: Retail, Online, Pop-up, etc.';

-- ---------------------------------------------------------------------------
-- 4. dim_customers
--    10,000 registered VISTARA customers.
-- ---------------------------------------------------------------------------
CREATE TABLE vistara.dim_customers (
    customer_id          VARCHAR(20)  NOT NULL,
    home_store           VARCHAR(20)  NOT NULL,   -- FK → dim_sales_outlet
    customer_first_name  VARCHAR(100) NOT NULL,
    customer_since       DATE         NOT NULL,   -- acquisition / registration date
    gender               CHAR(1)      NOT NULL,   -- 'M' | 'F'

    CONSTRAINT pk_dim_customers PRIMARY KEY (customer_id),
    CONSTRAINT fk_customers_home_store
        FOREIGN KEY (home_store)
        REFERENCES vistara.dim_sales_outlet (sales_outlet_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON TABLE vistara.dim_customers IS
    'Customer master dimension. Contains demographic and acquisition data for the 10,000 registered customers.';
COMMENT ON COLUMN vistara.dim_customers.customer_id IS
    'Natural PK, format CUST-NNNNN. Used across all fact tables for customer-level analysis.';
COMMENT ON COLUMN vistara.dim_customers.home_store IS
    'Preferred or registration store. FK → dim_sales_outlet.';
COMMENT ON COLUMN vistara.dim_customers.customer_since IS
    'Date the customer first registered. Used for cohort and tenure analysis.';
COMMENT ON COLUMN vistara.dim_customers.gender IS
    'Single-char gender code: M = Male, F = Female.';

-- ---------------------------------------------------------------------------
-- 5. dim_products
--    40 VISTARA product SKUs.
-- ---------------------------------------------------------------------------
CREATE TABLE vistara.dim_products (
    product_id        VARCHAR(20)   NOT NULL,
    product_category  VARCHAR(100)  NOT NULL,   -- e.g. 'Ropa Casual', 'Accesorios'
    product_type      VARCHAR(100)  NOT NULL,   -- e.g. 'Playera', 'Pantalón'
    product_name      VARCHAR(200)  NOT NULL,
    color             VARCHAR(100)  NOT NULL,
    current_price     NUMERIC(10,2) NOT NULL,   -- MXN, list price

    CONSTRAINT pk_dim_products PRIMARY KEY (product_id),
    CONSTRAINT chk_products_price CHECK (current_price >= 0)
);

COMMENT ON TABLE vistara.dim_products IS
    'Product catalogue dimension — 40 premium clothing SKUs with category, type, and current list price in MXN.';
COMMENT ON COLUMN vistara.dim_products.product_id IS
    'Natural PK, format PROD-NNN.';
COMMENT ON COLUMN vistara.dim_products.current_price IS
    'Current list price in Mexican Pesos (MXN). Historical transaction prices are stored in fact_order_details.unit_price.';

-- =============================================================================
-- FACT TABLES
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 6. fact_sales_receipts
--    ~219,824 transaction header rows — one row per item purchased per receipt.
--    (Each order_number groups one or more TXN rows, one per product line.)
-- ---------------------------------------------------------------------------
CREATE TABLE vistara.fact_sales_receipts (
    transaction_id    VARCHAR(20)  NOT NULL,
    transaction_date  DATE         NOT NULL,   -- FK → dim_dates
    transaction_time  TIME         NOT NULL,
    sales_outlet_id   VARCHAR(20)  NOT NULL,   -- FK → dim_sales_outlet
    customer_id       VARCHAR(20)  NOT NULL,   -- FK → dim_customers
    order_number      VARCHAR(30)  NOT NULL,   -- logical grouping key for the basket
    product_id        VARCHAR(20)  NOT NULL,   -- FK → dim_products

    CONSTRAINT pk_fact_sales_receipts PRIMARY KEY (transaction_id),
    CONSTRAINT fk_receipts_date
        FOREIGN KEY (transaction_date)
        REFERENCES vistara.dim_dates (transaction_date)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_receipts_outlet
        FOREIGN KEY (sales_outlet_id)
        REFERENCES vistara.dim_sales_outlet (sales_outlet_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_receipts_customer
        FOREIGN KEY (customer_id)
        REFERENCES vistara.dim_customers (customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_receipts_product
        FOREIGN KEY (product_id)
        REFERENCES vistara.dim_products (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON TABLE vistara.fact_sales_receipts IS
    'Transaction header fact — one row per product line per receipt (~219 k rows). '
    'Links customer, date, outlet, and product. Monetary detail lives in fact_order_details.';
COMMENT ON COLUMN vistara.fact_sales_receipts.transaction_id IS
    'Natural PK, format TXN-NNNNNN.';
COMMENT ON COLUMN vistara.fact_sales_receipts.order_number IS
    'Basket identifier — groups all transaction lines that belong to one customer visit / cart.';

-- ---------------------------------------------------------------------------
-- 7. fact_order_details
--    ~219,824 rows — monetary detail for each transaction line.
--    Joined 1:1 with fact_sales_receipts via (order_number, transaction_id).
-- ---------------------------------------------------------------------------
CREATE TABLE vistara.fact_order_details (
    order_detail_id  VARCHAR(20)   NOT NULL,
    order_number     VARCHAR(30)   NOT NULL,   -- FK → fact_sales_receipts.order_number (logical)
    transaction_id   VARCHAR(20)   NOT NULL,   -- FK → fact_sales_receipts
    product_id       VARCHAR(20)   NOT NULL,   -- FK → dim_products (denormalised for query speed)
    quantity         INTEGER       NOT NULL    DEFAULT 1,
    unit_price       NUMERIC(10,2) NOT NULL,   -- MXN, price at time of sale (may differ from list)
    discount_pct     NUMERIC(5,4)  NOT NULL    DEFAULT 0,  -- 0.0000 – 1.0000
    line_total       NUMERIC(10,2) NOT NULL,   -- quantity * unit_price * (1 - discount_pct)

    CONSTRAINT pk_fact_order_details PRIMARY KEY (order_detail_id),
    CONSTRAINT fk_od_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES vistara.fact_sales_receipts (transaction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_od_product
        FOREIGN KEY (product_id)
        REFERENCES vistara.dim_products (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_od_quantity   CHECK (quantity > 0),
    CONSTRAINT chk_od_unit_price CHECK (unit_price >= 0),
    CONSTRAINT chk_od_discount   CHECK (discount_pct BETWEEN 0 AND 1),
    CONSTRAINT chk_od_line_total CHECK (line_total >= 0)
);

COMMENT ON TABLE vistara.fact_order_details IS
    'Transaction line-item fact — quantities, prices, discounts, and computed line totals. '
    'Joined to fact_sales_receipts 1:1 on transaction_id for full monetary analysis.';
COMMENT ON COLUMN vistara.fact_order_details.unit_price IS
    'Actual selling price at the time of the transaction in MXN (may differ from dim_products.current_price due to promotions).';
COMMENT ON COLUMN vistara.fact_order_details.discount_pct IS
    'Fractional discount applied (0.20 = 20%). Used to calculate promotional impact.';
COMMENT ON COLUMN vistara.fact_order_details.line_total IS
    'Pre-computed net line value: quantity * unit_price * (1 - discount_pct).';

-- ---------------------------------------------------------------------------
-- 8. fact_inventory
--    58,560 rows — daily stock snapshot per outlet × product combination.
-- ---------------------------------------------------------------------------
CREATE TABLE vistara.fact_inventory (
    sales_outlet_id    VARCHAR(20)   NOT NULL,   -- FK → dim_sales_outlet
    transaction_date   DATE          NOT NULL,   -- FK → dim_dates
    product_id         VARCHAR(20)   NOT NULL,   -- FK → dim_products
    start_of_day_qty   INTEGER       NOT NULL    DEFAULT 0,
    quantity_sold      INTEGER       NOT NULL    DEFAULT 0,
    waste              INTEGER       NOT NULL    DEFAULT 0,
    waste_pct          NUMERIC(5,4)  NOT NULL    DEFAULT 0,  -- waste / start_of_day_qty

    CONSTRAINT pk_fact_inventory
        PRIMARY KEY (sales_outlet_id, transaction_date, product_id),
    CONSTRAINT fk_inv_outlet
        FOREIGN KEY (sales_outlet_id)
        REFERENCES vistara.dim_sales_outlet (sales_outlet_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inv_date
        FOREIGN KEY (transaction_date)
        REFERENCES vistara.dim_dates (transaction_date)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inv_product
        FOREIGN KEY (product_id)
        REFERENCES vistara.dim_products (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_inv_start_qty  CHECK (start_of_day_qty >= 0),
    CONSTRAINT chk_inv_qty_sold   CHECK (quantity_sold >= 0),
    CONSTRAINT chk_inv_waste      CHECK (waste >= 0),
    CONSTRAINT chk_inv_waste_pct  CHECK (waste_pct BETWEEN 0 AND 1)
);

COMMENT ON TABLE vistara.fact_inventory IS
    'Daily inventory snapshot fact — opening stock, units sold, and shrinkage/waste '
    'for each (outlet, product, date) combination. Composite PK enforces one row per grain.';
COMMENT ON COLUMN vistara.fact_inventory.start_of_day_qty IS
    'Units on hand at the start of the business day.';
COMMENT ON COLUMN vistara.fact_inventory.waste_pct IS
    'Fractional waste rate relative to opening stock (0.0500 = 5%).';

-- ---------------------------------------------------------------------------
-- 9. fact_returns
--    ~5,909 rows — product return / refund events.
-- ---------------------------------------------------------------------------
CREATE TABLE vistara.fact_returns (
    return_id               VARCHAR(20)   NOT NULL,
    original_transaction_id VARCHAR(20)   NOT NULL,   -- FK → fact_sales_receipts
    original_order_number   VARCHAR(30)   NOT NULL,
    customer_id             VARCHAR(20)   NOT NULL,   -- FK → dim_customers
    product_id              VARCHAR(20)   NOT NULL,   -- FK → dim_products
    return_date             DATE          NOT NULL,
    return_reason           VARCHAR(200)  NOT NULL,   -- e.g. 'Talla incorrecta'
    refund_amount           NUMERIC(10,2) NOT NULL,   -- MXN
    return_type             VARCHAR(100)  NOT NULL,   -- 'Cambio de producto', 'Reembolso', etc.

    CONSTRAINT pk_fact_returns PRIMARY KEY (return_id),
    CONSTRAINT fk_returns_transaction
        FOREIGN KEY (original_transaction_id)
        REFERENCES vistara.fact_sales_receipts (transaction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_returns_customer
        FOREIGN KEY (customer_id)
        REFERENCES vistara.dim_customers (customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_returns_product
        FOREIGN KEY (product_id)
        REFERENCES vistara.dim_products (product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_returns_refund CHECK (refund_amount >= 0)
);

COMMENT ON TABLE vistara.fact_returns IS
    'Return and refund event fact — links each return to its originating transaction, '
    'customer, and product. Refund amounts are used to compute net spend in RFM views.';
COMMENT ON COLUMN vistara.fact_returns.return_reason IS
    'Reason code as recorded at point of return, in Spanish (e.g. "Talla incorrecta", "Defecto de fábrica").';
COMMENT ON COLUMN vistara.fact_returns.refund_amount IS
    'Actual MXN amount refunded to the customer for this return event.';
COMMENT ON COLUMN vistara.fact_returns.return_type IS
    'Disposition category: "Cambio de producto" (exchange) or "Reembolso" (cash/card refund).';

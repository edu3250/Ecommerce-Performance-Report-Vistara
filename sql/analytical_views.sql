-- =============================================================================
-- VISTARA — Mexican Premium Clothing E-Commerce
-- analytical_views.sql  |  Pre-built Views for RFM & Churn Analysis
-- PostgreSQL 14+
-- =============================================================================
-- Reference date for recency calculations: 2025-01-01
--   (one day after the last transaction date in the dataset)
-- =============================================================================
-- Run with:  psql -d vistara_db -f analytical_views.sql
-- Run AFTER schema.sql, indexes.sql, and import_data.py
-- =============================================================================

SET search_path TO vistara;

-- ---------------------------------------------------------------------------
-- Drop views in reverse dependency order (safe re-run)
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS vistara.v_monthly_revenue;
DROP VIEW IF EXISTS vistara.v_churn_analysis;
DROP VIEW IF EXISTS vistara.v_rfm_segments;
DROP VIEW IF EXISTS vistara.v_rfm_scores;
DROP VIEW IF EXISTS vistara.v_rfm_base;

-- =============================================================================
-- VIEW 1: v_rfm_base
-- Per-customer aggregation of recency, frequency, and monetary raw values.
-- Reference date: 2025-01-01 (one day after last transaction in dataset).
-- =============================================================================
CREATE OR REPLACE VIEW vistara.v_rfm_base AS
WITH customer_spend AS (
    -- Gross spend per customer: sum of all order line totals
    SELECT
        r.customer_id,
        SUM(od.line_total)  AS gross_spend,
        COUNT(DISTINCT r.order_number)     AS total_orders,
        SUM(od.quantity)    AS total_items,
        MAX(r.transaction_date)            AS last_purchase_date,
        MIN(r.transaction_date)            AS first_purchase_date
    FROM vistara.fact_sales_receipts r
    INNER JOIN vistara.fact_order_details od
        ON od.transaction_id = r.transaction_id
    GROUP BY r.customer_id
),
customer_refunds AS (
    -- Total refunds per customer (to derive net spend)
    SELECT
        customer_id,
        COALESCE(SUM(refund_amount), 0) AS total_refunds
    FROM vistara.fact_returns
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_first_name                               AS first_name,
    c.gender,
    c.customer_since,
    cs.last_purchase_date,
    cs.first_purchase_date,
    cs.total_orders,
    cs.total_items,
    ROUND(cs.gross_spend,   2)                          AS gross_spend,
    ROUND(COALESCE(cr.total_refunds, 0), 2)             AS total_refunds,
    ROUND(cs.gross_spend - COALESCE(cr.total_refunds, 0), 2) AS net_spend,
    -- Recency: number of days between last purchase and reference date 2025-01-01
    (DATE '2025-01-01' - cs.last_purchase_date)::INTEGER AS days_since_last_purchase
FROM vistara.dim_customers c
INNER JOIN customer_spend cs
    ON cs.customer_id = c.customer_id
LEFT JOIN customer_refunds cr
    ON cr.customer_id = c.customer_id;

COMMENT ON VIEW vistara.v_rfm_base IS
    'Base RFM aggregation per customer: last purchase date, total orders, total items, '
    'gross spend, refunds, net spend, and days since last purchase relative to 2025-01-01.';

-- =============================================================================
-- VIEW 2: v_rfm_scores
-- Applies NTILE(5) quintile scoring to recency, frequency, and monetary raw values.
-- Recency is inverted: a LOWER days_since_last_purchase => HIGHER recency score.
-- =============================================================================
CREATE OR REPLACE VIEW vistara.v_rfm_scores AS
SELECT
    base.*,

    -- Recency score: 5 = bought most recently, 1 = bought least recently
    -- NTILE on ascending days gives 1=most recent, so we invert with (6 - ntile).
    (6 - NTILE(5) OVER (ORDER BY days_since_last_purchase ASC))::SMALLINT
        AS recency_score,

    -- Frequency score: 5 = highest order count
    NTILE(5) OVER (ORDER BY total_orders ASC)::SMALLINT
        AS frequency_score,

    -- Monetary score: 5 = highest net spend
    NTILE(5) OVER (ORDER BY net_spend ASC)::SMALLINT
        AS monetary_score,

    -- Concatenated RFM score string for segment mapping, e.g. '555', '432', '111'
    CONCAT(
        (6 - NTILE(5) OVER (ORDER BY days_since_last_purchase ASC))::TEXT,
        NTILE(5) OVER (ORDER BY total_orders ASC)::TEXT,
        NTILE(5) OVER (ORDER BY net_spend ASC)::TEXT
    ) AS rfm_score

FROM vistara.v_rfm_base AS base;

COMMENT ON VIEW vistara.v_rfm_scores IS
    'Adds NTILE(5) RFM quintile scores (1–5) to each customer. '
    'recency_score=5 means most recent buyer; frequency_score=5 and monetary_score=5 '
    'mean top-tier purchaser and spender respectively. rfm_score is the three-digit concatenation.';

-- =============================================================================
-- VIEW 3: v_rfm_segments
-- Maps RFM score combinations to named business segments for Power BI labelling.
-- Segment priority matters: evaluated top-to-bottom (CASE statement order).
-- =============================================================================
CREATE OR REPLACE VIEW vistara.v_rfm_segments AS
SELECT
    scores.*,
    CASE
        -- Champions: bought recently, buy often, spend the most
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4
            THEN 'Champions'

        -- Loyal Customers: high frequency and solid spend, recency not required
        WHEN frequency_score >= 4 AND monetary_score >= 3
            THEN 'Loyal Customers'

        -- Potential Loyalists: relatively recent and starting to buy regularly
        WHEN recency_score >= 3 AND frequency_score >= 2
            THEN 'Potential Loyalists'

        -- New Customers: bought very recently but only once or twice
        WHEN recency_score >= 4 AND frequency_score <= 1
            THEN 'New Customers'

        -- At Risk: used to buy often but have not returned recently
        WHEN recency_score <= 2 AND frequency_score >= 3
            THEN 'At Risk'

        -- Hibernating: low recency and low frequency — disengaged
        WHEN recency_score <= 2 AND frequency_score <= 2
            THEN 'Hibernating'

        -- Lost: worst across all three dimensions
        WHEN recency_score = 1 AND frequency_score = 1 AND monetary_score = 1
            THEN 'Lost'

        -- Catch-all for any remaining combination
        ELSE 'Others'
    END AS customer_segment

FROM vistara.v_rfm_scores AS scores;

COMMENT ON VIEW vistara.v_rfm_segments IS
    'Final RFM segmentation view. Adds customer_segment label (Champions, Loyal Customers, '
    'Potential Loyalists, New Customers, At Risk, Hibernating, Lost, Others) derived from '
    'recency_score, frequency_score, and monetary_score. Intended as the primary Power BI source '
    'for customer segmentation visuals.';

-- =============================================================================
-- VIEW 4: v_churn_analysis
-- Classifies each customer as Active, At Risk, or Churned based on purchase
-- recency relative to the reference date 2025-01-01.
--   Active    : last purchase within 90 days  (>= 2024-10-03)
--   At Risk   : last purchase 91–180 days ago (between 2024-07-05 and 2024-10-02)
--   Churned   : last purchase > 180 days ago  (< 2024-07-05)
-- =============================================================================
CREATE OR REPLACE VIEW vistara.v_churn_analysis AS
WITH customer_activity AS (
    SELECT
        r.customer_id,
        COUNT(DISTINCT r.order_number)                  AS total_orders,
        SUM(od.line_total)                              AS gross_spend,
        MAX(r.transaction_date)                         AS last_purchase_date
    FROM vistara.fact_sales_receipts r
    INNER JOIN vistara.fact_order_details od
        ON od.transaction_id = r.transaction_id
    GROUP BY r.customer_id
),
customer_refunds AS (
    SELECT
        customer_id,
        COALESCE(SUM(refund_amount), 0) AS total_refunds
    FROM vistara.fact_returns
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_first_name                                           AS first_name,
    c.gender,
    c.customer_since,

    -- Acquisition quarter: e.g. 'T1 2024', 'T2 2024'
    -- Derived from the calendar dimension for the customer's registration date
    d.quarter_name                                                  AS acquisition_quarter,

    ca.last_purchase_date,
    (DATE '2025-01-01' - ca.last_purchase_date)::INTEGER           AS days_since_last_purchase,

    -- Churn classification based on recency windows
    CASE
        WHEN (DATE '2025-01-01' - ca.last_purchase_date) <= 90
            THEN 'Active'
        WHEN (DATE '2025-01-01' - ca.last_purchase_date) BETWEEN 91 AND 180
            THEN 'At Risk'
        ELSE 'Churned'
    END                                                             AS churn_status,

    ca.total_orders,
    ROUND(ca.gross_spend - COALESCE(cr.total_refunds, 0), 2)       AS net_spend,

    -- Tenure: full months between registration and last purchase
    -- DATE - DATE returns INTEGER days in PostgreSQL; divide by 30 to get months.
    FLOOR(
        (ca.last_purchase_date - c.customer_since) / 30.0
    )::INTEGER                                                      AS months_active

FROM vistara.dim_customers c
INNER JOIN customer_activity ca
    ON ca.customer_id = c.customer_id
LEFT JOIN customer_refunds cr
    ON cr.customer_id = c.customer_id
-- Join the date dimension on customer_since to get the acquisition quarter label
LEFT JOIN vistara.dim_dates d
    ON d.transaction_date = c.customer_since;

COMMENT ON VIEW vistara.v_churn_analysis IS
    'Churn risk classification per customer. '
    'churn_status: Active (<=90 days since last purchase), '
    'At Risk (91–180 days), Churned (>180 days), relative to reference date 2025-01-01. '
    'Includes acquisition_quarter, lifetime net_spend, and months_active for cohort analysis.';

-- =============================================================================
-- VIEW 5: v_monthly_revenue
-- Monthly revenue summary joining receipts, order details, dates, and returns.
-- Designed for trend line and time-intelligence visuals in Power BI.
-- =============================================================================
CREATE OR REPLACE VIEW vistara.v_monthly_revenue AS
WITH monthly_sales AS (
    -- Aggregate gross sales metrics per year-month
    SELECT
        d.year_id,
        d.month_id,
        d.month_name,
        d.quarter_name,
        COUNT(DISTINCT r.transaction_id)            AS total_transactions,
        COUNT(DISTINCT r.customer_id)               AS unique_customers,
        SUM(od.quantity)                            AS total_items_sold,
        ROUND(SUM(od.line_total), 2)                AS gross_revenue,
        -- Discount value = unit_price * quantity * discount_pct
        ROUND(
            SUM(od.unit_price * od.quantity * od.discount_pct),
        2)                                          AS total_discounts
    FROM vistara.fact_sales_receipts r
    INNER JOIN vistara.fact_order_details od
        ON od.transaction_id = r.transaction_id
    INNER JOIN vistara.dim_dates d
        ON d.transaction_date = r.transaction_date
    GROUP BY
        d.year_id, d.month_id, d.month_name, d.quarter_name
),
monthly_refunds AS (
    -- Aggregate refund amounts per year-month based on the return_date
    SELECT
        d.year_id,
        d.month_id,
        ROUND(SUM(rt.refund_amount), 2) AS total_refunds
    FROM vistara.fact_returns rt
    INNER JOIN vistara.dim_dates d
        ON d.transaction_date = rt.return_date
    GROUP BY d.year_id, d.month_id
)
SELECT
    ms.year_id,
    ms.month_id,
    ms.month_name,
    ms.quarter_name,
    ms.total_transactions,
    ms.unique_customers,
    ms.total_items_sold,
    ms.gross_revenue,
    ms.total_discounts,
    COALESCE(mr.total_refunds, 0)                          AS total_refunds,
    ROUND(
        ms.gross_revenue - COALESCE(mr.total_refunds, 0),
    2)                                                     AS net_revenue,
    -- Average order value: net revenue divided by number of transactions
    ROUND(
        (ms.gross_revenue - COALESCE(mr.total_refunds, 0))
        / NULLIF(ms.total_transactions, 0),
    2)                                                     AS avg_order_value
FROM monthly_sales ms
LEFT JOIN monthly_refunds mr
    ON mr.year_id = ms.year_id
   AND mr.month_id = ms.month_id
ORDER BY ms.year_id ASC, ms.month_id ASC;

COMMENT ON VIEW vistara.v_monthly_revenue IS
    'Monthly revenue summary for trend analysis and Power BI time-intelligence visuals. '
    'Columns: year_id, month_id, month_name, quarter_name, total_transactions, unique_customers, '
    'total_items_sold, gross_revenue, total_discounts, total_refunds, net_revenue, avg_order_value. '
    'Refunds are matched on return_date (the month the refund was issued, not the original sale month).';

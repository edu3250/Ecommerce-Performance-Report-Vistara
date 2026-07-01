CREATE OR REPLACE VIEW vistara.v_daily_revenue AS

WITH daily_sales AS (
    SELECT
        sr.transaction_date,
        SUM(od.quantity * od.unit_price)                    AS gross_revenue,
        SUM(od.quantity * od.unit_price * od.discount_pct)  AS total_discounts,
        SUM(od.line_total)                                  AS net_sales,
        COUNT(DISTINCT sr.transaction_id)                   AS total_transactions,
        COUNT(DISTINCT sr.customer_id)                      AS unique_customers
    FROM vistara.fact_sales_receipts sr
    JOIN vistara.fact_order_details od
        ON sr.transaction_id = od.transaction_id
    GROUP BY sr.transaction_date
),

daily_returns AS (
    SELECT
        return_date,
        SUM(refund_amount) AS total_refunds
    FROM vistara.fact_returns
    GROUP BY return_date
)

SELECT
    dd.transaction_date,
    dd.date_id,
    dd.month_id,
    dd.year_id,
    dd.month_name,
    dd.quarter_name,
    COALESCE(ds.gross_revenue,      0)  AS gross_revenue,
    COALESCE(ds.total_discounts,    0)  AS total_discounts,
    COALESCE(dr.total_refunds,      0)  AS total_refunds,
    COALESCE(ds.net_sales,          0)
        - COALESCE(dr.total_refunds, 0) AS net_revenue,
    COALESCE(ds.total_transactions, 0)  AS total_transactions,
    COALESCE(ds.unique_customers,   0)  AS unique_customers
FROM vistara.dim_dates dd
LEFT JOIN daily_sales   ds ON dd.transaction_date = ds.transaction_date
LEFT JOIN daily_returns dr ON dd.transaction_date = dr.return_date
ORDER BY dd.transaction_date;
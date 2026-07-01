CREATE OR REPLACE VIEW vistara.v_cohort_retention AS

WITH customer_cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(transaction_date))::DATE AS cohort_month
    FROM vistara.fact_sales_receipts
    GROUP BY customer_id
),
customer_activity AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', transaction_date)::DATE AS activity_month
    FROM vistara.fact_sales_receipts
),
cohort_activity AS (
    SELECT
        cc.cohort_month,
        ca.activity_month,
        cc.customer_id,
        (EXTRACT(YEAR  FROM AGE(ca.activity_month, cc.cohort_month)) * 12 +
         EXTRACT(MONTH FROM AGE(ca.activity_month, cc.cohort_month)))::INT AS month_number
    FROM customer_cohorts cc
    JOIN customer_activity ca
        ON  cc.customer_id   = ca.customer_id
        AND ca.activity_month >= cc.cohort_month
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    TO_CHAR(ca.cohort_month, 'YYYY-MM') AS cohort_label,
    cs.cohort_size,
    ca.month_number,
    COUNT(DISTINCT ca.customer_id)                                    AS retained_customers,
    ROUND(COUNT(DISTINCT ca.customer_id)::NUMERIC / cs.cohort_size * 100, 1) AS retention_pct
FROM cohort_activity  ca
JOIN cohort_sizes     cs ON ca.cohort_month = cs.cohort_month
GROUP BY ca.cohort_month, ca.month_number, cs.cohort_size
ORDER BY ca.cohort_month, ca.month_number;
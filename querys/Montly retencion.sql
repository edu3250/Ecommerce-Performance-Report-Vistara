CREATE OR REPLACE VIEW vistara.v_monthly_retention AS

WITH monthly_customers AS (
    -- Paso 1: un registro por cliente por mes que compró
    SELECT DISTINCT
        DATE_TRUNC('month', transaction_date)::DATE AS month_start,
        customer_id
    FROM vistara.fact_sales_receipts
),

tagged AS (
    -- Paso 2: para cada cliente-mes, ¿también compró el mes anterior?
    SELECT
        curr.month_start,
        curr.customer_id,
        CASE
            WHEN prev.customer_id IS NOT NULL THEN 'Retained'
            ELSE 'New'
        END AS customer_type
    FROM monthly_customers curr
    LEFT JOIN monthly_customers prev
        ON  curr.customer_id  = prev.customer_id
        AND prev.month_start  = curr.month_start - INTERVAL '1 month'
),

monthly_agg AS (
    -- Paso 3: agrega por mes
    SELECT
        month_start,
        EXTRACT(YEAR  FROM month_start)::INT  AS year_id,
        EXTRACT(MONTH FROM month_start)::INT  AS month_id,
        TO_CHAR(month_start, 'FMMonth')       AS month_name,
        COUNT(DISTINCT customer_id)                                              AS active_customers,
        COUNT(DISTINCT CASE WHEN customer_type = 'Retained' THEN customer_id END) AS retained_customers,
        COUNT(DISTINCT CASE WHEN customer_type = 'New'      THEN customer_id END) AS new_customers
    FROM tagged
    GROUP BY month_start
)

SELECT
    month_start,
    year_id,
    month_id,
    month_name,
    active_customers,
    retained_customers,
    new_customers,
    -- Retenidos este mes / activos el mes anterior
    ROUND(
        retained_customers::NUMERIC /
        NULLIF(LAG(active_customers) OVER (ORDER BY month_start), 0) * 100,
        2
    ) AS retention_rate_pct,
    -- Clientes nuevos / activos totales este mes
    ROUND(
        new_customers::NUMERIC / NULLIF(active_customers, 0) * 100,
        2
    ) AS new_customer_rate_pct
FROM monthly_agg
ORDER BY month_start;

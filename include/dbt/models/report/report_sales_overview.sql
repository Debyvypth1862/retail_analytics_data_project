WITH daily_sales AS (
    SELECT
        dt.date,
        COUNT(DISTINCT fi.invoice_id) as total_transactions,
        COUNT(DISTINCT fi.customer_id) as total_customers,
        SUM(fi.total) as total_revenue
    FROM {{ ref('fct_invoices') }} fi
    JOIN {{ ref('dim_datetime') }} dt ON fi.datetime_id = dt.datetime_id
    GROUP BY dt.date
),
country_sales AS (
    SELECT
        c.country,
        c.iso,
        COUNT(DISTINCT fi.invoice_id) as total_transactions,
        COUNT(DISTINCT fi.customer_id) as total_customers,
        SUM(fi.total) as total_revenue
    FROM {{ ref('fct_invoices') }} fi
    JOIN {{ ref('dim_customer') }} c ON fi.customer_id = c.customer_id
    GROUP BY c.country, c.iso
)
SELECT 
    'Daily' as granularity,
    date as time_period,
    NULL as country,
    NULL as iso,
    total_transactions,
    total_customers,
    total_revenue
FROM daily_sales
UNION ALL
SELECT
    'Country' as granularity,
    NULL as time_period,
    country,
    iso,
    total_transactions,
    total_customers,
    total_revenue
FROM country_sales
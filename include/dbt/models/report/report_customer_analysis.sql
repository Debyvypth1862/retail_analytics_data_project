WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.country,
        COUNT(DISTINCT fi.invoice_id) as total_transactions,
        SUM(fi.quantity) as total_items,
        SUM(fi.total) as total_revenue,
        SUM(fi.quantity) / COUNT(DISTINCT fi.invoice_id) as avg_basket_size,
        COUNT(DISTINCT dt.month || '-' || dt.year) as months_active
    FROM {{ ref('fct_invoices') }} fi
    JOIN {{ ref('dim_customer') }} c ON fi.customer_id = c.customer_id
    JOIN {{ ref('dim_datetime') }} dt ON fi.datetime_id = dt.datetime_id
    GROUP BY c.customer_id, c.country
),
customer_segments AS (
    SELECT
        customer_id,
        country,
        total_transactions,
        total_items,
        total_revenue,
        avg_basket_size,
        months_active,
        CASE 
            WHEN months_active >= 6 THEN 'Loyal'
            WHEN months_active >= 3 THEN 'Regular'
            ELSE 'New'
        END as customer_segment
    FROM customer_metrics
)
SELECT 
    cs.*,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank
FROM customer_segments cs
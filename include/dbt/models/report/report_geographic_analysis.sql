WITH country_metrics AS (
    SELECT
        c.country,
        c.iso,
        p.description as product_description,
        p.stock_code,
        COUNT(DISTINCT fi.invoice_id) as num_transactions,
        COUNT(DISTINCT fi.customer_id) as num_customers,
        SUM(fi.quantity) as total_quantity,
        SUM(fi.total) as total_revenue,
        AVG(fi.total) as avg_transaction_value
    FROM {{ ref('fct_invoices') }} fi
    JOIN {{ ref('dim_customer') }} c ON fi.customer_id = c.customer_id
    JOIN {{ ref('dim_product') }} p ON fi.product_id = p.product_id
    GROUP BY c.country, c.iso, p.description, p.stock_code
),
country_rankings AS (
    SELECT
        country,
        iso,
        SUM(total_revenue) as country_revenue,
        COUNT(DISTINCT product_description) as unique_products,
        SUM(num_customers) as total_customers,
        RANK() OVER (ORDER BY SUM(total_revenue) DESC) as revenue_rank
    FROM country_metrics
    GROUP BY country, iso
),
top_products_by_country AS (
    SELECT 
        country,
        product_description,
        total_revenue,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_revenue DESC) as product_rank
    FROM country_metrics
)
SELECT 
    cr.*,
    STRING_AGG(tp.product_description, ', ') as top_3_products
FROM country_rankings cr
LEFT JOIN top_products_by_country tp 
    ON cr.country = tp.country 
    AND tp.product_rank <= 3
GROUP BY 
    cr.country,
    cr.iso,
    cr.country_revenue,
    cr.unique_products,
    cr.total_customers,
    cr.revenue_rank
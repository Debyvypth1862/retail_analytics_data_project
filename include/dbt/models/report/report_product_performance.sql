WITH product_metrics AS (
    SELECT
        p.product_id,
        p.stock_code,
        p.description,
        c.country,
        SUM(fi.quantity) as total_quantity,
        SUM(fi.total) as total_revenue,
        AVG(p.unit_price) as avg_unit_price,
        COUNT(DISTINCT fi.invoice_id) as number_of_sales
    FROM {{ ref('fct_invoices') }} fi
    JOIN {{ ref('dim_product') }} p ON fi.product_id = p.product_id
    JOIN {{ ref('dim_customer') }} c ON fi.customer_id = c.customer_id
    GROUP BY p.product_id, p.stock_code, p.description, c.country
),
product_summary AS (
    SELECT
        product_id,
        stock_code,
        description,
        SUM(total_quantity) as total_quantity,
        SUM(total_revenue) as total_revenue,
        AVG(avg_unit_price) as avg_unit_price,
        SUM(number_of_sales) as total_sales,
        COUNT(DISTINCT country) as countries_sold
    FROM product_metrics
    GROUP BY product_id, stock_code, description
)
SELECT 
    ps.*,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) as revenue_rank,
    DENSE_RANK() OVER (ORDER BY total_quantity DESC) as quantity_rank
FROM product_summary ps
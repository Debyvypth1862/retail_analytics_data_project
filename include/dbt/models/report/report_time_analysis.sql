WITH hourly_metrics AS (
    SELECT
        dt.hour_of_day,
        dt.day_of_week,
        dt.month,
        dt.year,
        COUNT(DISTINCT fi.invoice_id) as num_transactions,
        COUNT(DISTINCT fi.customer_id) as num_customers,
        SUM(fi.quantity) as total_items,
        SUM(fi.total) as total_revenue,
        AVG(fi.total) as avg_transaction_value
    FROM {{ ref('fct_invoices') }} fi
    JOIN {{ ref('dim_datetime') }} dt ON fi.datetime_id = dt.datetime_id
    GROUP BY dt.hour_of_day, dt.day_of_week, dt.month, dt.year
),
time_aggregates AS (
    SELECT
        hour_of_day,
        day_of_week,
        month,
        year,
        num_transactions,
        num_customers,
        total_items,
        total_revenue,
        avg_transaction_value,
        AVG(total_revenue) OVER (
            PARTITION BY hour_of_day
            ORDER BY year, month
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) as moving_avg_revenue_hourly,
        RANK() OVER (PARTITION BY month, year ORDER BY total_revenue DESC) as daily_revenue_rank
    FROM hourly_metrics
)
SELECT *,
    CASE 
        WHEN hour_of_day BETWEEN 6 AND 11 THEN 'Morning'
        WHEN hour_of_day BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN hour_of_day BETWEEN 18 AND 23 THEN 'Evening'
        ELSE 'Night'
    END as time_period
FROM time_aggregates
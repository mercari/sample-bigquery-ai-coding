DECLARE target_start_date,
        target_end_date DATE;

SET target_start_date = "2024-01-01";
SET target_end_date = "2024-12-31";

WITH user_monthly_activity AS (
    SELECT
        user_id,
        DATE_TRUNC(DATE(created_at), MONTH) AS activity_month, -- Aggregation by month
        COUNT(DISTINCT id) AS total_monthly_orders -- Total orders within that month for the user
    FROM `bigquery-public-data.thelook_ecommerce.order_items`
    -- Filter activity calculation to the target period's months
    WHERE DATE(created_at) BETWEEN target_start_date AND target_end_date
    GROUP BY user_id, activity_month
)

SELECT
    DATE(oi.created_at) AS d, -- Daily transaction date
    CASE
        WHEN IFNULL(uma.total_monthly_orders, 0) = 0 THEN '0.NoActivity'
        WHEN IFNULL(uma.total_monthly_orders, 0) = 1 THEN '1.Once'
        WHEN IFNULL(uma.total_monthly_orders, 0) > 1 THEN '2.Multiple'
    END AS user_segment_monthly,
    COUNT(DISTINCT oi.id) AS cnt_transactions,
    SUM(oi.sale_price) AS gmv
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
LEFT JOIN user_monthly_activity AS uma
    ON oi.user_id = uma.user_id
    AND DATE_TRUNC(DATE(oi.created_at), MONTH) = uma.activity_month -- Join based on the month of the transaction
-- Filter the main transactions to the precise target_start_date and target_end_date
WHERE DATE(oi.created_at) BETWEEN target_start_date AND target_end_date
GROUP BY 1, 2
ORDER BY d, user_segment_monthly;
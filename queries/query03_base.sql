DECLARE target_categories ARRAY<STRING>;
DECLARE target_start_date, target_end_date DATE;

SET target_categories = ['Outerwear & Coats', 'Suits & Sport Coats'];
SET target_start_date = "2023-01-01";
SET target_end_date = "2023-12-31";

SELECT
    DATE_TRUNC(DATE(oi.created_at), MONTH) AS m,
    p.category,
    SUM(oi.sale_price) AS gmv,
    COUNT(DISTINCT oi.user_id) AS cnt_users,
FROM
    `bigquery-public-data.thelook_ecommerce.order_items` AS oi
INNER JOIN
    `bigquery-public-data.thelook_ecommerce.products` AS p
    ON
    oi.product_id = p.id
WHERE
    DATE(oi.created_at) BETWEEN target_start_date AND target_end_date
    AND p.category IN UNNEST(target_categories)
GROUP BY
    1, 2
ORDER BY
    m
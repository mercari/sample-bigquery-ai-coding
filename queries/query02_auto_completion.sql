SELECT
    DATE(oi.created_at) AS d,
    COUNT(DISTINCT oi.id) AS cnt_transactions,
    SUM(oi.sale_price) AS gmv
FROM
    `bigquery-public-data.thelook_ecommerce.order_items` AS oi
GROUP BY

-- ここにカーソルを置くと、自動で補完されます
-- Tabキーを押すと補完が確定します

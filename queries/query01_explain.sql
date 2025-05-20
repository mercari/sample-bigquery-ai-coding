-- 複雑なSQLクエリの例: ユーザーセグメンテーションと月次LTV傾向分析
-- このクエリは、thelook_ecommerceデータセットを使用して以下の分析を行います:
-- 1. ユーザーごとの初回購入日、最終購入日、総購入回数、総購入額を計算します。
-- 2. RFMスコア（Recency, Frequency, Monetary）を計算し、ユーザーをセグメント化します。
-- 3. ユーザーの初回購入月をコホートとして定義します。
-- 4. ユーザーが初回購入してから各月経過時点での累積購入額と平均購入額を計算します。
-- 5. 上記を組み合わせて、RFMセグメントごとのLTV関連指標の傾向を分析します。

-- 分析の基準日 (データセットの最新注文日など、固定値でも可)
DECLARE analysis_snapshot_date DATE DEFAULT (SELECT MAX(DATE(created_at)) FROM `bigquery-public-data.thelook_ecommerce.orders`);

WITH
  -- 1. ユーザーごとの注文集計 (初回・最終購入日、購入回数、購入総額)
  user_order_summary AS (
    SELECT
      oi.user_id,
      MIN(DATE(o.created_at)) AS first_purchase_date,
      MAX(DATE(o.created_at)) AS last_purchase_date,
      COUNT(DISTINCT oi.order_id) AS total_orders,
      SUM(oi.sale_price) AS total_spend,
      AVG(oi.sale_price) AS avg_item_price -- 注文商品あたりの平均価格
    FROM
      `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    JOIN
      `bigquery-public-data.thelook_ecommerce.orders` AS o ON oi.order_id = o.order_id
    WHERE oi.status NOT IN ('Cancelled', 'Returned') -- 有効な注文のみ
    GROUP BY
      oi.user_id
  ),

  -- 2. RFMスコア計算のためのベースデータ
  rfm_base AS (
    SELECT
      user_id,
      first_purchase_date,
      last_purchase_date,
      total_orders,
      total_spend,
      DATE_DIFF(analysis_snapshot_date, last_purchase_date, DAY) AS recency_days,
      total_orders AS frequency_count,
      total_spend AS monetary_value
    FROM
      user_order_summary
    WHERE total_orders > 0 -- 購入実績のあるユーザーのみ
  ),

  -- RFMスコア (各指標を5段階評価)
  -- Recencyスコアは値が小さい(日数が少ない)ほど良いので、NTILEの順序を調整 (値が大きい方が高スコア)
  rfm_scores AS (
    SELECT
      user_id,
      first_purchase_date,
      last_purchase_date,
      recency_days,
      frequency_count,
      monetary_value,
      NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score, -- 最近の購入ほどスコアが高い (5が最高)
      NTILE(5) OVER (ORDER BY frequency_count DESC) AS f_score,
      NTILE(5) OVER (ORDER BY monetary_value DESC) AS m_score
    FROM
      rfm_base
  ),

  -- RFMセグメント (例: Champions, Loyal Customersなど)
  rfm_segments AS (
    SELECT
      user_id,
      first_purchase_date,
      last_purchase_date,
      recency_days,
      frequency_count,
      monetary_value,
      r_score,
      f_score,
      m_score,
      CONCAT(CAST(r_score AS STRING), '-', CAST(f_score AS STRING), '-', CAST(m_score AS STRING)) AS rfm_segment_value,
      CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN f_score >= 4 THEN 'Potential Loyalist (High Frequency)'
        WHEN m_score >= 4 THEN 'Big Spenders'
        WHEN r_score >= 4 THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'At Risk / Hibernating'
        ELSE 'Others'
      END AS rfm_segment_name
    FROM
      rfm_scores
  ),

  -- 3. ユーザーの初回購入月 (コホート)
  user_cohorts AS (
    SELECT
      user_id,
      DATE_TRUNC(first_purchase_date, MONTH) AS cohort_month
    FROM
      user_order_summary
    WHERE user_id IS NOT NULL AND first_purchase_date IS NOT NULL -- 念のためNULL除外
  ),

  -- 4. ユーザーごとの月次購入実績
  user_monthly_spend AS (
    SELECT
      oi.user_id,
      DATE_TRUNC(DATE(o.created_at), MONTH) AS order_month,
      SUM(oi.sale_price) AS monthly_spend
    FROM
      `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    JOIN
      `bigquery-public-data.thelook_ecommerce.orders` AS o ON oi.order_id = o.order_id
    WHERE oi.status NOT IN ('Cancelled', 'Returned')
    GROUP BY
      oi.user_id,
      order_month
  ),

  -- ユーザーのコホートと月次購入を結合し、コホートからの経過月数を計算
  user_cohort_activity AS (
    SELECT
      uc.user_id,
      uc.cohort_month,
      ums.order_month,
      ums.monthly_spend,
      DATE_DIFF(ums.order_month, uc.cohort_month, MONTH) AS months_since_cohort_start
    FROM
      user_cohorts AS uc
    JOIN
      user_monthly_spend AS ums ON uc.user_id = ums.user_id
    WHERE
      ums.order_month >= uc.cohort_month -- コホート月以降の活動のみ
  ),

  -- 経過月数ごとの累積購入額 (ユーザー単位)
  user_cumulative_spend_by_month AS (
    SELECT
      user_id,
      cohort_month,
      order_month,
      months_since_cohort_start,
      monthly_spend,
      SUM(monthly_spend) OVER (PARTITION BY user_id ORDER BY months_since_cohort_start ASC) AS cumulative_spend
    FROM
      user_cohort_activity
  )

-- 5. 最終的な出力: RFMセグメント別の、初回購入からの経過月数ごとの平均累積購入額
-- この出力は、どのセグメントのユーザーが長期的に価値が高いかを示唆する
SELECT
  rfm.rfm_segment_name,
  ucs.months_since_cohort_start,
  COUNT(DISTINCT ucs.user_id) AS number_of_users,
  ROUND(AVG(ucs.cumulative_spend), 2) AS avg_cumulative_spend_after_x_months,
  ROUND(SUM(ucs.monthly_spend), 2) AS total_monthly_spend_at_x_months -- その経過月の総支出 (平均ではない)
FROM
  user_cumulative_spend_by_month AS ucs
JOIN
  rfm_segments AS rfm ON ucs.user_id = rfm.user_id
WHERE
  ucs.months_since_cohort_start <= 12 AND ucs.months_since_cohort_start >=0 -- 例として初回購入から12ヶ月後までを分析 (0ヶ月目を含む)
GROUP BY
  rfm.rfm_segment_name,
  ucs.months_since_cohort_start
ORDER BY
  rfm.rfm_segment_name,
  ucs.months_since_cohort_start;


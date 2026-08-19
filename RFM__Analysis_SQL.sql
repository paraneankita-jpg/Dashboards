create database rfm_analysis;
use rfm_analysis;


------ RFM ANALYSIS

CREATE VIEW rfm_base AS
SELECT
o.user_id,u.name,
DATEDIFF('2026-04-21', MAX(o.order_date)) AS Recency,
COUNT(o.order_id) AS Frequency,
ROUND(SUM(o.total_amount),0) AS Monetary
FROM orders o
JOIN users u
ON o.user_id = u.user_id
WHERE o.order_status = 'shipped'
GROUP BY o.user_id, u.name;



---- GROUPING_CUSTOMER_SCORE


CREATE VIEW  rfm_score AS
SELECT *,
NTILE(5) OVER (ORDER BY recency ASC) AS R_score,
NTILE(5) OVER (ORDER BY frequency DESC) AS F_score,
NTILE(5) OVER (ORDER BY monetary DESC) AS M_score
FROM rfm_base;


------- CUSTOMER SEGMENTATION


CREATE VIEW customer_segment AS
SELECT *,
CONCAT_WS("-", r_score, f_score, m_score) AS RFM_Score,
CASE
WHEN r_score >=4  AND  f_score >=4  AND m_score >=4  THEN  'Champions'
WHEN  r_score >=4  AND  f_score >=3  THEN  'Loyal Customers'
WHEN  r_score >=4  AND  f_score <=2  THEN  'New Customers'
WHEN  r_score =3  AND  f_score <=3  THEN 'At risk'
WHEN  r_score =1  AND f_score =1  THEN  'Lost Customers'
ELSE  'Regular Customers'
END AS SEGMENT
FROM rfm_score;


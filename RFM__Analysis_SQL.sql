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

------ PRODUCT PERFORMANCE ANALYSIS
SELECT 
product_name,
SUM(oi.quantity) AS total_units,
ROUND(SUM(oi.quantity * oi.item_price),2) AS revenue
FROM
products p JOIN order_items oi ON p.product_id = oi.product_id 
GROUP BY product_name
ORDER BY revenue;

------- RATING ANALYSIS
SELECT
product_name,
round(AVG(r.rating),2) AS avg_rating,
count(*) AS total_reviews
FROM reviews r
JOIN products p on r.product_id = p.product_id
GROUP BY  product_name;
 
 ------- rating
 CREATE VIEW high_risk_products AS
 SELECT 
    r.product_id,
    round(AVG(rating),2) AS avg_rating,
    round(SUM(item_price),2) AS total_sales,
    
    CASE 
        WHEN AVG(r.rating) < 3 AND SUM(o.item_price) > 10000 
        THEN 'High Risk'
        ELSE 'Normal'
    END AS Flag

FROM reviews r
JOIN order_items o 
    ON r.product_id = o.product_id
GROUP BY r.product_id;



select *   from employee  group by dept having avg(salary)< (select dept ,salary from employe where salary >50000)
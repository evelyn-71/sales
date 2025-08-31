/*===============================================================================
5. ANALYSIS - CUSTOMER PROFILE
===============================================================================
*/

 ---Total customers,  unique customers and total orders over time(year) ---
SELECT 
	EXTRACT (YEAR FROM s.order_date) AS order_year, 
	COUNT (c.customer_id) AS total_cus, 
	COUNT (DISTINCT c.customer_id) AS total_uniq_cus,
	COUNT (order_number) AS total_order
FROM gold.dim_customers c
INNER JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
WHERE EXTRACT (YEAR FROM s.order_date) IS NOT NULL
GROUP BY EXTRACT (YEAR FROM s.order_date) 
ORDER BY EXTRACT (YEAR FROM s.order_date); 

--- Customer distribution by gender (n and %)---
SELECT
	COUNT (DISTINCT c.customer_id) AS total_uniq_cus,
	c.gender,
	ROUND(
		100.0 * COUNT(DISTINCT c.customer_id) / SUM(COUNT(DISTINCT c.customer_id)) OVER (),2
	) AS perc
FROM gold.dim_customers c
INNER JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
WHERE EXTRACT (YEAR FROM s.order_date) IS NOT NULL
GROUP BY c.gender;

--- Customer distribution by gender (n and %), over time---
SELECT
	COUNT (DISTINCT c.customer_id) AS total_uniq_cus,
	c.gender,
	ROUND(
		100.0 * COUNT(DISTINCT c.customer_id) / SUM(COUNT(DISTINCT c.customer_id)) OVER (PARTITION BY EXTRACT (YEAR FROM s.order_date)),2
	) AS perc,
	EXTRACT (YEAR FROM s.order_date) AS order_year
FROM gold.dim_customers c
INNER JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
WHERE EXTRACT (YEAR FROM s.order_date) IS NOT NULL
GROUP BY EXTRACT (YEAR FROM s.order_date), c.gender
ORDER BY EXTRACT (YEAR FROM s.order_date), perc DESC;


--- Customer distribution by marital status (n and %)---
SELECT
	COUNT (DISTINCT c.customer_id) AS total_uniq_cus,
	c.marital_status,
	ROUND(
		100.0 * COUNT(DISTINCT c.customer_id) / SUM(COUNT(DISTINCT c.customer_id)) OVER (),2
	) AS perc
FROM gold.dim_customers c
INNER JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
WHERE EXTRACT (YEAR FROM s.order_date) IS NOT NULL
GROUP BY c.marital_status;

--- Customer distribution by marital status (n and %), over time---
SELECT
	COUNT (DISTINCT c.customer_id) AS total_uniq_cus,
	c.marital_status,
	ROUND(
		100.0 * COUNT(DISTINCT c.customer_id) / SUM(COUNT(DISTINCT c.customer_id)) OVER (PARTITION BY EXTRACT (YEAR FROM s.order_date)),2
	) AS perc,
	EXTRACT (YEAR FROM s.order_date) AS order_year
FROM gold.dim_customers c
INNER JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
WHERE EXTRACT (YEAR FROM s.order_date) IS NOT NULL
GROUP BY EXTRACT (YEAR FROM s.order_date), c.marital_status
ORDER BY EXTRACT (YEAR FROM s.order_date), perc DESC;

--- Customer distribution by age group (n and %) ---
WITH age_group AS (
SELECT 
	(2025- ( EXTRACT (YEAR FROM birthdate))) AS age	
	FROM gold.dim_customers
)
SELECT
    CASE 
        WHEN age < 20 THEN 'Below 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age >= 60 THEN '60 and above'
        ELSE 'NA'
END AS age_group,
	COUNT (*) AS customer_count,
	ROUND(
		100* COUNT(*) / SUM(COUNT(*)) OVER(),
		2) AS perc
FROM age_group
GROUP BY age_group
ORDER BY age_group;


--- Customer distribution by age group over time ---
WITH age_cte AS (
SELECT 
	CASE 
        WHEN EXTRACT(YEAR FROM c.birthdate) IS NULL THEN 'NA'
        WHEN 2025 - EXTRACT(YEAR FROM c.birthdate) < 20 THEN 'Below 20'
        WHEN 2025 - EXTRACT(YEAR FROM c.birthdate) BETWEEN 20 AND 29 THEN '20-29'
        WHEN 2025 - EXTRACT(YEAR FROM c.birthdate) BETWEEN 30 AND 39 THEN '30-39'
        WHEN 2025 - EXTRACT(YEAR FROM c.birthdate) BETWEEN 40 AND 49 THEN '40-49'
        WHEN 2025 - EXTRACT(YEAR FROM c.birthdate) BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60 and above'
	END AS age_group,
	c.customer_key
FROM gold.dim_customers c
)
SELECT 
	EXTRACT (YEAR FROM s.order_date) AS order_year,
	ag.age_group AS age_group,
	COUNT(DISTINCT ag.customer_key) AS total_uniq_cus,
	ROUND (100 * COUNT(DISTINCT ag.customer_key)/
		SUM(COUNT(DISTINCT ag.customer_key)) OVER (PARTITION BY EXTRACT (YEAR FROM s.order_date)),2) AS perc ---total sum per year ---
FROM age_cte ag
INNER JOIN gold.fact_sales s
ON ag.customer_key = s.customer_key
WHERE s.order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM s.order_date), ag.age_group
ORDER BY order_year, perc DESC; 
 
 
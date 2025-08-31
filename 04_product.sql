/*===============================================================================
4. ANALYSIS - PRODUCT
===============================================================================
*/

--- Highest contributor in 2013 by subcategory ---
WITH product_sales AS 
(SELECT 
	sales_amount, 
 	EXTRACT (YEAR FROM order_date) AS year,
	category, 
	subcategory 
FROM gold.fact_sales s
INNER JOIN gold.dim_products p ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
)
SELECT 
    subcategory,
    SUM(sales_amount) AS total_sales_by_subcategory
FROM product_sales
WHERE year = 2013
GROUP BY subcategory
ORDER BY total_sales_by_subcategory DESC;

--- Highest contributor in 2013 by category ---
WITH product_sales AS 
(SELECT 
	sales_amount, 
 	EXTRACT (YEAR FROM order_date) AS year,
	category 
FROM gold.fact_sales s
INNER JOIN gold.dim_products p ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
)
SELECT 
    category,
    SUM(sales_amount) AS total_sales_by_category
FROM product_sales
WHERE year = 2013
GROUP BY category
ORDER BY total_sales_by_category DESC;

--- Total sales by each subcategory ---
WITH product_sales AS 
(SELECT sales_amount, 
category, 
subcategory 
FROM gold.fact_sales s
INNER JOIN gold.dim_products p ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
)
SELECT 
    category,
    subcategory,
    SUM(sales_amount) AS total_sales_by_subcategory
FROM product_sales
GROUP BY category, subcategory
ORDER BY total_sales_by_subcategory DESC;

--- Most-profitable subcategory across years ---
WITH annual_sales_subcat AS 
(SELECT 
SUM(s.sales_amount) AS total_subcat_sales,
p.subcategory,
EXTRACT(YEAR FROM order_date) AS order_year
FROM gold.fact_sales s
INNER JOIN gold.dim_products p ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
GROUP BY p.subcategory, order_year
)
SELECT subcategory, order_year, total_subcat_sales FROM (
	SELECT
		subcategory,
		order_year,
		total_subcat_sales,
		RANK() OVER(PARTITION BY order_year ORDER BY total_subcat_sales DESC) AS rank
	FROM annual_sales_subcat
) inner_q
WHERE rank=1;
 
--- Total sales of each sub-category by year ---
WITH product_sales AS 
(SELECT 
	sales_amount, 
 	EXTRACT (YEAR FROM order_date) AS year,
	category, 
	subcategory 
FROM gold.fact_sales s
INNER JOIN gold.dim_products p ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
)
SELECT 
    subcategory,
    SUM(sales_amount) AS total_sales_by_subcategory,
 	year
FROM product_sales
GROUP BY subcategory, year
ORDER BY subcategory, total_sales_by_subcategory DESC;

--- Highest year for each sub-category ---
WITH product_sales AS 
(SELECT 
 EXTRACT (YEAR FROM s.order_date) AS year,
	p.subcategory,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales s
	INNER JOIN gold.dim_products p ON s.product_key = p.product_key
	WHERE s.order_date IS NOT NULL
	GROUP BY EXTRACT(YEAR FROM s.order_date), p.subcategory
)
SELECT subcategory, total_sales, year FROM (
    SELECT *,
	RANK() OVER (PARTITION BY subcategory ORDER BY total_sales DESC) AS rank
    FROM product_sales
) AS inner_q
WHERE rank =1
ORDER BY subcategory;

--- Highest year for "road bikes" --- 
WITH product_sales AS 
(SELECT 
 EXTRACT (YEAR FROM s.order_date) AS year,
	p.subcategory,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales s
	INNER JOIN gold.dim_products p ON s.product_key = p.product_key
	WHERE s. order_date IS NOT NULL
	GROUP BY EXTRACT(YEAR FROM s.order_date), p.subcategory
)
SELECT subcategory, total_sales, year FROM (
    SELECT *,
	RANK() OVER (PARTITION BY subcategory ORDER BY total_sales DESC) AS rank
    FROM product_sales
) AS inner_q
WHERE subcategory = 'Road Bikes' AND rank = 1;

--- % of each sub-category towards that category ---
WITH subcat_sales AS (
    SELECT 
        p.category,
        p.subcategory,
        SUM(s.sales_amount) AS subcat_total ---total sum of each subcat ---
    FROM gold.fact_sales s
    INNER JOIN gold.dim_products p 
        ON s.product_key = p.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY p.category, p.subcategory
)
SELECT 
    category,
    subcategory,
    subcat_total,
    SUM(subcat_total) OVER(PARTITION BY category) AS total_by_category, --total sum of each cat ---
    ROUND(
        subcat_total * 100.0 / SUM(subcat_total) OVER(PARTITION BY category), 2
    ) AS pct_of_category --- pct --- 
FROM subcat_sales
ORDER BY pct_of_category DESC;

--- Total quantity sold for each subcategory ---
SELECT 
	p.subcategory,
	SUM(s.quantity) AS total_qty,
	EXTRACT (YEAR FROM s.order_date) AS order_year
FROM gold.fact_sales s
INNER JOIN gold.dim_products p 
        ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
GROUP BY p.subcategory,	EXTRACT (YEAR FROM s.order_date)
ORDER BY order_year;

--- Highest quantity across years ---
WITH qty_yr AS (
SELECT 
	p.subcategory,
	SUM(s.quantity) AS total_qty,
	EXTRACT (YEAR FROM s.order_date) AS order_year
FROM gold.fact_sales s
INNER JOIN gold.dim_products p 
        ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
GROUP BY p.subcategory,	EXTRACT (YEAR FROM s.order_date)
ORDER BY order_year
)
SELECT subcategory, order_year, total_qty FROM (
	SELECT
		subcategory,
		order_year,
		total_qty,
		RANK() OVER(PARTITION BY order_year ORDER BY total_qty DESC) AS rank
	FROM qty_yr
) inner_q
WHERE rank=1;

--- Total quantity sold for mountain bikes in 2013 ---
SELECT SUM(s.quantity), p.subcategory
FROM gold.fact_sales s
INNER JOIN gold.dim_products p 
        ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL AND p.subcategory = 'Mountain Bikes'
GROUP BY p.subcategory;

--- To check whether pricing differs for products ---
SELECT COUNT (DISTINCT s.price) AS num_unique_price, p.subcategory
FROM gold.fact_sales s
INNER JOIN gold.dim_products p 
        ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
GROUP BY p.subcategory
ORDER BY num_unique_price DESC;

--- To check whether pricing differs for products (mountain bikes in 2013)---
SELECT 
	COUNT (DISTINCT s.price) AS num_unique_price, 
	p.subcategory,
	EXTRACT (YEAR FROM s.order_date) AS order_year
FROM gold.fact_sales s
INNER JOIN gold.dim_products p 
        ON s.product_key = p.product_key
WHERE 
	s.order_date IS NOT NULL AND 
	p.subcategory = 'Mountain Bikes' AND 
	EXTRACT (YEAR FROM s.order_date)  = 2013
	GROUP BY p.subcategory, EXTRACT(YEAR FROM s.order_date);





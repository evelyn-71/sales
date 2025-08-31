 /*===============================================================================
3. ANALYSIS - SALES
===============================================================================
*/

---Total sales over time (year) ---
SELECT
	EXTRACT (YEAR FROM order_date) AS order_year,
	SUM (sales_amount) AS total_sales 
	FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT (YEAR FROM order_date) 
ORDER BY EXTRACT (YEAR FROM order_date);

--- % YoY increase in sales (year) ---
WITH yearly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS order_year, 
        SUM(sales_amount) AS total_year_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT 
    order_year,
    total_year_sales,
    LAG(total_year_sales) OVER (ORDER BY order_year) AS one_year_before,
    total_year_sales - LAG(total_year_sales) OVER (ORDER BY order_year) AS diff,
    100.0 * (
        (CAST(total_year_sales AS DECIMAL) - CAST(LAG(total_year_sales) OVER (ORDER BY order_year) AS DECIMAL))
        / NULLIF(CAST(LAG(total_year_sales) OVER (ORDER BY order_year) AS DECIMAL), 0)
    ) AS pct_yoy
FROM yearly_sales
ORDER BY order_year;

--- Total sales per month ---
SELECT 
	SUM(sales_amount) AS total_sales,
	EXTRACT (MONTH FROM order_date) AS order_month
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT (MONTH FROM order_date)
ORDER BY SUM(sales_amount) DESC;

---Highest sales by month (year and month)---
WITH month_sales AS (
SELECT 
	EXTRACT(YEAR FROM order_date) AS order_year,
	EXTRACT(MONTH FROM order_date) AS order_month,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date) 
)
SELECT total_sales, order_year, order_month FROM --outer query--
( --inner--
SELECT *, 
	RANK() OVER(PARTITION BY order_year ORDER BY order_month DESC) as rank
FROM month_sales
) --inner--
WHERE rank = 1 
ORDER BY order_year;

--- Total sales per month and per year ---
SELECT
    year,
    month,
    monthly_sales,
    SUM(monthly_sales) OVER(PARTITION BY year) AS total_year
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(sales_amount) AS monthly_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
) t
ORDER BY year, month;


--- Compare each subcategory's sales in a year by that year's average ---
WITH subcat_sales AS (
    SELECT 
        p.category,
        p.subcategory,
        SUM(s.sales_amount) AS subcat_total
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
    AVG(subcat_total) OVER (PARTITION BY category) AS avg_cat_total, --- the average sales by cat---
    subcat_total - AVG(subcat_total) OVER (PARTITION BY category) AS difference_from_avg,
	CASE  
		WHEN subcat_total - AVG(subcat_total) OVER (PARTITION BY category) >=0 THEN 'Avg and above'
		WHEN subcat_total - AVG(subcat_total) OVER (PARTITION BY category) <0 THEN 'Below avg'
		ELSE 'Avg'
	END avg_sales
FROM subcat_sales
ORDER BY category, subcategory;

---Average sales over time(year) ---
SELECT EXTRACT (YEAR FROM order_date) AS order_year, AVG (sales_amount) FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT (YEAR FROM order_date) 
ORDER BY EXTRACT (YEAR FROM order_date);

--- Average sales by month ---
SELECT EXTRACT (MONTH FROM order_date) AS order_month, AVG(sales_amount) AS avg_sales FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT (MONTH FROM order_date)
ORDER BY AVG(sales_amount) DESC;
 
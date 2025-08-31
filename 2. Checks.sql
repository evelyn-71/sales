/*===============================================================================
2. Database Exploration
===============================================================================
*/

--- Preview tables ---
SELECT * FROM gold.dim_customers
LIMIT 10;

SELECT * FROM gold.dim_products
LIMIT 10;

SELECT * FROM gold.fact_sales
LIMIT 10;

-- Metadata --
SELECT 
    COLUMN_NAME, 
    DATA_TYPE,  
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products';

SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';

--- PERFORM BASIC CHECKS ON DATA QUALITY --- 
SELECT COUNT (DISTINCT customer_key) FROM gold.fact_sales; --- 18484 --- 
SELECT COUNT (customer_key) FROM gold.fact_sales; --- 60,398--- (there is no primary key)

SELECT COUNT (DISTINCT customer_id) FROM gold.dim_customers; --- 18,484 ---
SELECT COUNT (customer_id) FROM gold.dim_customers; --- 18,484 --- (PK)

 SELECT COUNT (DISTINCT product_id) FROM gold.dim_products; --- 295 ---
 SELECT COUNT (product_id) FROM gold.dim_products; --- 295 --- (PK)

--- Check for null dates ---
SELECT order_date , order_number FROM gold.fact_sales
WHERE order_date IS NULL;


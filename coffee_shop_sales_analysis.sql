CREATE DATABASE coffee_shop_sales_db;
USE coffee_shop_sales_db;
SELECT * FROM coffee_shop_sales;
DESCRIBE coffee_shop_sales;

-- Data Cleaning
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, "%m/%d/%Y");
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, "%H:%i:%s");
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- Checking cleaned columns
DESCRIBE coffee_shop_sales;

-- Q1. What is the total sales for each month?
SELECT * FROM coffee_shop_sales;
SELECT
  DATE_FORMAT(transaction_date, '%Y-%m') AS month, 
  CONCAT((ROUND(SUM(unit_price * transaction_qty)))/1000, "K") AS total_sales
FROM coffee_shop_sales
GROUP BY month
ORDER BY month;

-- Q2. What is the sales comparison between previous and current months?
WITH monthly_sales AS (
  SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    SUM(unit_price * transaction_qty) AS total_sales
  FROM coffee_shop_sales
  GROUP BY month
)
SELECT
  month, total_sales,
  LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales,
  (total_sales - LAG(total_sales) OVER (ORDER BY month)) AS change_in_sales,
  ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY month)) / LAG(total_sales) OVER (ORDER BY month)) * 100, 2) AS percent_change
FROM
  monthly_sales;

-- Q3. What is the total number of orders for each month?
SELECT * FROM coffee_shop_sales;
SELECT COUNT(transaction_id) AS total_orders, DATE_FORMAT(transaction_date, "%m") as month 
FROM coffee_shop_sales
GROUP BY month;

-- Q4. What is the month on month increase or decrease in orders?
WITH monthly_orders AS (
	SELECT 
		COUNT(transaction_id) AS total_orders, 
        DATE_FORMAT(transaction_date, "%m") as month
	FROM coffee_shop_sales
	GROUP BY month 
)
SELECT month, total_orders,
LAG(total_orders) OVER (ORDER BY month) AS previous_month_orders,
(total_orders)- LAG(total_orders) OVER (ORDER BY month) AS change_in_order,
ROUND((total_orders)- LAG(total_orders) OVER (ORDER BY month)/ LAG(total_orders) OVER (ORDER BY month) *100, 2) AS percent_change
FROM monthly_orders;

-- Q5. What is total quantity sold for each month?
SELECT * FROM coffee_shop_sales;
SELECT COUNT(transaction_qty) as total_quantity, DATE_FORMAT(transaction_date, "%m") as month
FROM coffee_shop_sales
GROUP BY month;

-- Q6. What is the difference between total quantity sold for previous and current month?
WITH monthly_qty AS (
	SELECT COUNT(transaction_qty) as total_quantity, 	
    DATE_FORMAT(transaction_date, "%m") as month
	FROM coffee_shop_sales
	GROUP BY month )
SELECT month,
LAG(total_quantity) OVER (ORDER BY month) AS prev_month,
total_quantity AS current_month,
ROUND(total_quantity - LAG(total_quantity) OVER (ORDER BY month),2) as difference
FROM monthly_qty;
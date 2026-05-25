SELECT * FROM orders;
SELECT COUNT(row_id) FROM orders;
--Question 1 What are the total sales and profit for each product category?
SELECT category, 
       SUM(sales) AS total_sales, 
       SUM(profit) AS total_profit
FROM orders
GROUP BY category;

--Question 2 Which are the top 10 products by total sales?
SELECT product_name, ROUND(SUM(sales),2) AS total_sales
FROM orders
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

--Question 3 What is the total sales contribution of each region?
SELECT region, 
       ROUND(SUM(sales)*100/
       (SELECT SUM(sales) FROM orders),2) 
        AS sales_contribution_percent
FROM orders
GROUP BY region;

--Question 4 Which customer segment generates the highest average order value?
SELECT segment, 
       ROUND(AVG(sales),2) AS avg_order_value
FROM orders
GROUP BY segment
ORDER BY avg_order_value DESC;

--Question 5 What is the profit margin for each category? 
SELECT category, 
       ROUND((SUM(profit)/SUM(sales))*100,2) AS profit_margin_percentage
FROM orders
GROUP BY category;

--Question 6 Which sub-categories are loss-making (negative total profit)?
SELECT sub_category,
       SUM(profit) AS total_profit
FROM orders
GROUP BY sub_category
HAVING total_profit < 0;

--Question 7 How many orders were placed each year and what was the total revenue?
SELECT SUBSTR(order_date, -4) AS order_year,
       COUNT(DISTINCT order_id) AS total_orders,
       ROUND(SUM(sales),2) AS total_revenue
FROM orders
GROUP BY order_year
ORDER BY order_year;

--Question 8 Classify orders into High (>500), Medium (200–500), Low (<200) value buckets. How many orders fall in each?
WITH order_totals AS (
    SELECT order_id,
           SUM(sales) AS total_order_value
    FROM orders
    GROUP BY order_id
)
SELECT
    CASE
        WHEN total_order_value > 500 THEN 'High'
        WHEN total_order_value BETWEEN 200 AND 500 THEN 'Medium'
        ELSE 'Low'
    END AS order_value_bucket,
    COUNT(*) AS total_orders
FROM order_totals
GROUP BY order_value_bucket;

--Question 9 Who are the top 5 customers by total sales in each region?
WITH customer_sales AS (
    SELECT customer_id,
           region,
           ROUND(SUM(sales),2) AS total_sales
    FROM orders
    GROUP BY region, customer_id
),
ranked_customers AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY region
               ORDER BY total_sales DESC
           ) AS customer_rank
    FROM customer_sales
)
SELECT customer_id,
       region,
       total_sales
FROM ranked_customers
WHERE customer_rank <= 5;

--Question 10 What is the average discount given per category, and how does it correlate with profit margin?
SELECT category,
       ROUND(AVG(discount)*100,2) AS avg_discount,
       ROUND(SUM(PROFIT)/SUM(SALES)*100,2) AS profit_margin
FROM orders
GROUP BY category;
       
--Question 11 Rank all customers by total sales using RANK() — who is the #1 customer overall?
SELECT customer_id,
       ROUND(SUM(sales),2) AS total_sales,
       RANK() OVER(ORDER BY SUM(sales) DESC) AS customer_rank
FROM orders
GROUP BY customer_id;

--Question 12 Rank sub-categories by sales within each category 
SELECT category, 
       sub_category,
       ROUND(SUM(sales), 2) AS total_sales,
       RANK() OVER ( PARTITION BY category ORDER BY SUM(sales) DESC) AS product_rank
FROM orders
GROUP BY category, sub_category;

--Question 13 Using a CTE, find customers who have placed more than 5 orders (repeat buyers)
WITH customer_count AS (
  SELECT customer_id,
         COUNT(DISTINCT order_id) AS no_of_orders
  FROM orders
  GROUP BY customer_id
)
SE0LECT *
FROM customer_count
WHERE no_of_orders > 5;

--Question 14 Using a CTE, identify the most profitable sub-category in each region
WITH product_rank AS(
  SELECT region,
         sub_category,
         ROUND(SUM(profit), 2) AS total_profit,
         RANK() OVER (PARTITION BY region ORDER BY SUM(profit) DESC) AS sub_product_rank
  FROM orders
  GROUP BY region, sub_category
)
SELECT region, 
       sub_category,
       total_profit
FROM product_rank
WHERE sub_product_rank = 1;
  
--Question 15 Which products generate high sales(>5000) but negative profit?
SELECT product_name,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM orders
GROUP BY product_name
HAVING SUM(sales) > 5000
   AND SUM(profit) < 0
ORDER BY total_sales DESC;





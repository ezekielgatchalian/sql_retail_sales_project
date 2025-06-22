

-- SQL RETAIL ANALYSIS --


-- DATABASE AND TABLE CREATION --

CREATE DATABASE sql_project_p2
;

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
(
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id INT,
				gender VARCHAR(15),
				age INT,
				category VARCHAR(15),
				quantiy INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
)
;

SELECT *
FROM retail_sales
;

SELECT *
FROM retail_sales
LIMIT 10
;

SELECT COUNT(*)
FROM retail_sales
;

SELECT COUNT(DISTINCT customer_id)
FROM retail_sales
;

SELECT DISTINCT category
FROM retail_sales
;

-- Data Cleaning

-- TO FILTER ALL COLUMNS AND ROWS THAT HAVE NULL VALUE --

SELECT *
FROM retail_sales
WHERE 
		transactions_id IS NULL OR
		sale_date IS NULL OR
        sale_time IS NULL OR
        customer_id IS NULL OR
        gender IS NULL OR
        age IS NULL OR
        category IS NULL OR
        quantiy IS NULL OR
        price_per_unit IS NULL OR
        cogs IS NULL OR
        total_sale IS NULL
;

-- TO DELETE ALL THE FILTERED COLUMNS AND ROW THAT HAVE NULL VALUE --

DELETE
FROM retail_sales
WHERE
		transactions_id IS NULL OR
		sale_date IS NULL OR
        sale_time IS NULL OR
        customer_id IS NULL OR
        gender IS NULL OR
        age IS NULL OR
        category IS NULL OR
        quantiy IS NULL OR
        price_per_unit IS NULL OR
        cogs IS NULL OR
        total_sale IS NULL
;

SELECT *
FROM retail_sales
;

-- Data Exploration --

-- Question 1. How many sales we have --

-- Count of sales --

SELECT COUNT(*) AS Total_Count_of_Sales
FROM retail_sales
;

-- Sales and Profit --

SELECT SUBSTRING(sale_date, 1, 4) AS `Year`, 
SUM(cogs) AS Cost, COUNT(total_sale) AS Count_of_sale, SUM(total_sale) AS Total_sales, SUM(total_sale) - SUM(cogs) AS Profit
FROM retail_sales
GROUP BY SUBSTRING(sale_date, 1, 4)
;

-- Question 2. How many customers we have --

-- Total customer count --

SELECT COUNT(DISTINCT customer_id) AS Customer_Count
FROM retail_sales
;

-- Customers per Item Category --

SELECT category, COUNT(DISTINCT customer_id) AS Customer_Count
FROM retail_sales
GROUP BY category
ORDER BY 2 DESC
;

-- Question 2. How many categories we have --

SELECT COUNT(DISTINCT category) AS Category
FROM retail_sales
;

SELECT DISTINCT category
FROM retail_sales
;

-- Data Analysis and Business key problems and solutions --

-- Q1 Write a SQL query to retrieve all columns for sales made on '2022-11-05:

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05'
;

-- Q2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:

SELECT *
FROM retail_sales
WHERE category = 'Clothing' AND quantiy >= 4 
AND month(sale_date) = 11 AND YEAR(sale_date) = 2022
;

SELECT *
FROM retail_sales
WHERE category = 'Clothing' AND quantiy >= 4 
AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
;

-- Q3 Write a SQL query to calculate the total sales (total_sale) for each category.:

SELECT category, SUM(total_sale), COUNT(total_sale) AS total_order
FROM retail_sales
GROUP BY category
ORDER BY 2 DESC
;

-- Q4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:

SELECT category, ROUND(AVG(age), 2) AS Avg_Age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category
;

-- Q5 Write a SQL query to find all transactions where the total_sale is greater than 1000.:

SELECT *
FROM retail_sales
WHERE total_sale > 1000
;

-- Q6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:

SELECT category, gender, COUNT(transactions_id)
FROM retail_sales
GROUP BY category, gender
ORDER BY 1
;

-- Q7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:

SELECT YEAR(sale_date), MONTH(sale_date), AVG(total_sale)
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY 1
;

WITH Avg_sales_per_month (`Year`, `Month`, Avg_Sales) AS
(
SELECT YEAR(sale_date), MONTH(sale_date), ROUND(AVG(total_sale), 2)
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY Avg_Sales DESC) AS Ranking
FROM Avg_sales_per_month
ORDER BY Ranking ASC
;

--

WITH Avg_sales_per_month (`Year`, `Month`, Avg_Sales) AS
(
SELECT YEAR(sale_date), MONTH(sale_date), ROUND(AVG(total_sale), 2)
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
), Top_Ranking AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY Avg_Sales DESC) AS Ranking
FROM Avg_sales_per_month
)
SELECT *
FROM Top_Ranking
WHERE Ranking <= 3
ORDER BY 4 ASC
;

-- ANOTHER LOGIC BUT CTE IS MUCH READABLE --

WITH T1 AS
(
SELECT YEAR(sale_date), MONTH(sale_date), AVG(total_sale), 
DENSE_RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS T1_Ranking
FROM retail_sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY 1
)
SELECT *
FROM T1
WHERE T1_Ranking <= 3
ORDER BY 4 ASC
;

-- Q8 **Write a SQL query to find the top 5 customers based on the highest total sales **:

SELECT *
FROM retail_sales
;

SELECT customer_id, sum(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 5
;

WITH TOTAL_SALES AS
(
SELECT customer_id, sum(total_sale) AS Total_Sales
FROM retail_sales
GROUP BY customer_id
)
SELECT *, DENSE_RANK() OVER(ORDER BY Total_Sales DESC) AS RANKING
FROM TOTAL_SALES
LIMIT 5
;

-- ANOTHER LOGIC BUT CTE IS MUCH READABLE --

SELECT customer_id, sum(total_sale) AS Total_Sales, 
DENSE_RANK() OVER (ORDER BY SUM(total_sale) DESC) AS Ranking
FROM retail_sales
GROUP BY customer_id
LIMIT 5
;

-- Q9 Write a SQL query to find the number of unique customers who purchased items from each category.:

SELECT category, COUNT(DISTINCT customer_id)
FROM retail_sales
GROUP BY category
;

-- Q10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):

SELECT *
FROM retail_sales
;

SELECT
CASE
		WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
END AS Time_Period,
COUNT(*) AS TOTAL_ORDERS
FROM retail_sales
GROUP BY Time_Period
;

WITH Time_Interval_Period AS
(
SELECT 
CASE
		WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
END AS Time_Period,
COUNT(*) AS TOTAL_ORDERS
FROM retail_sales
GROUP BY Time_Period
)
SELECT *
FROM Time_Interval_Period
ORDER BY 2 DESC
;













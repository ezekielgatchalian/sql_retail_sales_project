# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `sql_project_p2`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sql_project_p2`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*)
FROM retail_sales
;

SELECT COUNT(DISTINCT customer_id)
FROM retail_sales
;

SELECT DISTINCT category
FROM retail_sales
;


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

```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05'
;

```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql


SELECT *
FROM retail_sales
WHERE category = 'Clothing' AND quantiy >= 4 
AND month(sale_date) = 11 AND YEAR(sale_date) = 2022
;

---

SELECT *
FROM retail_sales
WHERE category = 'Clothing' AND quantiy >= 4 
AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
;

```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql

SELECT category, SUM(total_sale), COUNT(total_sale) AS total_order
FROM retail_sales
GROUP BY category
ORDER BY 2 DESC
;

```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql

SELECT category, ROUND(AVG(age), 2) AS Avg_Age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category
;

```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql

SELECT *
FROM retail_sales
WHERE total_sale > 1000
;

```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql

SELECT category, gender, COUNT(transactions_id)
FROM retail_sales
GROUP BY category, gender
ORDER BY 1
;

```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql


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

--- Added this to see only the top 3 ---


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


```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql


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


```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql

SELECT customer_id, sum(total_sale) AS Total_Sales, 
DENSE_RANK() OVER (ORDER BY SUM(total_sale) DESC) AS Ranking
FROM retail_sales
GROUP BY customer_id
LIMIT 5
;

```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql

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

```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.



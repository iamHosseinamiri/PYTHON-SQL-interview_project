create table df_orders (
		 [order_id] int primary key
		,[order_date] date
		,[ship_mode] varchar(20)
		,[segment] varchar(20)
		,[country] varchar(20)
		,[city] varchar(20)
		,[state] varchar(20)
		,[postal_code] varchar(20)
		,[region] varchar(20)
		,[category] varchar(20)
		,[sub_category] varchar(20)
		,[product_id] varchar(20)
		,[quantity] int
		,[discount] decimal (7,2)
		,[sale_price] decimal (7,2)
		,[profit] decimal (7,2))

		SELECT * from df_orders

--FIND TOP 10 HIGHEST REVENUE GENERATION PRODUCTS?????

SELECT top 10 product_id,sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc

--FIND TOP 5 HIGHEST SELLING PRODUCTS IN EACH REGION???????

with cte as (
SELECT region,product_id,sum(sale_price) as sales
from df_orders
group by region,product_id)
SELECT * from (
SELECT *
, row_number() over(partition by region order by sales desc) as rn 
from cte) A
where rn<=5


--This query starts by using a Common Table Expression (CTE) to calculate the total sales
--(sum(sale_price)) for each product (product_id) in each region (region).
--The results are grouped by region and product_id to ensure that the sales are aggregated correctly. 
--Next, the query assigns a row number to each product within its region, ordered by the total sales in descending order, 
--using the ROW_NUMBER() window function. This window function creates a sequential numbering of rows for each region, 
--starting at 1 for the highest sales. Finally, the outer query filters these results
--to include only the top 5 products (those with row numbers 1 through 5) in each region. This way, the query provides the top 5 products by sales for each region.

--FIND MONTH OVER MONTH GROWTH COMPARISON FOR 2022 AND 2023 SALES : JAN 2022 VS JAN 2023??????

WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    DATENAME(month, DATEFROMPARTS(2000, order_month, 1)) AS month_name,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


--for each category which month had highest sales?????????

with cte as (
SELECT category,format(order_date,'yyyyMM') as order_year_month
,sum(sale_price) as sales 
from df_orders
group by category,format(order_date, 'yyyyMM')
--order by category,format(order_date, 'yyyyMM')
)
SELECT * from(
SELECT *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a 
where rn=1

-- WHICH SUB CATEGORY HAD HIGHEST GROWTH BY PROFIT IN 2023 COMPARE TO 2022?????

with cte as (
SELECT sub_category,year(order_date) as order_year
,sum(sale_price) as sales 
from df_orders
group by sub_category,year(order_date)
	)
	, cte2 as (
SELECT sub_category 
,sum(case when order_year=2022 then sales else 0 end) as sales_2022
,sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1*
,(sales_2023-sales_2022)*100/sales_2022 as sales_growth_percentage
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc

-- When you order by the absolute difference in sales (e.g., `sales_2023 - sales_2022`), 
-- you prioritize sub-categories with the largest numerical increase in sales, 
-- which might favor those with high initial sales. 
-- However, ordering by the percentage change in sales (e.g., `(sales_2023 - sales_2022) * 100 / sales_2022`) 
-- prioritizes sub-categories with the highest relative growth, regardless of their starting sales. 
-- This way, smaller sub-categories with significant growth can be highlighted, 
-- showing which ones are truly expanding the fastest relative to their previous year's sales. 
-- Hence, using percentage change can result in different sub-categories being highlighted compared to using absolute differences.

/* ======================================================================
   SalesAnalyticsDB  -  SQL Practice Pack (Basic -> Intermediate -> Advanced)
   Table : dbo.Sales_Analytics  (62,360 rows | 31,500 orders | 8,538 customers)

USE SalesAnalyticsDB;
GO

EXEC sp_rename 'dbo.Sales_Analytics_Dataset', 'Sales_Analytics';

-- Q01 | BASIC | Preview data
-- Definition: Display the first 10 rows to preview the dataset.

SELECT TOP 10 * FROM dbo.Sales_Analytics;

-- Q02 | BASIC | Select specific columns
-- Definition: Return only selected columns instead of every column.

SELECT TOP 20 Order_ID, Order_Date, Customer_Name, City, Product_Name, Quantity, Net_Sales
FROM DBO.Sales_Analytics

-- Q03 | BASIC | COUNT and COUNT DISTINCT : dataset size
-- Definition: Count rows, unique orders, customers, and products.

SELECT COUNT(*)								AS Total_Lines,
	   Count(DISTINCT Order_ID)				AS Total_Orders,
	   COUNT(DISTINCT Customer_ID)          AS Total_Customers,
	   COUNT(DISTINCT Product_ID)			AS Total_Products
FROM DBO.Sales_Analytics

-- Q04 | BASIC | DISTINCT : category and sub-category list
-- Definition: List unique category and sub-category combinations.

SELECT DISTINCT Category, Sub_Category
FROM DBO.Sales_Analytics
ORDER BY Category, Sub_Category

-- Q05 | BASIC | WHERE with AND : delivered Electronics orders in 2025
-- Definition: Filter delivered Electronics records from 2025.

SELECT Order_ID, Order_Date, Product_Name, Net_Sales
FROM DBO.Sales_Analytics
WHERE Category = 'Electronics'
	AND Order_Status = 'Delivered'
	AND Order_Year = 2025

-- Q06 | BASIC | IN, BETWEEN, LIKE : mid-value smartphone lines in North / West
-- Definition: Use IN, BETWEEN, and LIKE to filter matching smartphone sales.

SELECT TOP 20 Order_ID, Region, Product_Name, Net_Sales
FROM dbo.Sales_Analytics
WHERE Region IN ('North', 'West')
  AND Net_Sales BETWEEN 5000 AND 20000
  AND Product_Name LIKE '%Smartphone%'
ORDER BY Net_Sales DESC;

-- Q07 | BASIC | ORDER BY + TOP : 10 biggest sales lines
-- Definition: Sort sales lines from highest to lowest and return the top 10.

SELECT TOP 10 Order_Line_ID, Customer_Name, Product_Name, Quantity, Net_Sales
FROM dbo.Sales_Analytics
ORDER BY Net_Sales DESC

-- Q08 | BASIC | NULL handling : unrated lines and return reasons
-- Definition: Find missing customer ratings and summarize recorded return reasons.

SELECT COUNT(*) AS Not_Rated_Lines
FROM dbo.Sales_Analytics
WHERE Customer_Rating IS NULL

SELECT Return_Reason, COUNT(*) AS Returned_Lines
FROM dbo.Sales_Analytics
WHERE Return_Reason IS NOT NULL AND Return_Reason <> ''
GROUP BY Return_Reason
ORDER BY Returned_Lines DESC;

-- Q09 | BASIC | Aggregate functions : overall KPIs
-- Definition: Calculate total, average, minimum, and maximum sales and realized KPIs.

SELECT SUM(Net_Sales)         AS Total_Net_Sales,
       AVG(Net_Sales)         AS Avg_Line_Sales,
       MIN(Net_Sales)         AS Min_Line_Sales,
       MAX(Net_Sales)         AS Max_Line_Sales,
       SUM(Realized_Revenue)  AS Realized_Revenue,
       SUM(Realized_Profit)   AS Realized_Profit
FROM dbo.Sales_Analytics;

-- Q10 | BASIC | GROUP BY : revenue by category, lines by status
-- Definition: Group records to summarize revenue by category and line count by status.

SELECT Category, COUNT(*) AS Lines, SUM(Realized_Revenue) AS Revenue
FROM dbo.Sales_Analytics
GROUP BY Category
ORDER BY Revenue DESC;
 
SELECT Order_Status, COUNT(*) AS Lines
FROM dbo.Sales_Analytics
GROUP BY Order_Status
ORDER BY Lines DESC;

-- Q11 | BASIC | Calculated columns and aliases : margin check
-- Definition: Create calculated profit and margin columns from sales and cost.

SELECT TOP 10 Order_Line_ID, Net_Sales, COGS,
       Net_Sales - COGS AS Gross_Profit_Calc,
       ROUND((Net_Sales - COGS) * 100.0 / NULLIF(Net_Sales, 0), 2) AS Margin_Pct
FROM dbo.Sales_Analytics

-- Q12 | BASIC | CASE WHEN : order-line value bands
-- Definition: Classify sales lines into low, medium, and high value bands.

SELECT CASE WHEN Net_Sales < 1000  THEN '1. Low (<1K)'
            WHEN Net_Sales < 10000 THEN '2. Medium (1K-10K)'
            ELSE '3. High (10K+)' END AS Value_Band,
       COUNT(*)       AS Lines,
       SUM(Net_Sales) AS Net_Sales
FROM dbo.Sales_Analytics
GROUP BY CASE WHEN Net_Sales < 1000  THEN '1. Low (<1K)'
              WHEN Net_Sales < 10000 THEN '2. Medium (1K-10K)'
              ELSE '3. High (10K+)' END
ORDER BY Value_Band

/* #######################  LEVEL 2 : INTERMEDIATE  ########################## */

-- Q13 | INTERMEDIATE | Multi-column GROUP BY : year and quarter performance
-- Definition: Compare realized revenue and profit by year and quarter.

SELECT Order_Year, Order_Quarter,
       SUM(Realized_Revenue) AS Revenue,
       SUM(Realized_Profit)  AS Profit
FROM dbo.Sales_Analytics
GROUP BY Order_Year, Order_Quarter
ORDER BY Order_Year, Order_Quarter

-- Q14 | INTERMEDIATE | HAVING : cities with revenue above 5 million
-- Definition: Show cities whose realized revenue is above 5 million.

SELECT City, State, SUM(Realized_Revenue) AS Revenue
FROM dbo.Sales_Analytics
GROUP BY City, State
HAVING SUM(Realized_Revenue) > 5000000
ORDER BY Revenue DESC

-- Q15 | INTERMEDIATE | CASE pivot : channel revenue by year (columns)
-- Definition: Compare yearly realized revenue across sales channels.

SELECT Sales_Channel,
       SUM(CASE WHEN Order_Year = 2023 THEN Realized_Revenue ELSE 0 END) AS Y2023,
       SUM(CASE WHEN Order_Year = 2024 THEN Realized_Revenue ELSE 0 END) AS Y2024,
       SUM(CASE WHEN Order_Year = 2025 THEN Realized_Revenue ELSE 0 END) AS Y2025,
       SUM(CASE WHEN Order_Year = 2026 THEN Realized_Revenue ELSE 0 END) AS Y2026
FROM dbo.Sales_Analytics
GROUP BY Sales_Channel
ORDER BY Sales_Channel

-- Q16 | INTERMEDIATE | Conditional aggregation : return rate by category
-- Definition: Calculate return counts, return rate, and refunds by category.

-- Q16 | INTERMEDIATE | Return Rate by Category
-- Definition: Calculate returned lines, return rate, and refunds by category.

SELECT
    Category,
    COUNT(*) AS Total_Lines,
    SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) AS Returned_Lines,
    CAST(
        SUM(CASE WHEN Return_Flag = 1 THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS Return_Rate_Pct,
    SUM(Refund_Amount) AS Refund_Amount
FROM dbo.Sales_Analytics
WHERE Order_Status IN ('Delivered', 'Returned')
GROUP BY Category
ORDER BY Return_Rate_Pct DESC;

-- Q17 | INTERMEDIATE | Average Order Value (AOV) by sales channel
-- Definition: Calculate order counts, net sales, and average order value by channel

SELECT Sales_Channel,
       COUNT(DISTINCT Order_ID) AS Orders,
       SUM(Net_Sales)           AS Net_Sales,
       CAST(SUM(Net_Sales) / COUNT(DISTINCT Order_ID) AS DECIMAL(12,2)) AS AOV
FROM dbo.Sales_Analytics
WHERE Order_Status <> 'Cancelled'
GROUP BY Sales_Channel
ORDER BY AOV DESC;

-- Q18 | INTERMEDIATE | Delivery performance by warehouse
-- Definition: Compare on-time delivery percentage and average delivery days by warehouse.

SELECT Warehouse,
       COUNT(*) AS Delivered_Lines,
       CAST(SUM(CASE WHEN Delivery_Status IN ('On Time', 'Early') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS OnTime_Pct,
       CAST(AVG(Actual_Delivery_Days * 1.0) AS DECIMAL(5,2)) AS Avg_Delivery_Days
FROM dbo.Sales_Analytics
WHERE Delivery_Status IS NOT NULL AND Delivery_Status <> ''
GROUP BY Warehouse
ORDER BY OnTime_Pct DESC;

-- Q19 | INTERMEDIATE | Subquery : products earning more than the average product
-- Definition: Find products earning more than the average product revenue

SELECT Product_ID, Product_Name, SUM(Realized_Revenue) AS Revenue
FROM dbo.Sales_Analytics
GROUP BY Product_ID, Product_Name
HAVING SUM(Realized_Revenue) > (SELECT AVG(Rev)
                                FROM (SELECT SUM(Realized_Revenue) AS Rev
                                      FROM dbo.Sales_Analytics
                                      GROUP BY Product_ID) t)
ORDER BY Revenue DESC;

-- Q20 | INTERMEDIATE | Top repeat customers (10+ orders)
-- Definition: Find customers with at least 10 distinct orders and rank by revenue.

SELECT TOP 10 Customer_ID, Customer_Name,
       COUNT(DISTINCT Order_ID) AS Orders,
       SUM(Realized_Revenue)    AS Revenue
FROM dbo.Sales_Analytics
GROUP BY Customer_ID, Customer_Name
HAVING COUNT(DISTINCT Order_ID) >= 10
ORDER BY Revenue DESC;

-- Q21 | INTERMEDIATE | CTE + window total : top 5 states and their revenue share
-- Definition: Show the five highest-revenue states and their share of total revenue.

WITH st AS (
    SELECT State, SUM(Realized_Revenue) AS Revenue
    FROM dbo.Sales_Analytics
    GROUP BY State
)
SELECT TOP 5 State, Revenue,
       CAST(100.0 * Revenue / SUM(Revenue) OVER () AS DECIMAL(5,2)) AS Share_Pct
FROM st
ORDER BY Revenue DESC;


-- Q22 | INTERMEDIATE | String functions : split customer name, most common surnames
-- Definition: Use string functions to split customer names and count surname patterns.

SELECT TOP 10 Customer_Name,
       UPPER(Customer_Name) AS Name_Upper,
       CASE WHEN CHARINDEX(' ', Customer_Name) > 0
            THEN LEFT(Customer_Name, CHARINDEX(' ', Customer_Name) - 1)
            ELSE Customer_Name END AS First_Name,
       CASE WHEN CHARINDEX(' ', Customer_Name) > 0
            THEN SUBSTRING(Customer_Name, CHARINDEX(' ', Customer_Name) + 1, LEN(Customer_Name))
            ELSE '' END AS Last_Name,
       LEN(Customer_Name) AS Name_Length
FROM dbo.Sales_Analytics;
 
SELECT TOP 10 SUBSTRING(Customer_Name, CHARINDEX(' ', Customer_Name) + 1, LEN(Customer_Name)) AS Last_Name,
       COUNT(DISTINCT Customer_ID) AS Customers
FROM dbo.Sales_Analytics
GROUP BY SUBSTRING(Customer_Name, CHARINDEX(' ', Customer_Name) + 1, LEN(Customer_Name))
ORDER BY Customers DESC;

-- Q23 | INTERMEDIATE | Date functions : delivery time by ship mode, last 90 days
-- Definition: Calculate average delivery time by ship mode and sales in the latest 90 days of data.

SELECT Ship_Mode,
       CAST(AVG(DATEDIFF(DAY, Order_Date, Delivery_Date) * 1.0) AS DECIMAL(5,2)) AS Avg_Days_To_Deliver
FROM dbo.Sales_Analytics
WHERE Delivery_Date IS NOT NULL
GROUP BY Ship_Mode
ORDER BY Avg_Days_To_Deliver;
 
SELECT COUNT(DISTINCT Order_ID) AS Orders_Last_90_Days,
       SUM(Net_Sales)           AS Net_Sales_Last_90_Days
FROM dbo.Sales_Analytics
WHERE Order_Date >= DATEADD(DAY, -90, (SELECT MAX(Order_Date) FROM dbo.Sales_Analytics));

-- Q24 | INTERMEDIATE | Discount impact : bands vs margin and loss-making lines
-- Definition: Compare margin and loss-making lines across discount bands.

SELECT CASE WHEN Discount_Pct = 0  THEN '0%'
            WHEN Discount_Pct <= 10 THEN '1-10%'
            WHEN Discount_Pct <= 20 THEN '11-20%'
            WHEN Discount_Pct <= 30 THEN '21-30%'
            ELSE '31%+' END AS Discount_Band,
       COUNT(*) AS Lines,
       SUM(Net_Sales) AS Net_Sales,
       CAST(AVG(Gross_Margin_Pct) AS DECIMAL(5,2)) AS Avg_Gross_Margin_Pct,
       SUM(CASE WHEN Gross_Profit < 0 THEN 1 ELSE 0 END) AS Loss_Making_Lines
FROM dbo.Sales_Analytics
GROUP BY CASE WHEN Discount_Pct = 0  THEN '0%'
              WHEN Discount_Pct <= 10 THEN '1-10%'
              WHEN Discount_Pct <= 20 THEN '11-20%'
              WHEN Discount_Pct <= 30 THEN '21-30%'
              ELSE '31%+' END
ORDER BY MIN(Discount_Pct);
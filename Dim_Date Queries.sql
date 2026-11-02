USE SalesAnalyticsDB;
GO

IF OBJECT_ID('dbo.Dim_Date', 'U') IS NOT NULL
    DROP TABLE dbo.Dim_Date;

CREATE TABLE dbo.Dim_Date (
    [Date] DATE PRIMARY KEY,
    [Year] INT,
    [Quarter] VARCHAR(2),
    [Month Num] INT,
    [Month] VARCHAR(3),
    [Year-Month] CHAR(7),
    [Month Year] VARCHAR(12),
    [Year Month Num] INT,
    [Month Start] DATE,
    [Week Num] INT,
    [Weekday Num] INT,
    [Weekday] VARCHAR(3),
    [Day Type] VARCHAR(10),
    [Fiscal Year] VARCHAR(9),
    [Fiscal Quarter] VARCHAR(3)
);

DECLARE @StartDate DATE = '2023-01-01';
DECLARE @EndDate DATE = (SELECT MAX(Order_Date) FROM dbo.Sales_Analytics);

;WITH N AS (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
D AS (
    SELECT DATEADD(DAY, n, @StartDate) AS dt
    FROM N
)
INSERT INTO dbo.Dim_Date (
    [Date], [Year], [Quarter], [Month Num], [Month],
    [Year-Month], [Month Year], [Year Month Num],
    [Month Start], [Week Num], [Weekday Num], [Weekday],
    [Day Type], [Fiscal Year], [Fiscal Quarter]
)
SELECT
    dt,
    YEAR(dt),
    'Q' + CAST(DATEPART(QUARTER, dt) AS VARCHAR(1)),
    MONTH(dt),
    LEFT(DATENAME(MONTH, dt), 3),
    CONVERT(CHAR(7), dt, 120),
    LEFT(DATENAME(MONTH, dt), 3) + ' ' + CAST(YEAR(dt) AS VARCHAR(4)),
    YEAR(dt) * 100 + MONTH(dt),
    DATEFROMPARTS(YEAR(dt), MONTH(dt), 1),
    DATEPART(ISO_WEEK, dt),
    (DATEDIFF(DAY, '19000101', dt) % 7) + 1,
    LEFT(DATENAME(WEEKDAY, dt), 3),
    CASE WHEN (DATEDIFF(DAY, '19000101', dt) % 7) + 1 >= 6
         THEN 'Weekend' ELSE 'Weekday' END,
    CASE WHEN MONTH(dt) >= 4
         THEN 'FY ' + CAST(YEAR(dt) AS VARCHAR(4)) + '-' +
              RIGHT(CAST(YEAR(dt) + 1 AS VARCHAR(4)), 2)
         ELSE 'FY ' + CAST(YEAR(dt) - 1 AS VARCHAR(4)) + '-' +
              RIGHT(CAST(YEAR(dt) AS VARCHAR(4)), 2)
    END,
    CASE
        WHEN MONTH(dt) IN (4, 5, 6) THEN 'FQ1'
        WHEN MONTH(dt) IN (7, 8, 9) THEN 'FQ2'
        WHEN MONTH(dt) IN (10, 11, 12) THEN 'FQ3'
        ELSE 'FQ4'
    END
FROM D;

SELECT COUNT(*) AS Total_Days,
       MIN([Date]) AS First_Date,
       MAX([Date]) AS Last_Date
FROM dbo.Dim_Date;

USE SalesAnalyticsDB;
GO

ALTER TABLE dbo.Dim_Date
ALTER COLUMN [Fiscal Year] VARCHAR(10);
GO

SELECT
    COUNT(*) AS Total_Days,
    MIN([Date]) AS First_Date,
    MAX([Date]) AS Last_Date
FROM dbo.Dim_Date;

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Order_Date) AS Non_Null_Order_Dates,
    MIN(Order_Date) AS First_Order_Date,
    MAX(Order_Date) AS Last_Order_Date
FROM dbo.Sales_Analytics;

USE SalesAnalyticsDB;

DECLARE @StartDate DATE = '2023-01-01';
DECLARE @EndDate DATE = (
    SELECT MAX(Order_Date)
    FROM dbo.Sales_Analytics
);

;WITH N AS (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
D AS (
    SELECT DATEADD(DAY, n, @StartDate) AS dt
    FROM N
)
INSERT INTO dbo.Dim_Date (
    [Date], [Year], [Quarter], [Month Num], [Month],
    [Year-Month], [Month Year], [Year Month Num],
    [Month Start], [Week Num], [Weekday Num], [Weekday],
    [Day Type], [Fiscal Year], [Fiscal Quarter]
)
SELECT
    dt,
    YEAR(dt),
    'Q' + CAST(DATEPART(QUARTER, dt) AS VARCHAR(1)),
    MONTH(dt),
    LEFT(DATENAME(MONTH, dt), 3),
    CONVERT(CHAR(7), dt, 120),
    LEFT(DATENAME(MONTH, dt), 3) + ' ' + CAST(YEAR(dt) AS VARCHAR(4)),
    YEAR(dt) * 100 + MONTH(dt),
    DATEFROMPARTS(YEAR(dt), MONTH(dt), 1),
    DATEPART(ISO_WEEK, dt),
    (DATEDIFF(DAY, '19000101', dt) % 7) + 1,
    LEFT(DATENAME(WEEKDAY, dt), 3),
    CASE WHEN (DATEDIFF(DAY, '19000101', dt) % 7) + 1 >= 6
         THEN 'Weekend' ELSE 'Weekday' END,
    CASE WHEN MONTH(dt) >= 4
         THEN 'FY ' + CAST(YEAR(dt) AS VARCHAR(4)) + '-' +
              RIGHT(CAST(YEAR(dt) + 1 AS VARCHAR(4)), 2)
         ELSE 'FY ' + CAST(YEAR(dt) - 1 AS VARCHAR(4)) + '-' +
              RIGHT(CAST(YEAR(dt) AS VARCHAR(4)), 2)
    END,
    CASE
        WHEN MONTH(dt) IN (4, 5, 6) THEN 'FQ1'
        WHEN MONTH(dt) IN (7, 8, 9) THEN 'FQ2'
        WHEN MONTH(dt) IN (10, 11, 12) THEN 'FQ3'
        ELSE 'FQ4'
    END
FROM D
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Dim_Date existing
    WHERE existing.[Date] = D.dt
);

SELECT COUNT(*) AS Total_Days,
       MIN([Date]) AS First_Date,
       MAX([Date]) AS Last_Date
FROM dbo.Dim_Date;

    SELECT TOP 10 *
    FROM dbo.Dim_Date
    ORDER BY [Date];

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Sales_Analytics'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10
    S.Order_Date,
    D.[Year],
    D.[Quarter],
    D.[Month],
    D.[Month Year],
    D.[Day Type],
    S.Net_Sales
FROM dbo.Sales_Analytics AS S
INNER JOIN dbo.Dim_Date AS D
    ON CAST(S.Order_Date AS DATE) = D.[Date]
ORDER BY S.Order_Date;

-- monthly sales analysis
SELECT
    D.[Year],
    D.[Month],
    D.[Month Year],
    SUM(S.Net_Sales) AS Total_Net_Sales,
    SUM(S.Realized_Profit) AS Total_Realized_Profit
FROM dbo.Sales_Analytics AS S
INNER JOIN dbo.Dim_Date AS D
    ON CAST(S.Order_Date AS DATE) = D.[Date]
GROUP BY
    D.[Year],
    D.[Month],
    D.[Month Year],
    D.[Year Month Num]
ORDER BY
    D.[Year Month Num];

-- Category-wise Sales & Profit Analysis
SELECT
    Category,
    SUM(Quantity) AS Total_Quantity,
    SUM(Net_Sales) AS Total_Net_Sales,
    SUM(Realized_Profit) AS Total_Realized_Profit,
    AVG(Gross_Margin_Pct) AS Avg_Gross_Margin_Pct
FROM dbo.Sales_Analytics
GROUP BY Category
ORDER BY Total_Net_Sales DESC;

-- Region-wise Sales Performance
SELECT
    Region,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Net_Sales) AS Total_Net_Sales,
    SUM(Realized_Profit) AS Total_Realized_Profit,
    AVG(Customer_Rating) AS Avg_Customer_Rating
FROM dbo.Sales_Analytics
GROUP BY Region
ORDER BY Total_Net_Sales DESC;

-- Top 10 Products by Sales
SELECT TOP 10
    Product_Name,
    Category,
    SUM(Quantity) AS Total_Quantity,
    SUM(Net_Sales) AS Total_Net_Sales,
    SUM(Realized_Profit) AS Total_Realized_Profit
FROM dbo.Sales_Analytics
GROUP BY
    Product_Name,
    Category
ORDER BY
    Total_Net_Sales DESC;
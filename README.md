# Power_BI---salesiq-360-sql-powerbi
End-to-end sales analytics project: SQL Server database + Power BI dashboard (4 pages, 50+ DAX measures) covering revenue, profit, customers, returns and delivery performance.

Topics: power-bi, sql-server, dax, data-analytics, business-intelligence, dashboard, sales-analytics

# SalesIQ 360 | SQL + Power BI Analytics Dashboard

End-to-end sales analytics project: data modeling in SQL Server and a 4-page Power BI dashboard.

## Overview
Analyses a synthetic India e-commerce dataset (62,360 order lines, 31,500 orders, 8,378 active customers, Jan 2023 to Oct 2026) to track revenue, profitability, customer behaviour, returns and delivery performance.

## Tech Stack
SQL Server | Power BI | DAX | Power Query

## Dashboard Pages
| Page | What it shows |
|---|---|
| Executive Overview | KPIs, revenue by state, category, region and channel, monthly trend |
| Product Analysis | Top 10 products, sub-category mix, discount vs margin, return rate |
| Customer & Geography | Loyalty tier, age group, city revenue, new vs returning customers |
| Operations & Delivery | On-time delivery, delay by carrier, delivery days, return reasons |
| Product Detail (drillthrough) | Revenue trend, region and channel split for a selected product |

## Key Outcomes
- Revenue ₹29.07 Cr, profit ₹4.43 Cr, margin 15.2%, 29,196 delivered orders, AOV ₹9,957
- Electronics contributes ~52% of revenue; Distributor/B2B is the largest channel (27%)
- Top-selling products have near-zero or negative margin (e.g. realme Pro 5G 256GB: ₹2.06 Cr revenue, -0.06% margin)
- On-time delivery 78% vs 85% target; return rate 7.1%; average delivery time 3.27 days

## Project Structure
├── data/         Sales_Analytics_Dataset.csv
├── sql/          table creation, Dim_Date, analysis queries
├── powerbi/      SalesIQ_360_Dashboard.pbix, theme, DAX measures
└── screenshots/  dashboard page images

## How to Run
1. Run the table creation script in /sql and load the CSV.
2. Run the Dim_Date script.
3. Open the .pbix in Power BI Desktop and point the data source to your SQL Server.

## Note
The dataset is synthetic, created for learning and portfolio purposes.

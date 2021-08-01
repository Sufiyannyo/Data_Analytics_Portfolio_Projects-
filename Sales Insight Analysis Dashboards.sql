-- Link to visualisation on Tableau: https://public.tableau.com/app/profile/sufiyan.n.yo/viz/SalesInsightsDashboard_16278196206930/SalesandRevenueOverview

-- Extracting tables to Excel for visaulisation in Tableau
SELECT * FROM customers;

SELECT * FROM date;

SELECT * FROM markets;

SELECT * FROM products;

SELECT * FROM transactions;

-- Total number of customers

SELECT count(*) 
FROM customers;

-- Show transactions for Chennai market (market code for chennai is Mark001

SELECT * 
FROM transactions 
WHERE market_code='Mark001';

-- Show distrinct product codes that were sold in chennai

SELECT DISTINCT product_code 
FROM transactions 
WHERE market_code='Mark001';

-- Show transactions where currency is US dollars

SELECT * 
FROM transactions 
WHERE currency="USD"

-- Show transactions in 2019 join by date table

SELECT trans.*, date.*
FROM transactions trans
INNER JOIN date ON trans.order_date=date.date 
WHERE date.year=2019

-- Show total revenue in year 2019

SELECT SUM(transactions.sales_amount) 
FROM transactions 
INNER JOIN date ON transactions.order_date=date.date 
WHERE date.year=2019 
-- AND transactions.currency="INR\r" OR transactions.currency="USD\r";

-- Show total revenue in year 2019, May Month,

SELECT SUM(transactions.sales_amount) 
FROM transactions 
INNER JOIN date ON transactions.order_date=date.date 
WHERE date.year=2019 AND date.month_name="May" 
-- AND (transactions.currency="INR\r" OR transactions.currency="USD\r");

-- Show total revenue in year 2018 in Chennai

SELECT SUM(transactions.sales_amount) 
FROM transactions 
INNER JOIN date ON transactions.order_date=date.date 
WHERE date.year=2018 AND transactions.market_code="Mark001";
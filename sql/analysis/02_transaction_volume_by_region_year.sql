-- Query 2: Transaction volume per region per year
--
-- Counts sales per region per year. Provides context for the median-price
-- figures (a price movement on very few sales is less meaningful) and feeds
-- volume trends to the dashboard. Note the market-wide dip around 2008-2009,
-- reflecting the financial crisis.

SELECT r.name AS region_name,
       t.transfer_year AS year,
       COUNT(t.transaction_id) AS transaction_count
FROM transactions t
LEFT JOIN dim_region r ON t.region_id = r.region_id
GROUP BY r.name, t.transfer_year
ORDER BY r.name, t.transfer_year;
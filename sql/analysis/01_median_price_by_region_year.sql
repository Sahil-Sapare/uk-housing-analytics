-- Query 1: Median price per region per year
--
-- The backbone metric. Median rather than mean because a small number of
-- very high-value sales skews the mean upward and misrepresents the typical
-- home. Joined to dim_region for readable names.

SELECT r.name AS region_name, 
t.transfer_year AS year, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
FROM transactions t
LEFT JOIN dim_region r ON t.region_id = r.region_id
GROUP BY r.name, t.transfer_year
ORDER BY r.name, t.transfer_year;

-- Query 4: Year-on-year % change in median price, per region
--
-- First window-function query. LAG() lets each region-year row read the
-- previous year's median without collapsing rows the way GROUP BY does.
-- PARTITION BY region_name restarts the sequence per region; ORDER BY year
-- defines "previous".
--
-- Built in stages via chained CTEs: (1) median per region-year, (2) attach
-- the prior year via LAG, (3) compute the percentage change. The change
-- must be computed in a later stage because a column alias cannot be
-- referenced within the same SELECT that defines it.
--
-- The first year of each region is NULL: there is no prior year to compare
-- against. NULL (not zero) is correct here - zero would cause division by
-- zero and imply a meaningless infinite change.

WITH median_price_by_region_year AS (
    SELECT r.name AS region_name,
           t.transfer_year AS year,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    GROUP BY r.name, t.transfer_year
),
with_prev AS (
    SELECT region_name, year, median_price,
           LAG(median_price) OVER (PARTITION BY region_name ORDER BY year) AS prev_year_price
    FROM median_price_by_region_year
)
SELECT region_name, year, median_price, prev_year_price,
       ROUND(((median_price - prev_year_price) / prev_year_price * 100)::numeric, 2) AS yoy_pct_change
FROM with_prev
ORDER BY region_name, year;

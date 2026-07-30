-- Query 8: Affordability ratio per region per year
--
-- The project's headline metric: median house price / median gross annual pay.
-- A ratio of 8 means a typical home costs eight years' salary in that region
-- that year - the standard affordability measure used by ONS and housing
-- economists.
--
-- First query to join both datasets. Median price (from transactions) is
-- computed in the CTE, then inner-joined to the earnings table. Aggregating
-- first, then joining the ~288-row result to the 288-row earnings table, is
-- far cheaper than joining 29.5M raw rows and aggregating afterwards.
--
-- The join is on region AND year, not region alone. Both tables are at
-- region-year grain, so joining on region only would fan out - each price row
-- matching all 24 years of that region's earnings, pairing e.g. 2015 prices
-- with 2008 salaries. Two keys pin each price to its one correct earnings row.
--
-- Inner JOIN (not LEFT) is deliberate: it keeps only region-years present in
-- both sources. This drops 1995-2001 and 2026 (no earnings) and Scotland and
-- Northern Ireland (no prices), leaving the 2002-2025 England-and-Wales
-- overlap - the only span where a ratio is defined.

WITH median_price_by_region_year AS (
    SELECT r.name AS region_name,
           t.transfer_year AS year,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    GROUP BY r.name, t.transfer_year
)
SELECT mp.region_name, mp.year, mp.median_price, e.median_pay,
       ROUND((mp.median_price / e.median_pay)::numeric, 2) AS affordability_ratio
FROM median_price_by_region_year AS mp
JOIN earnings e ON mp.region_name = e.region AND mp.year = e.year
ORDER BY mp.region_name, mp.year;

-- Query 10: Change in affordability since 2002, per region
--
-- Ties Tier 3 together: query 8 gave the ratio each year, query 9 the latest
-- snapshot, and this measures the movement - how much each region's
-- price-to-earnings ratio worsened (or improved) from 2002 to the latest year.
--
-- FIRST_VALUE and LAST_VALUE pull each region's earliest and latest ratio,
-- rather than hardcoding 2002 and 2025, so the query survives new data and any
-- missing early years. LAST_VALUE needs the explicit full frame (UNBOUNDED
-- PRECEDING AND UNBOUNDED FOLLOWING): with the default frame it returns the
-- current row, not the partition's last. FIRST_VALUE is given the same frame
-- for symmetry, though its default would already be correct.
--
-- The change is last - first, so a positive number means affordability
-- worsened (the ratio rose). SELECT DISTINCT collapses to one row per region;
-- it works only because every selected column is constant within a region -
-- the per-year detail columns are deliberately excluded.

WITH median_price_by_region_year AS (
    SELECT r.name AS region_name,
           t.transfer_year AS year,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    GROUP BY r.name, t.transfer_year
),
with_earnings AS (
    SELECT mp.region_name, mp.year, mp.median_price, e.median_pay,
           ROUND((mp.median_price / e.median_pay)::numeric, 2) AS affordability_ratio
    FROM median_price_by_region_year AS mp
    JOIN earnings e ON mp.region_name = e.region AND mp.year = e.year
),
with_window_affordability_fn AS (
    SELECT region_name, affordability_ratio,
           FIRST_VALUE(affordability_ratio) OVER (
               PARTITION BY region_name ORDER BY year
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS first_value,
           LAST_VALUE(affordability_ratio) OVER (
               PARTITION BY region_name ORDER BY year
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS last_value
    FROM with_earnings
)
SELECT DISTINCT region_name, first_value, last_value,
       (last_value - first_value) AS affordability_change
FROM with_window_affordability_fn
ORDER BY affordability_change DESC;

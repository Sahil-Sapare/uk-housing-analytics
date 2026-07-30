-- Query 6: Regions ranked by median price, per year
--
-- Ranks the 12 regions most- to least-expensive within each year, and shows
-- whether that order shifts over time. PARTITION BY year (not region) is the
-- key choice: the ranking compares regions against each other within a single
-- year, rather than a region against its own past.
--
-- No GROUP BY in the outer query: the CTE already aggregated raw sales into one
-- median per region-year, so each row is a single region-year. RANK() then runs
-- across those rows without collapsing them - window functions and GROUP BY are
-- opposites.
--
-- The ORDER BY inside OVER() drives the ranking; the ORDER BY at the end only
-- controls display order (year, then rank).

WITH median_price_by_region_year AS (
    SELECT r.name AS region_name,
           t.transfer_year AS year,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    GROUP BY r.name, t.transfer_year
)
SELECT year, region_name, median_price,
       RANK() OVER (PARTITION BY year ORDER BY median_price DESC) AS rank
FROM median_price_by_region_year
ORDER BY year, rank;

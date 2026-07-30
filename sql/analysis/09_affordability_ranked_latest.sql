-- Query 9: Affordability ranking, latest year
--
-- A snapshot league table of the regions today, ranked least to most
-- affordable (rank 1 = highest price-to-earnings ratio). Builds on query 8:
-- the ratio is computed in CTEs, then filtered to the most recent year and
-- ranked.
--
-- The latest year is found with a subquery, SELECT MAX(year) FROM earnings,
-- rather than hardcoding 2025. When newer earnings data is loaded, the query
-- automatically reports the new latest year instead of silently showing stale
-- figures.
--
-- RANK() needs no PARTITION BY here: it is a single year, so all 10 regions
-- (England and Wales only, since earnings joins drop Scotland and NI) are
-- ranked against each other in one group.

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
)
SELECT region_name, year, median_price, median_pay, affordability_ratio,
       RANK() OVER (ORDER BY affordability_ratio DESC) AS rank
FROM with_earnings
WHERE year = (SELECT MAX(year) FROM earnings)
ORDER BY rank;

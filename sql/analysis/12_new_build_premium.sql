-- Query 12: New-build premium by region and year
--
-- How much more new-builds sell for than existing homes, as a percentage,
-- per region per year. First use of the is_new_build flag.
--
-- Two conditional medians via FILTER: PERCENTILE_CONT ... FILTER (WHERE
-- is_new_build) computes the median over new-builds only, and its NOT
-- counterpart over existing homes. FILTER is the clean way to do conditional
-- ordered-set aggregation, since CASE cannot sit inside WITHIN GROUP.
--
-- Two data-quality guards:
--   1. WHERE transfer_year < MAX(transfer_year) drops the latest year, which
--      is always a partial year of registrations and would otherwise sit at
--      the end of every trend as a misleading incomplete point. Using MAX
--      rather than a hardcoded year keeps this correct as new data loads.
--   2. HAVING COUNT(*) FILTER (WHERE is_new_build) >= 30 drops region-years
--      with too few new-build sales for a stable median, removing wild
--      premiums in sparse early-1990s region-years.
--
-- Price-only query, so it spans the full transactions range rather than the
-- 2002-2025 earnings overlap.

WITH median_price AS (
    SELECT r.name AS region_name,
           t.transfer_year AS year,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price)
             FILTER (WHERE t.is_new_build) AS new_build_median_price,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price)
             FILTER (WHERE NOT t.is_new_build) AS old_build_median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    WHERE t.transfer_year < (SELECT MAX(transfer_year) FROM transactions)
    GROUP BY r.name, t.transfer_year
    HAVING COUNT(*) FILTER (WHERE t.is_new_build) >= 30
)
SELECT region_name, year,
       new_build_median_price, old_build_median_price,
       ROUND(((new_build_median_price - old_build_median_price)
              / old_build_median_price * 100)::numeric, 2) AS new_build_premium_pct
FROM median_price
ORDER BY region_name, year;

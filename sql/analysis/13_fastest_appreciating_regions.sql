-- Query 13: Fastest-appreciating regions (total median-price growth)
--
-- A league table of regions by total growth in median price from the first
-- year to the latest complete year, as a percentage. Distils query 7's price
-- index into a single ranked figure per region.
--
-- Deliberately a different question from affordability (query 9): a region can
-- have grown fastest in percentage terms while remaining cheap in absolute
-- terms, because it grew from a low base. Comparing this ranking with the
-- affordability ranking is itself a finding.
--
-- FIRST_VALUE / LAST_VALUE pull each region's earliest and latest median price
-- rather than hardcoding years. LAST_VALUE needs the explicit full frame
-- (UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING); with the default frame it
-- returns the current row, not the partition's last.
--
-- The latest year is excluded (WHERE transfer_year < MAX) because it is a
-- partial year of registrations. This matters more here than elsewhere: the
-- growth metric is anchored on the latest value, so a partial endpoint would
-- distort every region's figure.
--
-- SELECT DISTINCT collapses to one row per region; it works only because every
-- selected column is constant within a region.

WITH median_price_by_region_year AS (
    SELECT r.name AS region_name,
           t.transfer_year AS year,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    WHERE t.transfer_year < (SELECT MAX(transfer_year) FROM transactions)
    GROUP BY r.name, t.transfer_year
),
with_endpoints AS (
    SELECT region_name,
           FIRST_VALUE(median_price) OVER (
               PARTITION BY region_name ORDER BY year
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS first_price,
           LAST_VALUE(median_price) OVER (
               PARTITION BY region_name ORDER BY year
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS latest_price
    FROM median_price_by_region_year
),
distinct_regions AS (
    SELECT DISTINCT region_name, first_price, latest_price,
           ROUND(((latest_price - first_price) / first_price * 100)::numeric, 2) AS total_growth_pct
    FROM with_endpoints
)
SELECT region_name, first_price, latest_price, total_growth_pct,
       RANK() OVER (ORDER BY total_growth_pct DESC) AS rank
FROM distinct_regions
ORDER BY rank;

-- Query 7: Price index since 1995, per region (1995 = 100)
--
-- Rebases each region's median price to its 1995 value = 100, so growth can be
-- compared proportionally rather than in absolute pounds. This separates two
-- different questions: which region is most expensive (absolute level) versus
-- which has grown fastest (proportional growth). A cheaper region can show a
-- higher index than London - growing faster from a lower base - even while
-- staying cheaper in absolute terms.
--
-- Not a cumulative/running total: it is an indexed (rebased) series, the same
-- construction the ONS House Price Index uses.
--
-- FIRST_VALUE grabs each region's 1995 median and exposes it on every row. The
-- explicit frame (UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) makes "first"
-- mean the earliest year across the whole region, not just rows seen so far.
-- Split into two CTEs because the index arithmetic cannot reference the
-- FIRST_VALUE alias in the same SELECT that defines it.

WITH median_price_by_region_year AS (
    SELECT r.name AS region_name,
           t.transfer_year AS year,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    GROUP BY r.name, t.transfer_year
),
with_first_value AS (
    SELECT region_name, year, median_price,
           FIRST_VALUE(median_price) OVER (
               PARTITION BY region_name ORDER BY year
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS first_price_value
    FROM median_price_by_region_year
)
SELECT region_name, year, median_price,
       ROUND((median_price / first_price_value * 100)::numeric, 2) AS price_index
FROM with_first_value
ORDER BY region_name, year;

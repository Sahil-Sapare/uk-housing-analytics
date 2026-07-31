-- Query 11: London vs North divergence in affordability
--
-- The project's headline narrative. Tracks the gap between London's
-- affordability ratio and the average of the three northern regions (North
-- East, North West, Yorkshire and The Humber) each year, showing whether the
-- two are pulling apart.
--
-- Affordability (price / earnings) is used rather than raw price: a price gap
-- partly just reflects that London earns more, whereas the affordability gap
-- captures what actually matters - how house prices compare to local incomes.
--
-- Conditional aggregation with CASE: MAX(CASE ... London ...) plucks London's
-- single ratio per year (aggregate skips the NULLs the CASE leaves on other
-- regions); AVG(CASE ... northern regions ...) averages just the three named
-- regions, since AVG ignores the NULLs on everything else. A simple average of
-- the three ratios is used, not a population-weighted one, so each northern
-- region counts equally rather than the larger North West dominating.
--
-- The gap subtraction sits in the outer query because the london_ratio and
-- north_avg_ratio aliases cannot be referenced in the same SELECT that defines
-- them.

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
with_case AS (
    SELECT year,
           MAX(CASE WHEN region_name = 'London' THEN affordability_ratio END) AS london_ratio,
           ROUND(AVG(CASE WHEN region_name IN ('North East', 'North West', 'Yorkshire and The Humber')
                          THEN affordability_ratio END), 2) AS north_avg_ratio
    FROM with_earnings
    GROUP BY year
)
SELECT year, london_ratio, north_avg_ratio,
       (london_ratio - north_avg_ratio) AS affordability_gap
FROM with_case
ORDER BY year;

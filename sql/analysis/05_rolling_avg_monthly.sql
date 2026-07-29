-- Query 5: 12-month rolling average of median price, per region (monthly)
--
-- Unlike the other queries, this works at monthly grain. Monthly medians are
-- noisy - low-volume regions and months swing sharply - so a 12-month trailing
-- window smooths the series into a trend and removes seasonal variation.
--
-- DATE_TRUNC('month', ...) collapses each date to the first of its month,
-- giving one orderable date per month. The window frame
-- ROWS BETWEEN 11 PRECEDING AND CURRENT ROW averages each month with the 11
-- before it (12 months total, counting the current row).
--
-- Note: this averages the monthly *medians*, not a recomputed median over each
-- 12-month span - the standard approach for a rolling trend line. The first 11
-- months of each region average fewer than 12 points, as there is no earlier
-- data to draw on yet.

WITH median_price_by_region_month AS (
    SELECT r.name AS region_name,
           DATE_TRUNC('month', t.transfer_date)::date AS date_by_month,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    GROUP BY r.name, DATE_TRUNC('month', t.transfer_date)
)
SELECT region_name, date_by_month, median_price,
       AVG(median_price)
         OVER (PARTITION BY region_name ORDER BY date_by_month
               ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS twelve_month_rolling_avg
FROM median_price_by_region_month
ORDER BY region_name, date_by_month;
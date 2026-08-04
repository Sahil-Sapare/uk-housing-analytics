-- Aggregated views for the Power BI dashboard.
-- Power BI connects to these small result sets, not the 29.5M-row fact table.
-- A view is a saved query that behaves like a table: Postgres runs the
-- aggregation, Power BI sees only the ~300-row result.

-- Median price per region per year (the backbone series)
CREATE OR REPLACE VIEW v_median_price AS
SELECT r.name AS region_name,
       t.transfer_year AS year,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
FROM transactions t
LEFT JOIN dim_region r ON t.region_id = r.region_id
WHERE t.transfer_year < (SELECT MAX(transfer_year) FROM transactions)
GROUP BY r.name, t.transfer_year;

-- Affordability ratio per region per year
CREATE OR REPLACE VIEW v_affordability AS
WITH mp AS (
    SELECT r.name AS region_name, t.transfer_year AS year,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
    FROM transactions t
    LEFT JOIN dim_region r ON t.region_id = r.region_id
    GROUP BY r.name, t.transfer_year
)
SELECT mp.region_name, mp.year, mp.median_price, e.median_pay,
       ROUND((mp.median_price / e.median_pay)::numeric, 2) AS affordability_ratio
FROM mp
JOIN earnings e ON mp.region_name = e.region AND mp.year = e.year;

-- Transaction volume per region per year
CREATE OR REPLACE VIEW v_volume AS
SELECT r.name AS region_name, t.transfer_year AS year,
       COUNT(*) AS transaction_count
FROM transactions t
LEFT JOIN dim_region r ON t.region_id = r.region_id
WHERE t.transfer_year < (SELECT MAX(transfer_year) FROM transactions)
GROUP BY r.name, t.transfer_year;

-- Median price per region per year per property type

CREATE OR REPLACE VIEW v_price_by_type AS
SELECT
    r.region_name,
    t.transfer_year AS year,
    pt.property_type_name AS property_type,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY t.price)::int AS median_price
FROM transactions t
JOIN dim_region r        ON t.region_id = r.region_id
JOIN dim_property_type pt ON t.property_type_id = pt.property_type_id
WHERE t.transfer_year < 2025          -- exclude partial latest year, matching your other views
GROUP BY r.region_name, t.transfer_year, pt.property_type_name;

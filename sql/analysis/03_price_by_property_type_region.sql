-- Query 3: Median price by property type, region, and year
--
-- Compares property types (detached, semi, terraced, flat, other) within
-- each region. Split by year deliberately: median price is nominal, so
-- averaging across years would blend three decades of inflation into a
-- figure representing no real point in time. Keeping year as a dimension
-- means comparisons are always like-for-like within a single year.
--
-- Brings in dim_property_type for the first time, alongside dim_region.

SELECT r.name AS region_name,
       pt.description AS property_type,
       t.transfer_year AS year,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY t.price) AS median_price
FROM transactions t
LEFT JOIN dim_region r ON t.region_id = r.region_id
LEFT JOIN dim_property_type pt ON t.property_type_id = pt.property_type_id
GROUP BY r.name, pt.description, t.transfer_year
ORDER BY r.name, t.transfer_year, pt.description;
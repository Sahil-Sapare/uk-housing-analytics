-- Dimension tables for the star schema.
--
-- dim_region holds the 12 UK regions used by ONS ASHE. Land Registry data
-- has no region column, so region is derived from county via a mapping
-- table (see county_region_map below).

DROP TABLE IF EXISTS dim_property_type CASCADE;
DROP TABLE IF EXISTS dim_region CASCADE;
DROP TABLE IF EXISTS county_region_map CASCADE;

-- Property type codes, per HM Land Registry documentation.
CREATE TABLE dim_property_type (
    property_type_id SERIAL PRIMARY KEY,
    code             CHAR(1) UNIQUE NOT NULL,
    description      TEXT NOT NULL
);

INSERT INTO dim_property_type (code, description) VALUES
    ('D', 'Detached'),
    ('S', 'Semi-Detached'),
    ('T', 'Terraced'),
    ('F', 'Flat / Maisonette'),
    ('O', 'Other');

-- The 12 regions, matching the region names used in the earnings table.
-- Scotland and Northern Ireland are included for consistency with ASHE,
-- but Price Paid covers England and Wales only, so no transactions will
-- join to them.
CREATE TABLE dim_region (
    region_id SERIAL PRIMARY KEY,
    name      TEXT UNIQUE NOT NULL
);

INSERT INTO dim_region (name) VALUES
    ('North East'),
    ('North West'),
    ('Yorkshire and The Humber'),
    ('East Midlands'),
    ('West Midlands'),
    ('East'),
    ('London'),
    ('South East'),
    ('South West'),
    ('Wales'),
    ('Scotland'),
    ('Northern Ireland');

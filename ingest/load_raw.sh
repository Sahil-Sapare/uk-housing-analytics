#!/bin/bash
# Bulk-load HM Land Registry Price Paid data, then build the star schema.
# Staging load: 31,346,259 rows in ~95s via COPY.
# Fact table: 29,550,867 standard transactions.
set -e

# 1. Staging: create the all-TEXT table and bulk-load the raw CSV.
psql housing -f sql/01_create_staging.sql
time psql housing -c "\copy raw_transactions FROM 'data/pp-complete.csv' WITH (FORMAT csv, QUOTE '\"', NULL '')"
psql housing -c "SELECT COUNT(*) FROM raw_transactions;"

# 2. Star schema: dimensions, county-region mapping, typed fact table, indexes.
psql housing -f sql/02_create_dimensions.sql
psql housing -f sql/03_county_region_mapping.sql
psql housing -f sql/04_create_fact_table.sql
psql housing -f sql/05_add_indexes.sql
psql housing -c "SELECT COUNT(*) FROM transactions;"

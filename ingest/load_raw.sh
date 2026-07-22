#!/bin/bash
# Bulk-load HM Land Registry Price Paid data into the staging table.
# Result: 31,346,259 rows loaded in ~95s via COPY.

set -e

psql housing -f sql/01_create_staging.sql

time psql housing -c "\copy raw_transactions FROM 'data/pp-complete.csv' WITH (FORMAT csv, QUOTE '\"', NULL '')"

psql housing -c "SELECT COUNT(*) FROM raw_transactions;"

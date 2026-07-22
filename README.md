# UK Housing Analytics

Analytics pipeline over 31M+ UK property transactions: a PostgreSQL schema,
analytical SQL, and a Power BI dashboard on regional prices and affordability.

*Work in progress - July 2026.*

## Overview

This project combines two open UK datasets to answer a question that neither
can answer alone: not just how house prices have moved since 1995, but how
they have moved *relative to what people in each region actually earn*.

Prices come from HM Land Registry; earnings from the ONS. The ratio between
them — median house price divided by median gross annual pay - is the
affordability measure this project is built around.

## Data sources

### HM Land Registry - Price Paid Data

Every residential property sale registered in England and Wales since January
1995. Downloaded as the single complete file (`pp-complete.csv`, ~5.1 GiB).

- Source: [Price Paid Data downloads](https://www.gov.uk/government/statistical-data-sets/price-paid-data-downloads)
- Direct file: [pp-complete.csv](https://price-paid-data.publicdata.landregistry.gov.uk/pp-complete.csv)
- Column definitions: [About the Price Paid Data](https://www.gov.uk/guidance/about-the-price-paid-data)

- **31,346,259 rows**, one per transaction
- 16 columns, **no header row** — the layout is documented separately by
  HM Land Registry
- Key fields: price paid, date of transfer, postcode, property type
  (D/S/T/F/O), old-or-new build, and address components down to county level
- No region column: region is derived from county during schema design

The file is too large to load comfortably into pandas, which is the point -
it forces the analysis into SQL, where it belongs.

### ONS - Annual Survey of Hours and Earnings (ASHE), Table 8

Median gross annual pay by region, from a 1% sample of PAYE employee records,
surveyed each April.

- Source: [ASHE Table 8 — place of residence by local authority](https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/placeofresidencebylocalauthorityashetable8)
- Survey background: [Annual Survey of Hours and Earnings](https://www.ons.gov.uk/ashe)
- Latest bulletin: [Employee earnings in the UK](https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/bulletins/annualsurveyofhoursandearnings/latest)

- Table 8 gives the place-of-residence breakdown, by home-based region down
  to local authority level
- Within each annual release, **Table 8.7a** holds gross annual pay
- 24 annual releases downloaded, covering **2002–2025**

Place-of-residence is used rather than place-of-work because the comparison
of interest is what people *living* in a region earn against what homes *in*
that region cost.

## Repository structure

    ingest/      Python: download and bulk-load into PostgreSQL
    sql/         Numbered, commented analytical queries
    notebooks/   Exploratory work
    dashboard/   Power BI report (.pbix)
    docs/        Schema diagram and dashboard screenshots
    data/        Raw data (gitignored - too large for GitHub)

## Approach

1. **Ingest** — Price Paid is bulk-loaded via PostgreSQL's `COPY` into a wide
   staging table where every column is `TEXT`. Loading untyped avoids a single
   malformed value aborting a 31M-row load; types are cast afterwards in SQL.
   ASHE spreadsheets are small and parsed with pandas.
2. **Schema** — a star schema: a `transactions` fact table with `property_type`
   and `region` dimensions, plus an `earnings` table keyed by region and year.
3. **Analysis** — 10–15 saved SQL queries using window functions and CTEs:
   median price by region and year, year-on-year change, rolling averages,
   affordability ratios, and the London–North divergence.
4. **Dashboard** — Power BI connected to PostgreSQL, reading from aggregate
   SQL views rather than the raw fact table.

## Limitations

- **Coverage differs between sources.** Price Paid runs from 1995; ASHE
  Table 8 from 2002. Price trends therefore span 30 years, but affordability
  analysis is scoped to the 2002–2025 overlap.
- **2025 ASHE figures are provisional.** ONS publishes provisional figures
  each October and revises them the following year. All years to 2024 use the
  revised edition; 2025 uses provisional, and is subject to change.
- **Edition notes.** ONS published two editions of 2006 under different
  methodologies; this project uses the revised edition and is consistent with the 2007 methodology onwards. The
  2011 release used here is the revised edition based on SOC 2010.
- **ASHE is a sample survey**, not a census, so regional medians carry
  sampling error. ONS publishes coefficients of variation alongside each
  table (the `8.7b` files) which are not used here.
- **Price Paid excludes** some transaction types, including transfers that
  are not at full market value and most commercial property.

## Reproducing this

### 1. Set up

Install PostgreSQL and create the database:

    createdb housing

Clone this repo, then create and activate a virtual environment:

    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt

Copy `.env.example` to `.env` and fill in your database credentials.

### 2. Get the data

Both datasets are gitignored (too large for GitHub), so download them into `data/` yourself.

Price Paid (a single ~5 GB file):

    curl -o data/pp-complete.csv "https://price-paid-data.publicdata.landregistry.gov.uk/pp-complete.csv"

ASHE earnings: download the annual zips for 2002-2025 from the [ASHE Table 8 page](https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/datasets/placeofresidencebylocalauthorityashetable8). Take the revised edition for each year where available, and provisional for the latest year. Unzip each into `data/ashe/ashe_YYYY/`. Only the `Table 8.7a - Annual pay - Gross` file from each release is used. The ONS site rate-limits scripted downloads, so a browser is more reliable than curl for these.

### 3. Load the data

    ./ingest/load_raw.sh

This creates the staging table, bulk-loads Price Paid via `COPY`, and reports the row count (31,346,259).

## Findings

*To be added.*

## Licence and attribution

Contains HM Land Registry data © Crown copyright and database right 2026.
This data is licensed under the
[Open Government Licence v3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

Contains ONS data © Crown copyright, licensed under the
[Open Government Licence v3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

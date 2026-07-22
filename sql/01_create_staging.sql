-- Staging table for raw Price Paid data.
-- Every column is TEXT: a single malformed value would abort a 31M-row
-- typed load, so we load as text and cast types later in SQL.

DROP TABLE IF EXISTS raw_transactions;

CREATE TABLE raw_transactions (
    transaction_id  TEXT,
    price           TEXT,
    date_of_transfer TEXT,
    postcode        TEXT,
    property_type   TEXT,
    old_new         TEXT,
    duration        TEXT,
    paon            TEXT,
    saon            TEXT,
    street          TEXT,
    locality        TEXT,
    town_city       TEXT,
    district        TEXT,
    county          TEXT,
    ppd_category    TEXT,
    record_status   TEXT
);

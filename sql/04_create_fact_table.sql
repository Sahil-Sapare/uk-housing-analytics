DROP TABLE IF EXISTS transactions CASCADE;

CREATE TABLE transactions (
    transaction_id    TEXT,
    price             INTEGER,
    transfer_date     DATE,
    transfer_year     INTEGER,
    postcode          TEXT,
    property_type_id  INTEGER,
    region_id         INTEGER,
    is_new_build      BOOLEAN
);

INSERT INTO transactions
SELECT
    r.transaction_id,
    r.price::INTEGER,
    r.date_of_transfer::DATE,
    EXTRACT(YEAR FROM r.date_of_transfer::DATE)::INTEGER,
    r.postcode,
    pt.property_type_id,
    reg.region_id,
    (r.old_new = 'Y')
FROM raw_transactions r
LEFT JOIN dim_property_type pt ON r.property_type = pt.code
LEFT JOIN county_region_map m  ON r.county = m.county
LEFT JOIN dim_region reg       ON m.region_name = reg.name
WHERE r.ppd_category = 'A';

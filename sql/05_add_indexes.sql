-- transfer_year alone: composite below can't serve year-only queries
-- (year is not its leftmost column).
CREATE INDEX idx_transactions_year ON transactions (transfer_year);

-- (region_id, transfer_year): serves both region-only queries (via the
-- leftmost prefix) and combined region+year queries. A standalone
-- region_id index would therefore be redundant.
CREATE INDEX idx_transactions_region_year ON transactions (region_id, transfer_year);

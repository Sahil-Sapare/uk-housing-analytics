CREATE INDEX idx_transactions_year ON transactions (transfer_year);
CREATE INDEX idx_transactions_region ON transactions (region_id);
CREATE INDEX idx_transactions_region_year ON transactions (region_id, transfer_year);

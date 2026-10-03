USE streamiq;

CREATE INDEX idx_watch_profile_start
ON watch_history(profile_id,watch_start);

CREATE INDEX idx_watch_content
ON watch_history(content_id);

CREATE INDEX idx_payments_date_status
ON payments(payment_date,payment_status);

-- Verify with:
-- SHOW INDEX FROM watch_history;
-- SHOW INDEX FROM payments;

USE streamiq;

EXPLAIN
SELECT profile_id,watch_start,watch_duration_minutes
FROM watch_history
WHERE profile_id=1
ORDER BY watch_start;

-- Verified:
-- type = ref
-- possible_keys = idx_watch_profile_start
-- key = idx_watch_profile_start
-- key_len = 4
-- ref = const
-- rows = 5
-- filtered = 100.00
--
-- MySQL used the intended composite index.

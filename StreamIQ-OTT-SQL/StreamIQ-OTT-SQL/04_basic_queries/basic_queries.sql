-- ============================================================
-- StreamIQ - Basic SQL Queries
-- basic_queries.sql
-- ============================================================

USE streamiq;

-- 1. View all users
SELECT *
FROM users;

-- 2. Active users by country
SELECT
    country,
    COUNT(*) AS total_users
FROM users
WHERE status = 'ACTIVE'
GROUP BY country
ORDER BY total_users DESC;

-- 3. Content catalogue by type
SELECT
    content_type,
    COUNT(*) AS total_titles
FROM content
GROUP BY content_type
ORDER BY total_titles DESC;

-- 4. Movies longer than 120 minutes
SELECT
    title,
    duration_minutes,
    language
FROM content
WHERE content_type = 'MOVIE'
  AND duration_minutes > 120
ORDER BY duration_minutes DESC;

-- 5. Content released from 2025 onward
SELECT
    title,
    content_type,
    release_date
FROM content
WHERE release_date >= '2025-01-01'
ORDER BY release_date;

-- 6. Number of profiles per user
SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    COUNT(p.profile_id) AS profile_count
FROM users u
LEFT JOIN profiles p
    ON u.user_id = p.user_id
GROUP BY
    u.user_id,
    u.first_name,
    u.last_name
ORDER BY profile_count DESC;

-- 7. Average rating by content
SELECT
    c.title,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.rating_id) AS rating_count
FROM content c
LEFT JOIN ratings r
    ON c.content_id = r.content_id
GROUP BY
    c.content_id,
    c.title
ORDER BY avg_rating DESC;

-- 8. Total watch time by profile
SELECT
    p.profile_name,
    COALESCE(SUM(wh.watch_duration_minutes), 0) AS total_watch_minutes
FROM profiles p
LEFT JOIN watch_history wh
    ON p.profile_id = wh.profile_id
GROUP BY
    p.profile_id,
    p.profile_name
ORDER BY total_watch_minutes DESC;

-- 9. Watch sessions by content type
SELECT
    c.content_type,
    COUNT(wh.watch_id) AS total_watch_sessions,
    COALESCE(SUM(wh.watch_duration_minutes), 0) AS total_watch_minutes
FROM content c
LEFT JOIN watch_history wh
    ON c.content_id = wh.content_id
GROUP BY c.content_type
ORDER BY total_watch_minutes DESC;

-- 10. Subscription count by plan
SELECT
    sp.plan_name,
    COUNT(s.subscription_id) AS total_subscriptions
FROM subscription_plans sp
LEFT JOIN subscriptions s
    ON sp.plan_id = s.plan_id
GROUP BY
    sp.plan_id,
    sp.plan_name
ORDER BY total_subscriptions DESC;

-- 11. Successful revenue by payment method
SELECT
    payment_method,
    COUNT(*) AS successful_payments,
    SUM(amount) AS total_revenue
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 12. Cancelled subscriptions
SELECT
    s.subscription_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    sp.plan_name,
    s.start_date,
    s.end_date
FROM subscriptions s
JOIN users u
    ON s.user_id = u.user_id
JOIN subscription_plans sp
    ON s.plan_id = sp.plan_id
WHERE s.status = 'CANCELLED'
ORDER BY s.end_date;

-- 13. Genres assigned to each title
SELECT
    c.title,
    GROUP_CONCAT(g.genre_name ORDER BY g.genre_name SEPARATOR ', ') AS genres
FROM content c
JOIN content_genres cg
    ON c.content_id = cg.content_id
JOIN genres g
    ON cg.genre_id = g.genre_id
GROUP BY
    c.content_id,
    c.title
ORDER BY c.title;

-- 14. Series and episode counts
SELECT
    c.title,
    COUNT(e.episode_id) AS episode_count
FROM content c
LEFT JOIN episodes e
    ON c.content_id = e.content_id
WHERE c.content_type = 'SERIES'
GROUP BY
    c.content_id,
    c.title
ORDER BY episode_count DESC, c.title;

-- 15. Profiles with at least 3 watch sessions
SELECT
    p.profile_name,
    COUNT(wh.watch_id) AS watch_sessions
FROM profiles p
JOIN watch_history wh
    ON p.profile_id = wh.profile_id
GROUP BY
    p.profile_id,
    p.profile_name
HAVING COUNT(wh.watch_id) >= 3
ORDER BY watch_sessions DESC;

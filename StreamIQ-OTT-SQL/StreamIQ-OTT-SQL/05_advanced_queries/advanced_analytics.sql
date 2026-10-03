-- ============================================================
-- StreamIQ - Advanced Streaming Analytics
-- advanced_analytics.sql
-- ============================================================

USE streamiq;

-- ============================================================
-- 1. Content performance using separate watch/rating summaries
--    Prevents one-to-many join multiplication.
-- ============================================================

WITH watch_summary AS (
    SELECT
        content_id,
        COUNT(*) AS total_views,
        SUM(watch_duration_minutes) AS total_watch_minutes,
        ROUND(AVG(completion_percentage), 2) AS avg_completion
    FROM watch_history
    GROUP BY content_id
),
rating_summary AS (
    SELECT
        content_id,
        COUNT(*) AS rating_count,
        ROUND(AVG(rating), 2) AS avg_rating
    FROM ratings
    GROUP BY content_id
)
SELECT
    c.title,
    c.content_type,
    COALESCE(ws.total_views, 0) AS total_views,
    COALESCE(ws.total_watch_minutes, 0) AS total_watch_minutes,
    ws.avg_completion,
    rs.avg_rating,
    COALESCE(rs.rating_count, 0) AS rating_count
FROM content c
LEFT JOIN watch_summary ws
    ON c.content_id = ws.content_id
LEFT JOIN rating_summary rs
    ON c.content_id = rs.content_id
ORDER BY total_watch_minutes DESC;

-- ============================================================
-- 2. Engagement classification with CASE
-- ============================================================

WITH content_engagement AS (
    SELECT
        c.content_id,
        c.title,
        COUNT(wh.watch_id) AS total_views,
        ROUND(AVG(wh.completion_percentage), 2) AS avg_completion
    FROM content c
    LEFT JOIN watch_history wh
        ON c.content_id = wh.content_id
    GROUP BY c.content_id, c.title
)
SELECT
    title,
    total_views,
    avg_completion,
    CASE
        WHEN total_views = 0 THEN 'No Viewing Data'
        WHEN avg_completion >= 85 THEN 'Highly Engaging'
        WHEN avg_completion >= 70 THEN 'Engaging'
        ELSE 'Low Engagement'
    END AS engagement_category
FROM content_engagement
ORDER BY avg_completion DESC;

-- ============================================================
-- 3. Subscription cancellation rate
--    This is subscription cancellation, not customer churn.
-- ============================================================

SELECT
    COUNT(*) AS total_subscriptions,
    SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END)
        AS cancelled_subscriptions,
    ROUND(
        100.0 * SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS subscription_cancellation_rate
FROM subscriptions;

-- ============================================================
-- 4. Cancelled subscription duration
-- ============================================================

SELECT
    ROUND(
        AVG(DATEDIFF(end_date, start_date)),
        2
    ) AS avg_cancelled_subscription_days,
    MIN(DATEDIFF(end_date, start_date)) AS min_days,
    MAX(DATEDIFF(end_date, start_date)) AS max_days
FROM subscriptions
WHERE status = 'CANCELLED'
  AND end_date IS NOT NULL;

-- ============================================================
-- 5. Successful revenue by subscription plan
-- ============================================================

SELECT
    sp.plan_name,
    COUNT(p.payment_id) AS successful_payments,
    SUM(p.amount) AS total_revenue
FROM payments p
JOIN subscriptions s
    ON p.subscription_id = s.subscription_id
JOIN subscription_plans sp
    ON s.plan_id = sp.plan_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY
    sp.plan_id,
    sp.plan_name
ORDER BY total_revenue DESC;

-- ============================================================
-- 6. Monthly successful revenue
-- ============================================================

SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS revenue_month,
    SUM(amount) AS monthly_revenue
FROM payments
WHERE payment_status = 'SUCCESS'
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY revenue_month;

-- ============================================================
-- 7. Cumulative revenue using a window function
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS revenue_month,
        SUM(amount) AS monthly_revenue
    FROM payments
    WHERE payment_status = 'SUCCESS'
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY revenue_month
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY revenue_month;

-- ============================================================
-- 8. Profile watch-time ranking using a window function
-- ============================================================

WITH profile_watch AS (
    SELECT
        p.profile_id,
        p.profile_name,
        COALESCE(SUM(wh.watch_duration_minutes), 0) AS total_watch_minutes
    FROM profiles p
    LEFT JOIN watch_history wh
        ON p.profile_id = wh.profile_id
    GROUP BY
        p.profile_id,
        p.profile_name
)
SELECT
    profile_name,
    total_watch_minutes,
    DENSE_RANK() OVER (
        ORDER BY total_watch_minutes DESC
    ) AS watch_time_rank
FROM profile_watch
ORDER BY watch_time_rank, profile_name;

-- ============================================================
-- 9. Genre performance
--    Watch and rating facts are aggregated separately to avoid
--    multiplying rows across multiple one-to-many relationships.
-- ============================================================

WITH genre_watch AS (
    SELECT
        cg.genre_id,
        COUNT(wh.watch_id) AS total_views,
        ROUND(AVG(wh.completion_percentage), 2) AS avg_completion
    FROM content_genres cg
    JOIN watch_history wh
        ON cg.content_id = wh.content_id
    GROUP BY cg.genre_id
),
genre_rating AS (
    SELECT
        cg.genre_id,
        ROUND(AVG(r.rating), 2) AS avg_rating
    FROM content_genres cg
    JOIN ratings r
        ON cg.content_id = r.content_id
    GROUP BY cg.genre_id
)
SELECT
    g.genre_name,
    COALESCE(gw.total_views, 0) AS total_views,
    gw.avg_completion,
    gr.avg_rating
FROM genres g
LEFT JOIN genre_watch gw
    ON g.genre_id = gw.genre_id
LEFT JOIN genre_rating gr
    ON g.genre_id = gr.genre_id
ORDER BY gw.total_views DESC;

-- ============================================================
-- 10. Device usage for explicitly tracked sessions
--     Historical sessions with NULL device_id are preserved.
-- ============================================================

SELECT
    d.device_type,
    COUNT(wh.watch_id) AS tracked_sessions,
    SUM(wh.watch_duration_minutes) AS total_watch_minutes,
    ROUND(AVG(wh.watch_duration_minutes), 2) AS avg_session_minutes
FROM watch_history wh
JOIN devices d
    ON wh.device_id = d.device_id
GROUP BY d.device_type
ORDER BY total_watch_minutes DESC;

-- ============================================================
-- 11. Device type + operating system
-- ============================================================

SELECT
    d.device_type,
    d.operating_system,
    COUNT(wh.watch_id) AS tracked_sessions,
    SUM(wh.watch_duration_minutes) AS total_watch_minutes,
    ROUND(AVG(wh.watch_duration_minutes), 2) AS avg_session_minutes
FROM watch_history wh
JOIN devices d
    ON wh.device_id = d.device_id
GROUP BY
    d.device_type,
    d.operating_system
ORDER BY total_watch_minutes DESC;

-- ============================================================
-- 12. Episode viewing activity
-- ============================================================

SELECT
    c.title,
    COUNT(DISTINCT wh.episode_id) AS distinct_episodes_watched,
    COUNT(wh.watch_id) AS episode_watch_sessions,
    SUM(wh.watch_duration_minutes) AS total_episode_watch_minutes
FROM watch_history wh
JOIN content c
    ON wh.content_id = c.content_id
WHERE wh.episode_id IS NOT NULL
GROUP BY
    c.content_id,
    c.title
ORDER BY distinct_episodes_watched DESC;

-- ============================================================
-- 13. Profiles with multiple distinct episodes from the same
--     series within a 24-hour window.
-- ============================================================

SELECT
    wh1.profile_id,
    wh1.content_id,
    DATE(wh1.watch_start) AS watch_date,
    COUNT(DISTINCT wh2.episode_id) AS distinct_episodes_within_24h
FROM watch_history wh1
JOIN watch_history wh2
    ON wh1.profile_id = wh2.profile_id
   AND wh1.content_id = wh2.content_id
   AND wh2.episode_id IS NOT NULL
   AND wh2.watch_start >= wh1.watch_start
   AND wh2.watch_start < DATE_ADD(wh1.watch_start, INTERVAL 24 HOUR)
WHERE wh1.episode_id IS NOT NULL
GROUP BY
    wh1.profile_id,
    wh1.content_id,
    DATE(wh1.watch_start)
HAVING COUNT(DISTINCT wh2.episode_id) >= 2
ORDER BY distinct_episodes_within_24h DESC;

-- ============================================================
-- 14. Strict binge-watch detection:
--     3+ distinct episodes of the same series within 24 hours.
-- ============================================================

SELECT
    wh1.profile_id,
    wh1.content_id,
    DATE(wh1.watch_start) AS watch_date,
    COUNT(DISTINCT wh2.episode_id) AS distinct_episodes_within_24h
FROM watch_history wh1
JOIN watch_history wh2
    ON wh1.profile_id = wh2.profile_id
   AND wh1.content_id = wh2.content_id
   AND wh2.episode_id IS NOT NULL
   AND wh2.watch_start >= wh1.watch_start
   AND wh2.watch_start < DATE_ADD(wh1.watch_start, INTERVAL 24 HOUR)
WHERE wh1.episode_id IS NOT NULL
GROUP BY
    wh1.profile_id,
    wh1.content_id,
    DATE(wh1.watch_start)
HAVING COUNT(DISTINCT wh2.episode_id) >= 3
ORDER BY distinct_episodes_within_24h DESC;

-- ============================================================
-- 15. Data integrity: orphan watch-history profiles
-- ============================================================

SELECT COUNT(*) AS invalid_watch_profiles
FROM watch_history wh
LEFT JOIN profiles p
    ON wh.profile_id = p.profile_id
WHERE p.profile_id IS NULL;

-- ============================================================
-- 16. Data integrity: episode/content consistency
-- ============================================================

SELECT
    wh.watch_id,
    wh.content_id,
    wh.episode_id,
    e.content_id AS episode_content_id
FROM watch_history wh
JOIN episodes e
    ON wh.episode_id = e.episode_id
WHERE wh.episode_id IS NOT NULL
  AND wh.content_id <> e.content_id;

-- ============================================================
-- 17. Payment integrity validation
-- ============================================================

SELECT COUNT(*) AS invalid_payments
FROM payments
WHERE amount <= 0
   OR payment_status NOT IN ('SUCCESS', 'FAILED')
   OR subscription_id NOT IN (
       SELECT subscription_id
       FROM subscriptions
   );

-- ============================================================
-- 18. Overall StreamIQ KPI snapshot
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM profiles) AS total_profiles,
    (SELECT COUNT(*) FROM content) AS total_content,
    (SELECT COUNT(*) FROM watch_history) AS total_watch_sessions,
    (SELECT COALESCE(SUM(watch_duration_minutes), 0)
     FROM watch_history) AS total_watch_minutes,
    (SELECT ROUND(AVG(completion_percentage), 2)
     FROM watch_history) AS overall_avg_completion,
    (SELECT COUNT(*) FROM subscriptions) AS total_subscriptions,
    (SELECT COUNT(*) FROM subscriptions
     WHERE status = 'ACTIVE') AS active_subscriptions,
    (SELECT COUNT(*) FROM subscriptions
     WHERE status = 'CANCELLED') AS cancelled_subscriptions,
    (SELECT COALESCE(SUM(amount), 0)
     FROM payments
     WHERE payment_status = 'SUCCESS') AS total_revenue;

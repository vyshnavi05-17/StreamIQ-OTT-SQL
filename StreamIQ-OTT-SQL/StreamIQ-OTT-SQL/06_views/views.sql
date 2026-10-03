USE streamiq;

CREATE OR REPLACE VIEW vw_content_performance AS
WITH watch_summary AS (
    SELECT content_id, COUNT(*) AS total_views,
           SUM(watch_duration_minutes) AS total_watch_minutes,
           ROUND(AVG(completion_percentage),2) AS avg_completion
    FROM watch_history GROUP BY content_id
),
rating_summary AS (
    SELECT content_id, COUNT(*) AS rating_count,
           ROUND(AVG(rating),2) AS avg_rating
    FROM ratings GROUP BY content_id
)
SELECT c.content_id, c.title, c.content_type,
       COALESCE(ws.total_views,0) AS total_views,
       COALESCE(ws.total_watch_minutes,0) AS total_watch_minutes,
       ws.avg_completion, rs.avg_rating,
       COALESCE(rs.rating_count,0) AS rating_count
FROM content c
LEFT JOIN watch_summary ws ON c.content_id=ws.content_id
LEFT JOIN rating_summary rs ON c.content_id=rs.content_id;

CREATE OR REPLACE VIEW vw_profile_engagement AS
SELECT p.profile_id, p.profile_name,
       COUNT(wh.watch_id) AS total_watch_sessions,
       COALESCE(SUM(wh.watch_duration_minutes),0) AS total_watch_minutes,
       ROUND(COALESCE(AVG(wh.watch_duration_minutes),0),2) AS avg_session_minutes,
       ROUND(COALESCE(AVG(wh.completion_percentage),0),2) AS avg_completion_percentage,
       COUNT(DISTINCT wh.content_id) AS unique_contents_watched
FROM profiles p
LEFT JOIN watch_history wh ON p.profile_id=wh.profile_id
GROUP BY p.profile_id,p.profile_name;

CREATE OR REPLACE VIEW vw_subscription_revenue AS
SELECT s.subscription_id,u.user_id,
       CONCAT(u.first_name,' ',u.last_name) AS user_name,
       sp.plan_name,sp.billing_cycle,sp.price AS plan_price,
       s.start_date,s.end_date,s.status AS subscription_status,
       COUNT(CASE WHEN p.payment_status='SUCCESS' THEN p.payment_id END) AS successful_payments,
       COALESCE(SUM(CASE WHEN p.payment_status='SUCCESS' THEN p.amount ELSE 0 END),0) AS total_revenue
FROM subscriptions s
JOIN users u ON s.user_id=u.user_id
JOIN subscription_plans sp ON s.plan_id=sp.plan_id
LEFT JOIN payments p ON s.subscription_id=p.subscription_id
GROUP BY s.subscription_id,u.user_id,u.first_name,u.last_name,
         sp.plan_name,sp.billing_cycle,sp.price,s.start_date,s.end_date,s.status;

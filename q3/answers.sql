\set ON_ERROR_STOP on
BEGIN;

\echo
\echo '== 1. Insert a new subscriber: Fajar, Basic plan, activated 24 January 2024 =='
INSERT INTO subscribers (id, name, plan, activation_date)
VALUES ('SUB07', 'Fajar', 'Basic', DATE '2024-01-24')
RETURNING *;

\echo '== 2. Update Fajar''s plan to Premium =='
UPDATE subscribers
SET plan = 'Premium'
WHERE id = 'SUB07'
RETURNING *;

\echo '== 3. Total data usage across all snapshots for Premium-plan subscribers =='
SELECT COALESCE(SUM(u.data_usage_mb), 0.00) AS total_premium_data_mb
FROM subscribers AS s
JOIN usage AS u ON u.subscriber_id = s.id
WHERE s.plan = 'Premium';

\echo '   Breakdown per Premium subscriber (LEFT JOIN keeps Fajar, who has no usage yet)'
SELECT s.id,
       s.name,
       COALESCE(SUM(u.data_usage_mb), 0.00) AS total_data_mb
FROM subscribers AS s
LEFT JOIN usage AS u ON u.subscriber_id = s.id
WHERE s.plan = 'Premium'
GROUP BY s.id, s.name
ORDER BY total_data_mb DESC, s.id;

\echo '== 4. Top 3 subscribers by total data usage across all snapshots =='
SELECT s.id,
       s.name,
       s.plan,
       SUM(u.data_usage_mb) AS total_data_mb
FROM subscribers AS s
JOIN usage AS u ON u.subscriber_id = s.id
GROUP BY s.id, s.name, s.plan
ORDER BY total_data_mb DESC, s.id
LIMIT 3;

\echo '== 5. Subscribers whose average call minutes per snapshot is <= 30 (subquery) =='
SELECT s.id,
       s.name,
       ROUND(a.avg_call_minutes, 2) AS avg_call_minutes
FROM subscribers AS s
JOIN (
    SELECT subscriber_id,
           AVG(call_minutes) AS avg_call_minutes
    FROM usage
    GROUP BY subscriber_id
) AS a ON a.subscriber_id = s.id
WHERE a.avg_call_minutes <= 30
ORDER BY a.avg_call_minutes, s.id;

ROLLBACK;
\echo 'Rolled back: the database is back to the seeded state.'
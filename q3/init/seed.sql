INSERT INTO subscribers (id, name, plan, activation_date) VALUES
    ('SUB01', 'Amir', 'Basic',   DATE '2023-01-12'),
    ('SUB02', 'Sari', 'Premium', DATE '2022-05-03'),
    ('SUB03', 'Budi', 'Basic',   DATE '2024-09-20'),
    ('SUB04', 'Dewi', 'Family',  DATE '2021-02-15'),
    ('SUB05', 'Rian', 'Premium', DATE '2023-08-08'),
    ('SUB06', 'Nia',  'Basic',   DATE '2024-11-30');

INSERT INTO usage (subscriber_id, call_minutes, sms_count, data_usage_mb, recorded_at) VALUES
    ('SUB01',  40, 10, 1500, '2025-08-01 08:00+07'),
    ('SUB01',  35,  8, 1200, '2025-08-01 12:00+07'),
    ('SUB02',  90, 20, 6000, '2025-08-01 08:00+07'),
    ('SUB02',  85, 18, 5800, '2025-08-01 12:00+07'),
    ('SUB03',  20,  5,  500, '2025-08-01 08:00+07'),
    ('SUB04', 150, 30, 9000, '2025-08-01 08:00+07'),
    ('SUB05',  70, 15, 5000, '2025-08-01 08:00+07'),
    ('SUB06',  25,  6,  700, '2025-08-01 08:00+07');
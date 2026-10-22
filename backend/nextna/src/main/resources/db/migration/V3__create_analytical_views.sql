CREATE OR REPLACE VIEW view_predictive_duration_stats AS
SELECT 
    service_id,
    service_name,
    day_of_week,
    hour_of_day,
    COUNT(*) AS total_samples,
    ROUND(AVG(actual_duration_minutes)) AS average_duration_minutes,
    MIN(actual_duration_minutes) AS min_duration_minutes,
    MAX(actual_duration_minutes) AS max_duration_minutes
FROM service_telemetry_logs
GROUP BY service_id, service_name, day_of_week, hour_of_day;

CREATE OR REPLACE VIEW view_daily_financial_summary AS
SELECT 
    DATE(time_fulfilled) AS report_date,
    COUNT(*) AS total_services_completed,
    SUM(service_price) AS total_revenue_php,
    ROUND(AVG(actual_duration_minutes), 1) AS average_service_duration_minutes,
    ROUND(SUM(service_price) / NULLIF(SUM(actual_duration_minutes), 0), 2) AS revenue_per_minute_php
FROM service_telemetry_logs
GROUP BY DATE(time_fulfilled);

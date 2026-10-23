ALTER TABLE services ALTER COLUMN is_active SET DEFAULT TRUE;
ALTER TABLE services ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE services ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

INSERT INTO services (id, name, category, unit_price, baseline_duration_minutes, is_active, created_at, updated_at) VALUES
('srv-001', 'Standard Haircut & Wash', 'BARBERSHOP', 200.00, 20, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('srv-002', 'Haircut & Beard Sculpting', 'BARBERSHOP', 280.00, 30, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('srv-003', 'Deep Scalp / Hair Treatment', 'BARBERSHOP', 450.00, 45, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('srv-004', 'General Dental Consultation', 'CLINIC', 500.00, 30, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('srv-005', 'Quick Order / Meal Prep', 'FOOD_ORDER', 160.00, 15, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

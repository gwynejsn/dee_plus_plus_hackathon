INSERT INTO services (id, name, category, unit_price, baseline_duration_minutes) VALUES
('srv-001', 'Standard Haircut & Wash', 'BARBERSHOP', 200.00, 20),
('srv-002', 'Haircut & Beard Sculpting', 'BARBERSHOP', 280.00, 30),
('srv-003', 'Deep Scalp / Hair Treatment', 'BARBERSHOP', 450.00, 45),
('srv-004', 'General Dental Consultation', 'CLINIC', 500.00, 30),
('srv-005', 'Quick Order / Meal Prep', 'FOOD_ORDER', 160.00, 15)
ON CONFLICT (id) DO NOTHING;

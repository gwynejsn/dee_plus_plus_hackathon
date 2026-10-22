CREATE TABLE IF NOT EXISTS services (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) DEFAULT 'GENERAL',
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    baseline_duration_minutes INT NOT NULL CHECK (baseline_duration_minutes > 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS queue_tickets (
    id VARCHAR(36) PRIMARY KEY,
    ticket_number INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    service_id VARCHAR(36) NOT NULL REFERENCES services(id),
    service_price DECIMAL(10, 2) NOT NULL,
    state VARCHAR(20) NOT NULL DEFAULT 'WAITING',
    estimated_wait_minutes INT NOT NULL,
    is_manual_override BOOLEAN DEFAULT FALSE,
    on_my_way_confirmed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    called_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT chk_ticket_state CHECK (state IN ('WAITING', 'ALMOST_NEXT', 'NOW_SERVING', 'COMPLETED', 'CANCELLED'))
);

CREATE TABLE IF NOT EXISTS service_telemetry_logs (
    id VARCHAR(36) PRIMARY KEY,
    ticket_id VARCHAR(36) NOT NULL,
    ticket_number INT NOT NULL,
    customer_name VARCHAR(100),
    service_id VARCHAR(36) NOT NULL REFERENCES services(id),
    service_name VARCHAR(100) NOT NULL,
    service_price DECIMAL(10, 2) NOT NULL,
    time_intake TIMESTAMP WITH TIME ZONE NOT NULL,
    time_commenced TIMESTAMP WITH TIME ZONE NOT NULL,
    time_fulfilled TIMESTAMP WITH TIME ZONE NOT NULL,
    actual_duration_minutes INT NOT NULL CHECK (actual_duration_minutes >= 0),
    estimated_duration_minutes INT NOT NULL,
    duration_variance_minutes INT NOT NULL,
    day_of_week INT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    hour_of_day INT NOT NULL CHECK (hour_of_day BETWEEN 0 AND 23),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tickets_state ON queue_tickets(state);
CREATE INDEX IF NOT EXISTS idx_tickets_number ON queue_tickets(ticket_number);
CREATE INDEX IF NOT EXISTS idx_telemetry_service ON service_telemetry_logs(service_id);
CREATE INDEX IF NOT EXISTS idx_telemetry_day_hour ON service_telemetry_logs(day_of_week, hour_of_day);
CREATE INDEX IF NOT EXISTS idx_telemetry_fulfilled ON service_telemetry_logs(time_fulfilled);

CREATE TABLE IF NOT EXISTS event_publication (
  id UUID NOT NULL,
  listener_id VARCHAR(512) NOT NULL,
  event_type VARCHAR(512) NOT NULL,
  serialized_event TEXT NOT NULL,
  publication_date TIMESTAMP WITH TIME ZONE NOT NULL,
  completion_date TIMESTAMP WITH TIME ZONE,
  PRIMARY KEY (id)
);

package com.deeplusplus.nextna.analytics.domain;

public class TelemetryNotFoundException extends RuntimeException {
    public TelemetryNotFoundException(String message) {
        super(message);
    }

    public static TelemetryNotFoundException of(String id) {
        return new TelemetryNotFoundException("Telemetry log with id '" + id + "' was not found");
    }
}

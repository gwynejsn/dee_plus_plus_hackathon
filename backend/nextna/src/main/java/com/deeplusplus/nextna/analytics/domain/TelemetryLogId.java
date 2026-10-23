package com.deeplusplus.nextna.analytics.domain;

import java.util.Objects;
import java.util.UUID;

public record TelemetryLogId(String value) {

    public TelemetryLogId {
        Objects.requireNonNull(value, "Telemetry log id cannot be null");
        if (value.isBlank()) {
            throw new IllegalArgumentException("Telemetry log id cannot be blank");
        }
    }

    public static TelemetryLogId of(String value) {
        return new TelemetryLogId(value);
    }

    public static TelemetryLogId generate() {
        return new TelemetryLogId("tel-" + UUID.randomUUID().toString().substring(0, 8));
    }
}

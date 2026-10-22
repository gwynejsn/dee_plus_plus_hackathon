package com.deeplusplus.NextNa.servicecatalog.domain;

import java.util.Objects;
import java.util.UUID;

public record ServiceId(String value) {
    public ServiceId {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("ServiceId cannot be null or blank");
        }
    }

    public static ServiceId generate() {
        return new ServiceId("srv-" + UUID.randomUUID().toString().substring(0, 8));
    }

    public static ServiceId of(String value) {
        return new ServiceId(value);
    }
}

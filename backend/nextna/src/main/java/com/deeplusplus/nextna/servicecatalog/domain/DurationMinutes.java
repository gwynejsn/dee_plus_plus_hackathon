package com.deeplusplus.nextna.servicecatalog.domain;

public record DurationMinutes(int minutes) {
    public DurationMinutes {
        if (minutes <= 0) {
            throw new InvalidDurationException("Service duration must be greater than zero: " + minutes);
        }
        if (minutes > 480) {
            throw new InvalidDurationException("Service duration exceeds maximum limit of 480 minutes: " + minutes);
        }
    }

    public static DurationMinutes of(int minutes) {
        return new DurationMinutes(minutes);
    }
}

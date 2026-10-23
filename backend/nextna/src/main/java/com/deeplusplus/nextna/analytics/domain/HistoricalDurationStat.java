package com.deeplusplus.nextna.analytics.domain;

public record HistoricalDurationStat(
        String serviceId,
        String serviceName,
        int dayOfWeek,
        int hourOfDay,
        long totalSamples,
        int averageDurationMinutes,
        int minDurationMinutes,
        int maxDurationMinutes
) {}

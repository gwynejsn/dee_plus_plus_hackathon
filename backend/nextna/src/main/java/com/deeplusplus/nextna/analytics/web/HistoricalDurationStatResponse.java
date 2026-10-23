package com.deeplusplus.nextna.analytics.web;

import com.deeplusplus.nextna.analytics.domain.HistoricalDurationStat;

public record HistoricalDurationStatResponse(
        String serviceId,
        String serviceName,
        int dayOfWeek,
        int hourOfDay,
        long totalSamples,
        int averageDurationMinutes,
        int minDurationMinutes,
        int maxDurationMinutes
) {
    public static HistoricalDurationStatResponse from(HistoricalDurationStat domain) {
        return new HistoricalDurationStatResponse(
                domain.serviceId(),
                domain.serviceName(),
                domain.dayOfWeek(),
                domain.hourOfDay(),
                domain.totalSamples(),
                domain.averageDurationMinutes(),
                domain.minDurationMinutes(),
                domain.maxDurationMinutes()
        );
    }
}

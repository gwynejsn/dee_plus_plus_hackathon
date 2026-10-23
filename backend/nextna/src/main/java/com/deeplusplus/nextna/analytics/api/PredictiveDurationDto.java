package com.deeplusplus.nextna.analytics.api;

public record PredictiveDurationDto(
        String serviceId,
        int suggestedDurationMinutes,
        double confidenceScore,
        String summaryInsight
) {}

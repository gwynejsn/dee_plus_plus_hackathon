package com.deeplusplus.nextna.analytics.infrastructure;

public record AiPredictionResponse(
        int predictedDurationMinutes,
        double confidenceScore,
        double varianceFactor,
        String summaryInsight,
        String operationalAdvice,
        String bottleneckRisk
) {}

package com.deeplusplus.nextna.analytics.domain;

import java.time.Instant;

public record AiPredictionRecommendation(
        int predictedDurationMinutes,
        double confidenceScore,
        double varianceFactor,
        String summaryInsight,
        String operationalAdvice,
        String bottleneckRisk,
        Instant evaluatedAt
) {}

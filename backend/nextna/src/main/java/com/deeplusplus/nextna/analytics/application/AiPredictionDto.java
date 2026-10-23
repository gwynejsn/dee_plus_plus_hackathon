package com.deeplusplus.nextna.analytics.application;

import com.deeplusplus.nextna.analytics.domain.AiPredictionRecommendation;

import java.time.Instant;

public record AiPredictionDto(
        String serviceId,
        String serviceName,
        int predictedDurationMinutes,
        double confidenceScore,
        double varianceFactor,
        String summaryInsight,
        String operationalAdvice,
        String bottleneckRisk,
        Instant evaluatedAt
) {
    public static AiPredictionDto from(String serviceId, String serviceName, AiPredictionRecommendation domain) {
        return new AiPredictionDto(
                serviceId,
                serviceName,
                domain.predictedDurationMinutes(),
                domain.confidenceScore(),
                domain.varianceFactor(),
                domain.summaryInsight(),
                domain.operationalAdvice(),
                domain.bottleneckRisk(),
                domain.evaluatedAt()
        );
    }
}

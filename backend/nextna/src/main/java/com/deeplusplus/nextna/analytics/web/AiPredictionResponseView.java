package com.deeplusplus.nextna.analytics.web;

import com.deeplusplus.nextna.analytics.application.AiPredictionDto;

import java.time.Instant;

public record AiPredictionResponseView(
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
    public static AiPredictionResponseView from(AiPredictionDto dto) {
        return new AiPredictionResponseView(
                dto.serviceId(),
                dto.serviceName(),
                dto.predictedDurationMinutes(),
                dto.confidenceScore(),
                dto.varianceFactor(),
                dto.summaryInsight(),
                dto.operationalAdvice(),
                dto.bottleneckRisk(),
                dto.evaluatedAt()
        );
    }
}

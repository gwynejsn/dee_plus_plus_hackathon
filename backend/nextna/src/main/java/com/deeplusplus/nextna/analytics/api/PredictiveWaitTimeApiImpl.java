package com.deeplusplus.nextna.analytics.api;

import com.deeplusplus.nextna.analytics.application.AiPredictionDto;
import com.deeplusplus.nextna.analytics.application.AnalyticsService;
import org.springframework.stereotype.Component;

@Component
public class PredictiveWaitTimeApiImpl implements PredictiveWaitTimeApi {

    private final AnalyticsService analyticsService;

    public PredictiveWaitTimeApiImpl(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @Override
    public PredictiveDurationDto getSuggestedDuration(String serviceId, int dayOfWeek, int hourOfDay) {
        AiPredictionDto prediction = analyticsService.getAiPrediction(serviceId, dayOfWeek, hourOfDay);
        return new PredictiveDurationDto(
                prediction.serviceId(),
                prediction.predictedDurationMinutes(),
                prediction.confidenceScore(),
                prediction.summaryInsight()
        );
    }
}

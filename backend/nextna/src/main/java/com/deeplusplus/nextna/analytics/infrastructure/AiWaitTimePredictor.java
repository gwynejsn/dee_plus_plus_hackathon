package com.deeplusplus.nextna.analytics.infrastructure;

import com.deeplusplus.nextna.analytics.domain.AiPredictionRecommendation;
import dev.langchain4j.model.chat.request.ResponseFormat;
import dev.langchain4j.model.googleai.GoogleAiGeminiChatModel;
import dev.langchain4j.service.AiServices;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class AiWaitTimePredictor {

    private static final Logger log = LoggerFactory.getLogger(AiWaitTimePredictor.class);

    private final GeminiWaitTimeAdvisorClient advisorClient;

    public AiWaitTimePredictor(@Value("${gemini.api-key:${GEMINI_API_KEY:}}") String apiKey) {
        GeminiWaitTimeAdvisorClient client = null;
        if (apiKey != null && !apiKey.isBlank()) {
            try {
                GoogleAiGeminiChatModel model = GoogleAiGeminiChatModel.builder()
                        .apiKey(apiKey.trim())
                        .modelName("gemini-1.5-flash")
                        .temperature(0.2)
                        .responseFormat(ResponseFormat.JSON)
                        .build();

                client = AiServices.create(GeminiWaitTimeAdvisorClient.class, model);
            } catch (Exception ex) {
                log.warn("Failed to initialize Gemini AI client, falling back to statistical estimation: {}", ex.getMessage());
            }
        }
        this.advisorClient = client;
    }

    public AiPredictionRecommendation predict(
            String serviceName,
            int baselineMinutes,
            int dayOfWeek,
            int hourOfDay,
            int waitingCount,
            int historicalAvgMinutes,
            long totalSamples,
            int minMinutes,
            int maxMinutes
    ) {
        if (advisorClient != null) {
            try {
                AiPredictionResponse response = advisorClient.evaluate(
                        serviceName,
                        baselineMinutes,
                        dayOfWeek,
                        hourOfDay,
                        waitingCount,
                        historicalAvgMinutes,
                        totalSamples,
                        minMinutes,
                        maxMinutes
                );

                if (response != null && response.predictedDurationMinutes() > 0) {
                    return new AiPredictionRecommendation(
                            response.predictedDurationMinutes(),
                            response.confidenceScore(),
                            response.varianceFactor(),
                            response.summaryInsight(),
                            response.operationalAdvice(),
                            response.bottleneckRisk(),
                            Instant.now()
                    );
                }
            } catch (Exception ex) {
                log.warn("Gemini evaluation encountered an error, falling back to statistical predictor: {}", ex.getMessage());
            }
        }

        return fallbackStatisticalPrediction(
                serviceName,
                baselineMinutes,
                dayOfWeek,
                hourOfDay,
                waitingCount,
                historicalAvgMinutes,
                totalSamples
        );
    }

    private AiPredictionRecommendation fallbackStatisticalPrediction(
            String serviceName,
            int baselineMinutes,
            int dayOfWeek,
            int hourOfDay,
            int waitingCount,
            int historicalAvgMinutes,
            long totalSamples
    ) {
        int predicted;
        if (totalSamples > 0 && historicalAvgMinutes > 0) {
            predicted = (int) Math.round((baselineMinutes * 0.35) + (historicalAvgMinutes * 0.65));
        } else {
            predicted = baselineMinutes;
        }

        double varianceFactor = (double) predicted / Math.max(1, baselineMinutes);
        String bottleneckRisk = varianceFactor >= 1.25 ? "HIGH" : (varianceFactor >= 1.1 ? "MEDIUM" : "LOW");
        double confidence = Math.min(0.95, 0.40 + (totalSamples * 0.05));

        String insight = String.format(
                "Estimated %d minutes for %s at slot (day %d, %02d:00) with %d samples on record.",
                predicted, serviceName, dayOfWeek, hourOfDay, totalSamples
        );

        String advice = varianceFactor >= 1.15
                ? "Historical variance exceeds baseline. Allocate additional buffer time for walk-in arrivals."
                : "Operational velocity is steady and aligned with baseline schedule.";

        return new AiPredictionRecommendation(
                predicted,
                confidence,
                varianceFactor,
                insight,
                advice,
                bottleneckRisk,
                Instant.now()
        );
    }
}

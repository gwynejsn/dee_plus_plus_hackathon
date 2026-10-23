package com.deeplusplus.nextna.analytics.infrastructure;

import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import dev.langchain4j.service.V;

public interface GeminiWaitTimeAdvisorClient {

    @SystemMessage("You are an operations intelligence assistant for an MSME queue system. Evaluate queue telemetry and return concise operational recommendations.")
    @UserMessage("""
            Service: {{serviceName}}
            Baseline duration: {{baselineMinutes}} minutes
            Current day of week: {{dayOfWeek}} (1=Mon, 7=Sun)
            Current hour: {{hourOfDay}}:00
            Patrons waiting ahead: {{waitingCount}}
            Historical average duration for this slot: {{historicalAvgMinutes}} minutes
            Historical sample count: {{totalSamples}}
            Min observed: {{minMinutes}} minutes, Max observed: {{maxMinutes}} minutes
            
            Analyze the historical variance and current queue backlog.
            Predict realistic service duration in minutes, compute confidence score (0.0 to 1.0), variance factor (predicted / baseline), concise summary insight, practical operational advice for the MSME business owner, and bottleneck risk (LOW, MEDIUM, HIGH).
            """)
    AiPredictionResponse evaluate(
            @V("serviceName") String serviceName,
            @V("baselineMinutes") int baselineMinutes,
            @V("dayOfWeek") int dayOfWeek,
            @V("hourOfDay") int hourOfDay,
            @V("waitingCount") int waitingCount,
            @V("historicalAvgMinutes") int historicalAvgMinutes,
            @V("totalSamples") long totalSamples,
            @V("minMinutes") int minMinutes,
            @V("maxMinutes") int maxMinutes
    );
}

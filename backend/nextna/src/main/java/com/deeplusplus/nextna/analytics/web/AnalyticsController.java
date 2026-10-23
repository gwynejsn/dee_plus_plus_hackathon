package com.deeplusplus.nextna.analytics.web;

import com.deeplusplus.nextna.analytics.application.AnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "3. Analytics & AI Advisor", description = "Endpoints for financial telemetry, daily revenue summaries, and Gemini AI predictions")
@RestController
@RequestMapping("/api/v1/analytics")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    public AnalyticsController(AnalyticsService analyticsService) {
        this.analyticsService = analyticsService;
    }

    @Operation(summary = "Get daily operations dashboard overview and real-time KPIs")
    @GetMapping("/overview")
    public DashboardOverviewResponse getDashboardOverview() {
        return DashboardOverviewResponse.from(analyticsService.getDashboardOverview());
    }

    @Operation(summary = "Get daily financial summaries within date range")
    @GetMapping("/financial-summary")
    public List<DailyFinancialSummaryResponse> getFinancialSummary(
            @RequestParam(name = "from", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(name = "to", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to
    ) {
        return analyticsService.getFinancialSummaries(from, to).stream()
                .map(DailyFinancialSummaryResponse::from)
                .toList();
    }

    @Operation(summary = "Get historical duration telemetry stats by service ID")
    @GetMapping("/predictive-stats/{serviceId}")
    public List<HistoricalDurationStatResponse> getPredictiveStats(@PathVariable String serviceId) {
        return analyticsService.getHistoricalStats(serviceId).stream()
                .map(HistoricalDurationStatResponse::from)
                .toList();
    }

    @Operation(summary = "Get AI predicted wait time and advice via Gemini AI")
    @GetMapping("/ai-prediction")
    public AiPredictionResponseView getAiPrediction(
            @RequestParam(name = "serviceId") String serviceId,
            @RequestParam(name = "dayOfWeek", required = false) Integer dayOfWeek,
            @RequestParam(name = "hourOfDay", required = false) Integer hourOfDay
    ) {
        return AiPredictionResponseView.from(analyticsService.getAiPrediction(serviceId, dayOfWeek, hourOfDay));
    }
}

package com.deeplusplus.nextna.analytics.web;

import com.deeplusplus.nextna.analytics.application.DashboardOverviewDto;

import java.math.BigDecimal;
import java.util.List;

public record DashboardOverviewResponse(
        long totalCompletedToday,
        BigDecimal todayRevenuePhp,
        double averageDurationMinutesToday,
        int activeQueueCount,
        List<DailyFinancialSummaryResponse> recentFinancials,
        List<TelemetryLogResponse> recentLogs
) {
    public static DashboardOverviewResponse from(DashboardOverviewDto dto) {
        return new DashboardOverviewResponse(
                dto.totalCompletedToday(),
                dto.todayRevenuePhp(),
                dto.averageDurationMinutesToday(),
                dto.activeQueueCount(),
                dto.recentFinancials().stream().map(DailyFinancialSummaryResponse::from).toList(),
                dto.recentLogs().stream().map(TelemetryLogResponse::from).toList()
        );
    }
}

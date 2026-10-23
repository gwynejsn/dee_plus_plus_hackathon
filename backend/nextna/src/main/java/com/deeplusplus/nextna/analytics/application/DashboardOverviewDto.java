package com.deeplusplus.nextna.analytics.application;

import com.deeplusplus.nextna.analytics.domain.DailyFinancialSummary;

import java.math.BigDecimal;
import java.util.List;

public record DashboardOverviewDto(
        long totalCompletedToday,
        BigDecimal todayRevenuePhp,
        double averageDurationMinutesToday,
        int activeQueueCount,
        List<DailyFinancialSummary> recentFinancials,
        List<TelemetryLogDto> recentLogs
) {}

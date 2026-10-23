package com.deeplusplus.nextna.analytics.web;

import com.deeplusplus.nextna.analytics.domain.DailyFinancialSummary;

import java.math.BigDecimal;
import java.time.LocalDate;

public record DailyFinancialSummaryResponse(
        LocalDate reportDate,
        long totalServicesCompleted,
        BigDecimal totalRevenuePhp,
        double averageServiceDurationMinutes,
        BigDecimal revenuePerMinutePhp
) {
    public static DailyFinancialSummaryResponse from(DailyFinancialSummary domain) {
        return new DailyFinancialSummaryResponse(
                domain.reportDate(),
                domain.totalServicesCompleted(),
                domain.totalRevenuePhp(),
                domain.averageServiceDurationMinutes(),
                domain.revenuePerMinutePhp()
        );
    }
}

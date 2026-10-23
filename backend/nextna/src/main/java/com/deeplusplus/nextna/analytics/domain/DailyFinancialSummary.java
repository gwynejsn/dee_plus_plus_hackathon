package com.deeplusplus.nextna.analytics.domain;

import java.math.BigDecimal;
import java.time.LocalDate;

public record DailyFinancialSummary(
        LocalDate reportDate,
        long totalServicesCompleted,
        BigDecimal totalRevenuePhp,
        double averageServiceDurationMinutes,
        BigDecimal revenuePerMinutePhp
) {}

package com.deeplusplus.NextNa.servicecatalog.application;

import java.math.BigDecimal;

public record CreateServiceCommand(
        String name,
        String category,
        BigDecimal unitPrice,
        Integer baselineDurationMinutes
) {}

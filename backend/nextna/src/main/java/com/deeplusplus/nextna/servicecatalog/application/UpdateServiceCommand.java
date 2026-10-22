package com.deeplusplus.nextna.servicecatalog.application;

import java.math.BigDecimal;

public record UpdateServiceCommand(
        String name,
        String category,
        BigDecimal unitPrice,
        Integer baselineDurationMinutes
) {}

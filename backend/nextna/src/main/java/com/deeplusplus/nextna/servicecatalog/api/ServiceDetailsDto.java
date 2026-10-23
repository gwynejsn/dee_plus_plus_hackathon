package com.deeplusplus.nextna.servicecatalog.api;

import java.math.BigDecimal;

public record ServiceDetailsDto(
        String id,
        String name,
        String category,
        BigDecimal unitPrice,
        int baselineDurationMinutes,
        boolean active
) {}

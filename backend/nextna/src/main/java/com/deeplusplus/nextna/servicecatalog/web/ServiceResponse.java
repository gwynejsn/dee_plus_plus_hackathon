package com.deeplusplus.nextna.servicecatalog.web;

import com.deeplusplus.nextna.servicecatalog.application.ServiceResponseDto;

import java.math.BigDecimal;
import java.time.Instant;

public record ServiceResponse(
        String id,
        String name,
        String category,
        BigDecimal unitPrice,
        int baselineDurationMinutes,
        boolean active,
        Instant createdAt,
        Instant updatedAt
) {
    public static ServiceResponse from(ServiceResponseDto dto) {
        return new ServiceResponse(
                dto.id(),
                dto.name(),
                dto.category(),
                dto.unitPrice(),
                dto.baselineDurationMinutes(),
                dto.active(),
                dto.createdAt(),
                dto.updatedAt()
        );
    }
}

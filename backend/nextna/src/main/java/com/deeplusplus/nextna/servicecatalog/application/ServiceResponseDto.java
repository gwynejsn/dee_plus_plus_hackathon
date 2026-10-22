package com.deeplusplus.nextna.servicecatalog.application;

import com.deeplusplus.nextna.servicecatalog.domain.CatalogService;

import java.math.BigDecimal;
import java.time.Instant;

public record ServiceResponseDto(
        String id,
        String name,
        String category,
        BigDecimal unitPrice,
        int baselineDurationMinutes,
        boolean active,
        Instant createdAt,
        Instant updatedAt
) {
    public static ServiceResponseDto from(CatalogService domain) {
        return new ServiceResponseDto(
                domain.getId().value(),
                domain.getName(),
                domain.getCategory().name(),
                domain.getPrice().amount(),
                domain.getBaselineDuration().minutes(),
                domain.isActive(),
                domain.getCreatedAt(),
                domain.getUpdatedAt()
        );
    }
}

package com.deeplusplus.nextna.analytics.web;

import com.deeplusplus.nextna.analytics.application.TelemetryLogDto;

import java.math.BigDecimal;
import java.time.Instant;

public record TelemetryLogResponse(
        String id,
        String ticketId,
        int ticketNumber,
        String customerName,
        String serviceId,
        String serviceName,
        BigDecimal servicePrice,
        Instant timeIntake,
        Instant timeCommenced,
        Instant timeFulfilled,
        int actualDurationMinutes,
        int estimatedDurationMinutes,
        int durationVarianceMinutes,
        int dayOfWeek,
        int hourOfDay,
        Instant createdAt
) {
    public static TelemetryLogResponse from(TelemetryLogDto dto) {
        return new TelemetryLogResponse(
                dto.id(),
                dto.ticketId(),
                dto.ticketNumber(),
                dto.customerName(),
                dto.serviceId(),
                dto.serviceName(),
                dto.servicePrice(),
                dto.timeIntake(),
                dto.timeCommenced(),
                dto.timeFulfilled(),
                dto.actualDurationMinutes(),
                dto.estimatedDurationMinutes(),
                dto.durationVarianceMinutes(),
                dto.dayOfWeek(),
                dto.hourOfDay(),
                dto.createdAt()
        );
    }
}

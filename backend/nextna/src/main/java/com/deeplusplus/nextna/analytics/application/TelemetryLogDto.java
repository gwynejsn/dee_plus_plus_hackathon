package com.deeplusplus.nextna.analytics.application;

import com.deeplusplus.nextna.analytics.domain.TelemetryLog;

import java.math.BigDecimal;
import java.time.Instant;

public record TelemetryLogDto(
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
    public static TelemetryLogDto from(TelemetryLog domain) {
        return new TelemetryLogDto(
                domain.getId().value(),
                domain.getTicketId(),
                domain.getTicketNumber(),
                domain.getCustomerName(),
                domain.getServiceId(),
                domain.getServiceName(),
                domain.getServicePrice(),
                domain.getTimeIntake(),
                domain.getTimeCommenced(),
                domain.getTimeFulfilled(),
                domain.getActualDurationMinutes(),
                domain.getEstimatedDurationMinutes(),
                domain.getDurationVarianceMinutes(),
                domain.getDayOfWeek(),
                domain.getHourOfDay(),
                domain.getCreatedAt()
        );
    }
}

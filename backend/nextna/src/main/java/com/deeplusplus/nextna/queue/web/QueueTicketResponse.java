package com.deeplusplus.NextNa.queue.web;

import com.deeplusplus.NextNa.queue.application.QueueTicketResponseDto;

import java.math.BigDecimal;
import java.time.Instant;

public record QueueTicketResponse(
        String id,
        int ticketNumber,
        String customerName,
        String serviceId,
        BigDecimal servicePrice,
        String state,
        int estimatedWaitMinutes,
        boolean manualOverride,
        boolean onMyWayConfirmed,
        Instant createdAt,
        Instant calledAt,
        Instant completedAt
) {
    public static QueueTicketResponse from(QueueTicketResponseDto dto) {
        return new QueueTicketResponse(
                dto.id(),
                dto.ticketNumber(),
                dto.customerName(),
                dto.serviceId(),
                dto.servicePrice(),
                dto.state(),
                dto.estimatedWaitMinutes(),
                dto.manualOverride(),
                dto.onMyWayConfirmed(),
                dto.createdAt(),
                dto.calledAt(),
                dto.completedAt()
        );
    }
}

package com.deeplusplus.nextna.queue.application;

import com.deeplusplus.nextna.queue.domain.QueueTicket;

import java.math.BigDecimal;
import java.time.Instant;

public record QueueTicketResponseDto(
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
    public static QueueTicketResponseDto from(QueueTicket domain) {
        return new QueueTicketResponseDto(
                domain.getId().value(),
                domain.getTicketNumber().value(),
                domain.getCustomerName().value(),
                domain.getServiceId(),
                domain.getServicePrice(),
                domain.getState().name(),
                domain.getEstimatedWaitMinutes(),
                domain.isManualOverride(),
                domain.isOnMyWayConfirmed(),
                domain.getCreatedAt(),
                domain.getCalledAt(),
                domain.getCompletedAt()
        );
    }
}

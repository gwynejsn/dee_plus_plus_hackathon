package com.deeplusplus.NextNa.queue.api;

import java.math.BigDecimal;
import java.time.Instant;

public record QueueTicketSummaryDto(
        String ticketId,
        int ticketNumber,
        String customerName,
        String serviceId,
        BigDecimal servicePrice,
        String state,
        int estimatedWaitMinutes,
        boolean onMyWayConfirmed,
        Instant createdAt,
        Instant calledAt,
        Instant completedAt
) {}

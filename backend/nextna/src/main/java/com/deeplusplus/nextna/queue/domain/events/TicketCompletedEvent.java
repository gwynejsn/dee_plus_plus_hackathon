package com.deeplusplus.nextna.queue.domain.events;

import java.math.BigDecimal;
import java.time.Instant;

public record TicketCompletedEvent(
        String ticketId,
        int ticketNumber,
        String customerName,
        String serviceId,
        BigDecimal servicePrice,
        Instant createdAt,
        Instant calledAt,
        Instant completedAt,
        int actualDurationMinutes
) {}

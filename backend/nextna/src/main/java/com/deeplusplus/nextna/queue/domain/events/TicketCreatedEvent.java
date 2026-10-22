package com.deeplusplus.NextNa.queue.domain.events;

import java.time.Instant;

public record TicketCreatedEvent(
        String ticketId,
        int ticketNumber,
        String customerName,
        String serviceId,
        Instant createdAt
) {}

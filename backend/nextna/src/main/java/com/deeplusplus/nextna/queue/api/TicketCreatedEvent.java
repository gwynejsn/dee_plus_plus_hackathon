package com.deeplusplus.nextna.queue.api;

import java.time.Instant;

public record TicketCreatedEvent(
        String ticketId,
        int ticketNumber,
        String customerName,
        String serviceId,
        Instant createdAt
) {}

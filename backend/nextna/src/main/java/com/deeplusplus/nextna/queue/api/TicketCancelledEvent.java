package com.deeplusplus.nextna.queue.api;

import java.time.Instant;

public record TicketCancelledEvent(
        String ticketId,
        int ticketNumber,
        Instant cancelledAt
) {}

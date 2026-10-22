package com.deeplusplus.NextNa.queue.domain.events;

import java.time.Instant;

public record TicketCancelledEvent(
        String ticketId,
        int ticketNumber,
        Instant cancelledAt
) {}

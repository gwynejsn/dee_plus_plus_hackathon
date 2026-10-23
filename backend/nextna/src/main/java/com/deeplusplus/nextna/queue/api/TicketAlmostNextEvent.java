package com.deeplusplus.nextna.queue.api;

import java.time.Instant;

public record TicketAlmostNextEvent(
        String ticketId,
        int ticketNumber,
        String customerName,
        Instant stagedAt
) {}

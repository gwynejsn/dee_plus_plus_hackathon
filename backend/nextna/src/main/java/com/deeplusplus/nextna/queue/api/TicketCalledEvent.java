package com.deeplusplus.nextna.queue.api;

import java.time.Instant;

public record TicketCalledEvent(
        String ticketId,
        int ticketNumber,
        String customerName,
        Instant calledAt
) {}

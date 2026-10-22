package com.deeplusplus.NextNa.queue.domain.events;

import java.time.Instant;

public record TicketCalledEvent(
        String ticketId,
        int ticketNumber,
        String customerName,
        Instant calledAt
) {}

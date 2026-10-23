package com.deeplusplus.nextna.queue.api;

import java.time.Instant;

public record TicketOnMyWayEvent(
        String ticketId,
        int ticketNumber,
        Instant confirmedAt
) {}

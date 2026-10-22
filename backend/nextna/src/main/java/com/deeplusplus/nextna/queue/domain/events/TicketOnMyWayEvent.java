package com.deeplusplus.nextna.queue.domain.events;

import java.time.Instant;

public record TicketOnMyWayEvent(
        String ticketId,
        int ticketNumber,
        Instant confirmedAt
) {}

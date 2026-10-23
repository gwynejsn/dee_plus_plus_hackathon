package com.deeplusplus.nextna.queue.domain;

import java.util.Objects;
import java.util.UUID;

public record TicketId(String value) {

    public TicketId {
        Objects.requireNonNull(value, "Ticket id cannot be null");
        if (value.isBlank()) {
            throw new IllegalArgumentException("Ticket id cannot be blank");
        }
    }

    public static TicketId of(String value) {
        return new TicketId(value);
    }

    public static TicketId generate() {
        return new TicketId("tkt-" + UUID.randomUUID().toString().substring(0, 8));
    }
}

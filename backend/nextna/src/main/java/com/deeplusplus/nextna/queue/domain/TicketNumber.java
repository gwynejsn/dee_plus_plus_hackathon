package com.deeplusplus.nextna.queue.domain;

public record TicketNumber(int value) {

    public TicketNumber {
        if (value <= 0) {
            throw new InvalidTicketNumberException("Ticket number must be greater than zero");
        }
    }

    public static TicketNumber of(int value) {
        return new TicketNumber(value);
    }
}

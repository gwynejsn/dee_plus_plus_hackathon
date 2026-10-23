package com.deeplusplus.nextna.queue.domain;

public class TicketNotFoundException extends RuntimeException {
    public TicketNotFoundException(String message) {
        super(message);
    }

    public static TicketNotFoundException of(String id) {
        return new TicketNotFoundException("Queue ticket with id '" + id + "' was not found");
    }

    public static TicketNotFoundException of(int ticketNumber) {
        return new TicketNotFoundException("Queue ticket with number '" + ticketNumber + "' was not found");
    }
}

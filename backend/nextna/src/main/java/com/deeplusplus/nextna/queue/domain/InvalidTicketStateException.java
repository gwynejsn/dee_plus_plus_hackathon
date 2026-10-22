package com.deeplusplus.NextNa.queue.domain;

public class InvalidTicketStateException extends RuntimeException {
    public InvalidTicketStateException(String message) {
        super(message);
    }
}

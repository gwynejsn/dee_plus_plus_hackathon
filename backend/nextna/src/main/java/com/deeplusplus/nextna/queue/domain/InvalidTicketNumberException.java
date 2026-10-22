package com.deeplusplus.nextna.queue.domain;

public class InvalidTicketNumberException extends RuntimeException {
    public InvalidTicketNumberException(String message) {
        super(message);
    }
}

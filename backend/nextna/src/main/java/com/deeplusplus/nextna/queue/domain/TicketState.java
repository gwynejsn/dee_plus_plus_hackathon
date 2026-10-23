package com.deeplusplus.nextna.queue.domain;

public enum TicketState {
    WAITING,
    ALMOST_NEXT,
    NOW_SERVING,
    COMPLETED,
    CANCELLED;

    public boolean isActive() {
        return this == WAITING || this == ALMOST_NEXT || this == NOW_SERVING;
    }

    public boolean isTerminal() {
        return this == COMPLETED || this == CANCELLED;
    }
}

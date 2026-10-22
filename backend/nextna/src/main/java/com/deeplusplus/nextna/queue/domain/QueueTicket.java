package com.deeplusplus.NextNa.queue.domain;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.Objects;

public class QueueTicket {

    private final TicketId id;
    private final TicketNumber ticketNumber;
    private final CustomerName customerName;
    private final String serviceId;
    private final BigDecimal servicePrice;
    private TicketState state;
    private int estimatedWaitMinutes;
    private boolean manualOverride;
    private boolean onMyWayConfirmed;
    private final Instant createdAt;
    private Instant calledAt;
    private Instant completedAt;

    private QueueTicket(
            TicketId id,
            TicketNumber ticketNumber,
            CustomerName customerName,
            String serviceId,
            BigDecimal servicePrice,
            TicketState state,
            int estimatedWaitMinutes,
            boolean manualOverride,
            boolean onMyWayConfirmed,
            Instant createdAt,
            Instant calledAt,
            Instant completedAt
    ) {
        this.id = Objects.requireNonNull(id, "Ticket id cannot be null");
        this.ticketNumber = Objects.requireNonNull(ticketNumber, "Ticket number cannot be null");
        this.customerName = Objects.requireNonNull(customerName, "Customer name cannot be null");
        this.serviceId = Objects.requireNonNull(serviceId, "Service id cannot be null");
        this.servicePrice = Objects.requireNonNull(servicePrice, "Service price cannot be null");
        this.state = Objects.requireNonNull(state, "Ticket state cannot be null");
        this.estimatedWaitMinutes = Math.max(0, estimatedWaitMinutes);
        this.manualOverride = manualOverride;
        this.onMyWayConfirmed = onMyWayConfirmed;
        this.createdAt = Objects.requireNonNull(createdAt, "Created at cannot be null");
        this.calledAt = calledAt;
        this.completedAt = completedAt;
    }

    public static QueueTicket issue(
            TicketNumber ticketNumber,
            CustomerName customerName,
            String serviceId,
            BigDecimal servicePrice,
            int estimatedWaitMinutes
    ) {
        return new QueueTicket(
                TicketId.generate(),
                ticketNumber,
                customerName,
                serviceId,
                servicePrice,
                TicketState.WAITING,
                estimatedWaitMinutes,
                false,
                false,
                Instant.now(),
                null,
                null
        );
    }

    public static QueueTicket reconstruct(
            TicketId id,
            TicketNumber ticketNumber,
            CustomerName customerName,
            String serviceId,
            BigDecimal servicePrice,
            TicketState state,
            int estimatedWaitMinutes,
            boolean manualOverride,
            boolean onMyWayConfirmed,
            Instant createdAt,
            Instant calledAt,
            Instant completedAt
    ) {
        return new QueueTicket(
                id,
                ticketNumber,
                customerName,
                serviceId,
                servicePrice,
                state,
                estimatedWaitMinutes,
                manualOverride,
                onMyWayConfirmed,
                createdAt,
                calledAt,
                completedAt
        );
    }

    public void call() {
        if (state.isTerminal()) {
            throw new InvalidTicketStateException("Cannot call ticket in terminal state: " + state);
        }
        this.state = TicketState.NOW_SERVING;
        if (this.calledAt == null) {
            this.calledAt = Instant.now();
        }
    }

    public void stageAlmostNext() {
        if (state != TicketState.WAITING) {
            throw new InvalidTicketStateException("Only tickets in WAITING state can be staged to ALMOST_NEXT");
        }
        this.state = TicketState.ALMOST_NEXT;
    }

    public void serve() {
        if (state.isTerminal()) {
            throw new InvalidTicketStateException("Cannot serve ticket in terminal state: " + state);
        }
        this.state = TicketState.NOW_SERVING;
        if (this.calledAt == null) {
            this.calledAt = Instant.now();
        }
    }

    public void complete() {
        if (state != TicketState.NOW_SERVING) {
            throw new InvalidTicketStateException("Ticket must be in NOW_SERVING state to be completed. Current state: " + state);
        }
        this.state = TicketState.COMPLETED;
        this.completedAt = Instant.now();
    }

    public void cancel() {
        if (state == TicketState.COMPLETED) {
            throw new InvalidTicketStateException("Cannot cancel an already completed ticket");
        }
        this.state = TicketState.CANCELLED;
        if (this.completedAt == null) {
            this.completedAt = Instant.now();
        }
    }

    public void confirmOnMyWay() {
        if (state.isTerminal()) {
            throw new InvalidTicketStateException("Cannot confirm 'on my way' for a ticket in terminal state: " + state);
        }
        this.onMyWayConfirmed = true;
    }

    public void overrideEstimatedWait(int minutes) {
        if (minutes < 0) {
            throw new IllegalArgumentException("Estimated wait minutes cannot be negative");
        }
        this.estimatedWaitMinutes = minutes;
        this.manualOverride = true;
    }

    public void updateCalculatedWait(int minutes) {
        if (!manualOverride) {
            this.estimatedWaitMinutes = Math.max(0, minutes);
        }
    }

    public int calculateActualDurationMinutes() {
        Instant start = (calledAt != null) ? calledAt : createdAt;
        Instant end = (completedAt != null) ? completedAt : Instant.now();
        long minutes = Duration.between(start, end).toMinutes();
        return (int) Math.max(0, minutes);
    }

    public TicketId getId() {
        return id;
    }

    public TicketNumber getTicketNumber() {
        return ticketNumber;
    }

    public CustomerName getCustomerName() {
        return customerName;
    }

    public String getServiceId() {
        return serviceId;
    }

    public BigDecimal getServicePrice() {
        return servicePrice;
    }

    public TicketState getState() {
        return state;
    }

    public int getEstimatedWaitMinutes() {
        return estimatedWaitMinutes;
    }

    public boolean isManualOverride() {
        return manualOverride;
    }

    public boolean isOnMyWayConfirmed() {
        return onMyWayConfirmed;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getCalledAt() {
        return calledAt;
    }

    public Instant getCompletedAt() {
        return completedAt;
    }
}

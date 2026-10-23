package com.deeplusplus.nextna.notification.domain;

import java.time.Instant;
import java.util.Objects;

public class BuzzerNotification {

    private final String ticketId;
    private final int ticketNumber;
    private final String customerName;
    private BuzzerAlertStatus status;
    private int peopleAhead;
    private int estimatedWaitMinutes;
    private boolean onMyWayConfirmed;
    private String alertMessage;
    private Instant updatedAt;

    public BuzzerNotification(
            String ticketId,
            int ticketNumber,
            String customerName,
            BuzzerAlertStatus status,
            int peopleAhead,
            int estimatedWaitMinutes,
            boolean onMyWayConfirmed,
            String alertMessage,
            Instant updatedAt
    ) {
        if (ticketId == null || ticketId.isBlank()) {
            throw new IllegalArgumentException("Ticket ID cannot be null or blank");
        }
        if (ticketNumber <= 0) {
            throw new IllegalArgumentException("Ticket number must be positive");
        }
        if (peopleAhead < 0) {
            throw new IllegalArgumentException("People ahead cannot be negative");
        }
        if (estimatedWaitMinutes < 0) {
            throw new IllegalArgumentException("Estimated wait minutes cannot be negative");
        }
        this.ticketId = ticketId;
        this.ticketNumber = ticketNumber;
        this.customerName = customerName != null ? customerName.trim() : "";
        this.status = Objects.requireNonNull(status, "Status cannot be null");
        this.peopleAhead = peopleAhead;
        this.estimatedWaitMinutes = estimatedWaitMinutes;
        this.onMyWayConfirmed = onMyWayConfirmed;
        this.alertMessage = alertMessage != null ? alertMessage : "";
        this.updatedAt = updatedAt != null ? updatedAt : Instant.now();
    }

    public static BuzzerNotification createInitial(
            String ticketId,
            int ticketNumber,
            String customerName,
            int peopleAhead,
            int estimatedWaitMinutes
    ) {
        return new BuzzerNotification(
                ticketId,
                ticketNumber,
                customerName,
                BuzzerAlertStatus.IN_LINE,
                peopleAhead,
                estimatedWaitMinutes,
                false,
                "You are in line. Please keep this virtual buzzer active.",
                Instant.now()
        );
    }

    public void markAlmostNext() {
        this.status = BuzzerAlertStatus.ALMOST_NEXT;
        this.peopleAhead = 1;
        this.alertMessage = "Almost your turn! Please start heading back to the shop.";
        this.updatedAt = Instant.now();
    }

    public void markNowServing() {
        this.status = BuzzerAlertStatus.NOW_SERVING;
        this.peopleAhead = 0;
        this.estimatedWaitMinutes = 0;
        this.alertMessage = "Your turn now! Please proceed to the service counter.";
        this.updatedAt = Instant.now();
    }

    public void markCompleted() {
        this.status = BuzzerAlertStatus.COMPLETED;
        this.peopleAhead = 0;
        this.estimatedWaitMinutes = 0;
        this.alertMessage = "Service completed. Thank you for visiting!";
        this.updatedAt = Instant.now();
    }

    public void markCancelled() {
        this.status = BuzzerAlertStatus.CANCELLED;
        this.peopleAhead = 0;
        this.estimatedWaitMinutes = 0;
        this.alertMessage = "This ticket has been cancelled.";
        this.updatedAt = Instant.now();
    }

    public void confirmOnMyWay() {
        this.onMyWayConfirmed = true;
        this.alertMessage = "Shop notified: You are on your way!";
        this.updatedAt = Instant.now();
    }

    public void updatePosition(int peopleAhead, int estimatedWaitMinutes) {
        if (peopleAhead < 0) {
            throw new IllegalArgumentException("People ahead cannot be negative");
        }
        if (estimatedWaitMinutes < 0) {
            throw new IllegalArgumentException("Estimated wait minutes cannot be negative");
        }
        this.peopleAhead = peopleAhead;
        this.estimatedWaitMinutes = estimatedWaitMinutes;
        this.updatedAt = Instant.now();
    }

    public String getTicketId() {
        return ticketId;
    }

    public int getTicketNumber() {
        return ticketNumber;
    }

    public String getCustomerName() {
        return customerName;
    }

    public BuzzerAlertStatus getStatus() {
        return status;
    }

    public int getPeopleAhead() {
        return peopleAhead;
    }

    public int getEstimatedWaitMinutes() {
        return estimatedWaitMinutes;
    }

    public boolean isOnMyWayConfirmed() {
        return onMyWayConfirmed;
    }

    public String getAlertMessage() {
        return alertMessage;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}

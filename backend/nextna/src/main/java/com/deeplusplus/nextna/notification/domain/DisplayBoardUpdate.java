package com.deeplusplus.nextna.notification.domain;

import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class DisplayBoardUpdate {

    private final String eventType;
    private final Integer currentServingNumber;
    private final String currentServingCustomer;
    private final Integer almostNextNumber;
    private final String almostNextCustomer;
    private final int totalWaitingCount;
    private final List<Integer> waitingNumbers;
    private final String alertMessage;
    private final Instant timestamp;

    public DisplayBoardUpdate(
            String eventType,
            Integer currentServingNumber,
            String currentServingCustomer,
            Integer almostNextNumber,
            String almostNextCustomer,
            int totalWaitingCount,
            List<Integer> waitingNumbers,
            String alertMessage,
            Instant timestamp
    ) {
        if (eventType == null || eventType.isBlank()) {
            throw new IllegalArgumentException("Event type cannot be null or blank");
        }
        if (totalWaitingCount < 0) {
            throw new IllegalArgumentException("Total waiting count cannot be negative");
        }
        this.eventType = eventType;
        this.currentServingNumber = currentServingNumber;
        this.currentServingCustomer = currentServingCustomer;
        this.almostNextNumber = almostNextNumber;
        this.almostNextCustomer = almostNextCustomer;
        this.totalWaitingCount = totalWaitingCount;
        this.waitingNumbers = waitingNumbers != null ? List.copyOf(waitingNumbers) : Collections.emptyList();
        this.alertMessage = alertMessage != null ? alertMessage : "";
        this.timestamp = Objects.requireNonNullElseGet(timestamp, Instant::now);
    }

    public String getEventType() {
        return eventType;
    }

    public Integer getCurrentServingNumber() {
        return currentServingNumber;
    }

    public String getCurrentServingCustomer() {
        return currentServingCustomer;
    }

    public Integer getAlmostNextNumber() {
        return almostNextNumber;
    }

    public String getAlmostNextCustomer() {
        return almostNextCustomer;
    }

    public int getTotalWaitingCount() {
        return totalWaitingCount;
    }

    public List<Integer> getWaitingNumbers() {
        return waitingNumbers;
    }

    public String getAlertMessage() {
        return alertMessage;
    }

    public Instant getTimestamp() {
        return timestamp;
    }
}

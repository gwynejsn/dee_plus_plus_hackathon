package com.deeplusplus.nextna.analytics.domain;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Objects;

public class TelemetryLog {

    private final TelemetryLogId id;
    private final String ticketId;
    private final int ticketNumber;
    private final String customerName;
    private final String serviceId;
    private final String serviceName;
    private final BigDecimal servicePrice;
    private final Instant timeIntake;
    private final Instant timeCommenced;
    private final Instant timeFulfilled;
    private final int actualDurationMinutes;
    private final int estimatedDurationMinutes;
    private final int durationVarianceMinutes;
    private final int dayOfWeek;
    private final int hourOfDay;
    private final Instant createdAt;

    private TelemetryLog(
            TelemetryLogId id,
            String ticketId,
            int ticketNumber,
            String customerName,
            String serviceId,
            String serviceName,
            BigDecimal servicePrice,
            Instant timeIntake,
            Instant timeCommenced,
            Instant timeFulfilled,
            int actualDurationMinutes,
            int estimatedDurationMinutes,
            int durationVarianceMinutes,
            int dayOfWeek,
            int hourOfDay,
            Instant createdAt
    ) {
        this.id = Objects.requireNonNull(id, "Telemetry id cannot be null");
        this.ticketId = Objects.requireNonNull(ticketId, "Ticket id cannot be null");
        this.ticketNumber = ticketNumber;
        this.customerName = customerName;
        this.serviceId = Objects.requireNonNull(serviceId, "Service id cannot be null");
        this.serviceName = Objects.requireNonNull(serviceName, "Service name cannot be null");
        this.servicePrice = Objects.requireNonNull(servicePrice, "Service price cannot be null");
        this.timeIntake = Objects.requireNonNull(timeIntake, "Intake time cannot be null");
        this.timeCommenced = Objects.requireNonNull(timeCommenced, "Commence time cannot be null");
        this.timeFulfilled = Objects.requireNonNull(timeFulfilled, "Fulfilled time cannot be null");
        this.actualDurationMinutes = Math.max(0, actualDurationMinutes);
        this.estimatedDurationMinutes = Math.max(0, estimatedDurationMinutes);
        this.durationVarianceMinutes = durationVarianceMinutes;
        this.dayOfWeek = dayOfWeek;
        this.hourOfDay = hourOfDay;
        this.createdAt = Objects.requireNonNull(createdAt, "Created at cannot be null");
    }

    public static TelemetryLog record(
            String ticketId,
            int ticketNumber,
            String customerName,
            String serviceId,
            String serviceName,
            BigDecimal servicePrice,
            Instant timeIntake,
            Instant timeCommenced,
            Instant timeFulfilled,
            int actualDurationMinutes,
            int estimatedDurationMinutes
    ) {
        int variance = actualDurationMinutes - estimatedDurationMinutes;

        ZonedDateTime localFulfilled = timeFulfilled.atZone(ZoneId.systemDefault());
        int dayOfWeek = localFulfilled.getDayOfWeek().getValue();
        int hourOfDay = localFulfilled.getHour();

        return new TelemetryLog(
                TelemetryLogId.generate(),
                ticketId,
                ticketNumber,
                customerName,
                serviceId,
                serviceName,
                servicePrice,
                timeIntake,
                timeCommenced,
                timeFulfilled,
                actualDurationMinutes,
                estimatedDurationMinutes,
                variance,
                dayOfWeek,
                hourOfDay,
                Instant.now()
        );
    }

    public static TelemetryLog reconstruct(
            TelemetryLogId id,
            String ticketId,
            int ticketNumber,
            String customerName,
            String serviceId,
            String serviceName,
            BigDecimal servicePrice,
            Instant timeIntake,
            Instant timeCommenced,
            Instant timeFulfilled,
            int actualDurationMinutes,
            int estimatedDurationMinutes,
            int durationVarianceMinutes,
            int dayOfWeek,
            int hourOfDay,
            Instant createdAt
    ) {
        return new TelemetryLog(
                id,
                ticketId,
                ticketNumber,
                customerName,
                serviceId,
                serviceName,
                servicePrice,
                timeIntake,
                timeCommenced,
                timeFulfilled,
                actualDurationMinutes,
                estimatedDurationMinutes,
                durationVarianceMinutes,
                dayOfWeek,
                hourOfDay,
                createdAt
        );
    }

    public TelemetryLogId getId() {
        return id;
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

    public String getServiceId() {
        return serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public BigDecimal getServicePrice() {
        return servicePrice;
    }

    public Instant getTimeIntake() {
        return timeIntake;
    }

    public Instant getTimeCommenced() {
        return timeCommenced;
    }

    public Instant getTimeFulfilled() {
        return timeFulfilled;
    }

    public int getActualDurationMinutes() {
        return actualDurationMinutes;
    }

    public int getEstimatedDurationMinutes() {
        return estimatedDurationMinutes;
    }

    public int getDurationVarianceMinutes() {
        return durationVarianceMinutes;
    }

    public int getDayOfWeek() {
        return dayOfWeek;
    }

    public int getHourOfDay() {
        return hourOfDay;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}

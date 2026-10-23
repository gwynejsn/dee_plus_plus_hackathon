package com.deeplusplus.nextna.analytics.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "service_telemetry_logs")
public class TelemetryLogJpaEntity {

    @Id
    @Column(name = "id", length = 36, nullable = false)
    private String id;

    @Column(name = "ticket_id", length = 36, nullable = false)
    private String ticketId;

    @Column(name = "ticket_number", nullable = false)
    private Integer ticketNumber;

    @Column(name = "customer_name", length = 100)
    private String customerName;

    @Column(name = "service_id", length = 36, nullable = false)
    private String serviceId;

    @Column(name = "service_name", length = 100, nullable = false)
    private String serviceName;

    @Column(name = "service_price", precision = 10, scale = 2, nullable = false)
    private BigDecimal servicePrice;

    @Column(name = "time_intake", nullable = false)
    private Instant timeIntake;

    @Column(name = "time_commenced", nullable = false)
    private Instant timeCommenced;

    @Column(name = "time_fulfilled", nullable = false)
    private Instant timeFulfilled;

    @Column(name = "actual_duration_minutes", nullable = false)
    private Integer actualDurationMinutes;

    @Column(name = "estimated_duration_minutes", nullable = false)
    private Integer estimatedDurationMinutes;

    @Column(name = "duration_variance_minutes", nullable = false)
    private Integer durationVarianceMinutes;

    @Column(name = "day_of_week", nullable = false)
    private Integer dayOfWeek;

    @Column(name = "hour_of_day", nullable = false)
    private Integer hourOfDay;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public TelemetryLogJpaEntity() {}

    public TelemetryLogJpaEntity(
            String id,
            String ticketId,
            Integer ticketNumber,
            String customerName,
            String serviceId,
            String serviceName,
            BigDecimal servicePrice,
            Instant timeIntake,
            Instant timeCommenced,
            Instant timeFulfilled,
            Integer actualDurationMinutes,
            Integer estimatedDurationMinutes,
            Integer durationVarianceMinutes,
            Integer dayOfWeek,
            Integer hourOfDay,
            Instant createdAt
    ) {
        this.id = id;
        this.ticketId = ticketId;
        this.ticketNumber = ticketNumber;
        this.customerName = customerName;
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.servicePrice = servicePrice;
        this.timeIntake = timeIntake;
        this.timeCommenced = timeCommenced;
        this.timeFulfilled = timeFulfilled;
        this.actualDurationMinutes = actualDurationMinutes;
        this.estimatedDurationMinutes = estimatedDurationMinutes;
        this.durationVarianceMinutes = durationVarianceMinutes;
        this.dayOfWeek = dayOfWeek;
        this.hourOfDay = hourOfDay;
        this.createdAt = createdAt;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTicketId() {
        return ticketId;
    }

    public void setTicketId(String ticketId) {
        this.ticketId = ticketId;
    }

    public Integer getTicketNumber() {
        return ticketNumber;
    }

    public void setTicketNumber(Integer ticketNumber) {
        this.ticketNumber = ticketNumber;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public BigDecimal getServicePrice() {
        return servicePrice;
    }

    public void setServicePrice(BigDecimal servicePrice) {
        this.servicePrice = servicePrice;
    }

    public Instant getTimeIntake() {
        return timeIntake;
    }

    public void setTimeIntake(Instant timeIntake) {
        this.timeIntake = timeIntake;
    }

    public Instant getTimeCommenced() {
        return timeCommenced;
    }

    public void setTimeCommenced(Instant timeCommenced) {
        this.timeCommenced = timeCommenced;
    }

    public Instant getTimeFulfilled() {
        return timeFulfilled;
    }

    public void setTimeFulfilled(Instant timeFulfilled) {
        this.timeFulfilled = timeFulfilled;
    }

    public Integer getActualDurationMinutes() {
        return actualDurationMinutes;
    }

    public void setActualDurationMinutes(Integer actualDurationMinutes) {
        this.actualDurationMinutes = actualDurationMinutes;
    }

    public Integer getEstimatedDurationMinutes() {
        return estimatedDurationMinutes;
    }

    public void setEstimatedDurationMinutes(Integer estimatedDurationMinutes) {
        this.estimatedDurationMinutes = estimatedDurationMinutes;
    }

    public Integer getDurationVarianceMinutes() {
        return durationVarianceMinutes;
    }

    public void setDurationVarianceMinutes(Integer durationVarianceMinutes) {
        this.durationVarianceMinutes = durationVarianceMinutes;
    }

    public Integer getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(Integer dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }

    public Integer getHourOfDay() {
        return hourOfDay;
    }

    public void setHourOfDay(Integer hourOfDay) {
        this.hourOfDay = hourOfDay;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}

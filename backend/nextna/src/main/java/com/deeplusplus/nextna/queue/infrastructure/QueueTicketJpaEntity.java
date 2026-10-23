package com.deeplusplus.nextna.queue.infrastructure;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "queue_tickets")
public class QueueTicketJpaEntity {

    @Id
    @Column(name = "id", length = 36, nullable = false)
    private String id;

    @Column(name = "ticket_number", nullable = false)
    private Integer ticketNumber;

    @Column(name = "customer_name", length = 100, nullable = false)
    private String customerName;

    @Column(name = "service_id", length = 36, nullable = false)
    private String serviceId;

    @Column(name = "service_price", precision = 10, scale = 2, nullable = false)
    private BigDecimal servicePrice;

    @Column(name = "state", length = 20, nullable = false)
    private String state;

    @Column(name = "estimated_wait_minutes", nullable = false)
    private Integer estimatedWaitMinutes;

    @Column(name = "is_manual_override", nullable = false)
    private Boolean manualOverride;

    @Column(name = "on_my_way_confirmed", nullable = false)
    private Boolean onMyWayConfirmed;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "called_at")
    private Instant calledAt;

    @Column(name = "completed_at")
    private Instant completedAt;

    public QueueTicketJpaEntity() {}

    public QueueTicketJpaEntity(
            String id,
            Integer ticketNumber,
            String customerName,
            String serviceId,
            BigDecimal servicePrice,
            String state,
            Integer estimatedWaitMinutes,
            Boolean manualOverride,
            Boolean onMyWayConfirmed,
            Instant createdAt,
            Instant calledAt,
            Instant completedAt
    ) {
        this.id = id;
        this.ticketNumber = ticketNumber;
        this.customerName = customerName;
        this.serviceId = serviceId;
        this.servicePrice = servicePrice;
        this.state = state;
        this.estimatedWaitMinutes = estimatedWaitMinutes;
        this.manualOverride = manualOverride;
        this.onMyWayConfirmed = onMyWayConfirmed;
        this.createdAt = createdAt;
        this.calledAt = calledAt;
        this.completedAt = completedAt;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
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

    public BigDecimal getServicePrice() {
        return servicePrice;
    }

    public void setServicePrice(BigDecimal servicePrice) {
        this.servicePrice = servicePrice;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public Integer getEstimatedWaitMinutes() {
        return estimatedWaitMinutes;
    }

    public void setEstimatedWaitMinutes(Integer estimatedWaitMinutes) {
        this.estimatedWaitMinutes = estimatedWaitMinutes;
    }

    public Boolean getManualOverride() {
        return manualOverride;
    }

    public void setManualOverride(Boolean manualOverride) {
        this.manualOverride = manualOverride;
    }

    public Boolean getOnMyWayConfirmed() {
        return onMyWayConfirmed;
    }

    public void setOnMyWayConfirmed(Boolean onMyWayConfirmed) {
        this.onMyWayConfirmed = onMyWayConfirmed;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getCalledAt() {
        return calledAt;
    }

    public void setCalledAt(Instant calledAt) {
        this.calledAt = calledAt;
    }

    public Instant getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(Instant completedAt) {
        this.completedAt = completedAt;
    }
}

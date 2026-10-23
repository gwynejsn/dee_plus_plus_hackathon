package com.deeplusplus.nextna.servicecatalog.domain;

import java.time.Instant;
import java.util.Objects;

public class CatalogService {
    private final ServiceId id;
    private String name;
    private ServiceCategory category;
    private ServicePrice price;
    private DurationMinutes baselineDuration;
    private boolean active;
    private final Instant createdAt;
    private Instant updatedAt;

    private CatalogService(ServiceId id,
                           String name,
                           ServiceCategory category,
                           ServicePrice price,
                           DurationMinutes baselineDuration,
                           boolean active,
                           Instant createdAt,
                           Instant updatedAt) {
        this.id = Objects.requireNonNull(id, "ServiceId cannot be null");
        validateName(name);
        this.name = name.trim();
        this.category = Objects.requireNonNullElse(category, ServiceCategory.GENERAL);
        this.price = Objects.requireNonNull(price, "ServicePrice cannot be null");
        this.baselineDuration = Objects.requireNonNull(baselineDuration, "DurationMinutes cannot be null");
        this.active = active;
        this.createdAt = Objects.requireNonNullElseGet(createdAt, Instant::now);
        this.updatedAt = Objects.requireNonNullElseGet(updatedAt, Instant::now);
    }

    public static CatalogService create(String name,
                                        ServiceCategory category,
                                        ServicePrice price,
                                        DurationMinutes baselineDuration) {
        Instant now = Instant.now();
        return new CatalogService(
                ServiceId.generate(),
                name,
                category,
                price,
                baselineDuration,
                true,
                now,
                now
        );
    }

    public static CatalogService reconstitute(ServiceId id,
                                              String name,
                                              ServiceCategory category,
                                              ServicePrice price,
                                              DurationMinutes baselineDuration,
                                              boolean active,
                                              Instant createdAt,
                                              Instant updatedAt) {
        return new CatalogService(id, name, category, price, baselineDuration, active, createdAt, updatedAt);
    }

    public void updateDetails(String name,
                              ServiceCategory category,
                              ServicePrice price,
                              DurationMinutes baselineDuration) {
        validateName(name);
        this.name = name.trim();
        this.category = Objects.requireNonNullElse(category, ServiceCategory.GENERAL);
        this.price = Objects.requireNonNull(price, "ServicePrice cannot be null");
        this.baselineDuration = Objects.requireNonNull(baselineDuration, "DurationMinutes cannot be null");
        this.updatedAt = Instant.now();
    }

    public void updatePricing(ServicePrice newPrice) {
        this.price = Objects.requireNonNull(newPrice, "ServicePrice cannot be null");
        this.updatedAt = Instant.now();
    }

    public void updateDuration(DurationMinutes newDuration) {
        this.baselineDuration = Objects.requireNonNull(newDuration, "DurationMinutes cannot be null");
        this.updatedAt = Instant.now();
    }

    public void deactivate() {
        this.active = false;
        this.updatedAt = Instant.now();
    }

    public void activate() {
        this.active = true;
        this.updatedAt = Instant.now();
    }

    private void validateName(String name) {
        if (name == null || name.trim().length() < 2 || name.trim().length() > 100) {
            throw new InvalidServiceNameException("Service name must be between 2 and 100 characters");
        }
    }

    public ServiceId getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public ServiceCategory getCategory() {
        return category;
    }

    public ServicePrice getPrice() {
        return price;
    }

    public DurationMinutes getBaselineDuration() {
        return baselineDuration;
    }

    public boolean isActive() {
        return active;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof CatalogService that)) return false;
        return Objects.equals(id, that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

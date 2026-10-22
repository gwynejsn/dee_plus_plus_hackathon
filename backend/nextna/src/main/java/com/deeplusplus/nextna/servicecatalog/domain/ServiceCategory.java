package com.deeplusplus.NextNa.servicecatalog.domain;

public enum ServiceCategory {
    GENERAL,
    BARBERSHOP,
    CLINIC,
    FOOD_ORDER,
    LAUNDRY,
    CARWASH;

    public static ServiceCategory fromString(String value) {
        if (value == null || value.isBlank()) {
            return GENERAL;
        }
        try {
            return ServiceCategory.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return GENERAL;
        }
    }
}

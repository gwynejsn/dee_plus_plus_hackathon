package com.deeplusplus.NextNa.queue.domain;

public record CustomerName(String value) {

    public CustomerName {
        if (value == null || value.trim().isBlank()) {
            throw new InvalidCustomerNameException("Customer name cannot be empty");
        }
        if (value.trim().length() > 100) {
            throw new InvalidCustomerNameException("Customer name cannot exceed 100 characters");
        }
        value = value.trim();
    }

    public static CustomerName of(String value) {
        return new CustomerName(value);
    }
}

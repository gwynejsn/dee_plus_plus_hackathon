package com.deeplusplus.nextna.servicecatalog.domain;

import java.math.BigDecimal;
import java.math.RoundingMode;

public record ServicePrice(BigDecimal amount) {
    public ServicePrice {
        if (amount == null) {
            throw new InvalidServicePriceException("Service price cannot be null");
        }
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new InvalidServicePriceException("Service price cannot be negative: " + amount);
        }
        amount = amount.setScale(2, RoundingMode.HALF_UP);
    }

    public static ServicePrice of(double amount) {
        return new ServicePrice(BigDecimal.valueOf(amount));
    }

    public static ServicePrice of(BigDecimal amount) {
        return new ServicePrice(amount);
    }
}

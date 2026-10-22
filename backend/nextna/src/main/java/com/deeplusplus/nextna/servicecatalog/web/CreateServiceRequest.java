package com.deeplusplus.NextNa.servicecatalog.web;

import com.deeplusplus.NextNa.servicecatalog.application.CreateServiceCommand;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CreateServiceRequest(
        @NotBlank(message = "Service name is required")
        String name,

        @NotBlank(message = "Service category is required")
        String category,

        @NotNull(message = "Unit price is required")
        @DecimalMin(value = "0.0", inclusive = true, message = "Unit price cannot be negative")
        BigDecimal unitPrice,

        @NotNull(message = "Baseline duration is required")
        @Min(value = 1, message = "Baseline duration must be at least 1 minute")
        @Max(value = 480, message = "Baseline duration cannot exceed 480 minutes")
        Integer baselineDurationMinutes
) {
    public CreateServiceCommand toCommand() {
        return new CreateServiceCommand(name, category, unitPrice, baselineDurationMinutes);
    }
}

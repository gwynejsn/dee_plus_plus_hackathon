package com.deeplusplus.nextna.servicecatalog.web;

import com.deeplusplus.nextna.servicecatalog.application.UpdateServiceCommand;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record UpdateServiceRequest(
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
    public UpdateServiceCommand toCommand() {
        return new UpdateServiceCommand(name, category, unitPrice, baselineDurationMinutes);
    }
}

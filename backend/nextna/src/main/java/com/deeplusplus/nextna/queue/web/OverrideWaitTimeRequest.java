package com.deeplusplus.NextNa.queue.web;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record OverrideWaitTimeRequest(
        @NotNull(message = "Estimated wait minutes is required")
        @Min(value = 0, message = "Estimated wait minutes cannot be negative")
        Integer estimatedWaitMinutes
) {}

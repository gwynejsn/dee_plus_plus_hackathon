package com.deeplusplus.nextna.queue.web;

import com.deeplusplus.nextna.queue.application.IssueTicketCommand;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record IssueTicketRequest(
        @NotBlank(message = "Customer name is required")
        String customerName,

        @NotBlank(message = "Service ID is required")
        String serviceId,

        @Min(value = 0, message = "Manual wait minutes override cannot be negative")
        Integer manualWaitMinutesOverride
) {
    public IssueTicketCommand toCommand() {
        return new IssueTicketCommand(customerName, serviceId, manualWaitMinutesOverride);
    }
}

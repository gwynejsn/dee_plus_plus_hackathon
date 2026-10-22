package com.deeplusplus.NextNa.queue.application;

public record IssueTicketCommand(
        String customerName,
        String serviceId,
        Integer manualWaitMinutesOverride
) {}

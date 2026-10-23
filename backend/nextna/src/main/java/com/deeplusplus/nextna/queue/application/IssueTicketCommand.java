package com.deeplusplus.nextna.queue.application;

public record IssueTicketCommand(
        String customerName,
        String serviceId,
        Integer manualWaitMinutesOverride
) {}

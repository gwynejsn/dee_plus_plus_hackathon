package com.deeplusplus.NextNa.queue.application;

import java.util.List;

public record QueueSummaryDto(
        int totalActive,
        int waitingCount,
        int servingCount,
        QueueTicketResponseDto currentlyServing,
        List<QueueTicketResponseDto> activeTickets
) {}

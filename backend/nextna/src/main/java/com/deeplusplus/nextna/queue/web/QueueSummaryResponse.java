package com.deeplusplus.NextNa.queue.web;

import com.deeplusplus.NextNa.queue.application.QueueSummaryDto;

import java.util.List;

public record QueueSummaryResponse(
        int totalActive,
        int waitingCount,
        int servingCount,
        QueueTicketResponse currentlyServing,
        List<QueueTicketResponse> activeTickets
) {
    public static QueueSummaryResponse from(QueueSummaryDto dto) {
        return new QueueSummaryResponse(
                dto.totalActive(),
                dto.waitingCount(),
                dto.servingCount(),
                dto.currentlyServing() != null ? QueueTicketResponse.from(dto.currentlyServing()) : null,
                dto.activeTickets().stream().map(QueueTicketResponse::from).toList()
        );
    }
}

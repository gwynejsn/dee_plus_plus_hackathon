package com.deeplusplus.NextNa.queue.api;

import java.util.List;
import java.util.Optional;

public interface QueueApi {

    Optional<QueueTicketSummaryDto> findTicketById(String ticketId);

    Optional<QueueTicketSummaryDto> findTicketByNumber(int ticketNumber);

    List<QueueTicketSummaryDto> getActiveTickets();

    int getActiveQueueCount();
}

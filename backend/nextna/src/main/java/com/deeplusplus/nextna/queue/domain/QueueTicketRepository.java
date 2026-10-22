package com.deeplusplus.nextna.queue.domain;

import java.util.List;
import java.util.Optional;

public interface QueueTicketRepository {

    QueueTicket save(QueueTicket ticket);

    Optional<QueueTicket> findById(TicketId id);

    Optional<QueueTicket> findByTicketNumber(TicketNumber number);

    List<QueueTicket> findActiveQueue();

    List<QueueTicket> findByState(TicketState state);

    int findNextTicketNumber();
}

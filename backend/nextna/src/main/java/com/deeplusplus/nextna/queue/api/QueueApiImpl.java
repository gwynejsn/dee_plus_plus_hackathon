package com.deeplusplus.NextNa.queue.api;

import com.deeplusplus.NextNa.queue.domain.QueueTicket;
import com.deeplusplus.NextNa.queue.domain.QueueTicketRepository;
import com.deeplusplus.NextNa.queue.domain.TicketId;
import com.deeplusplus.NextNa.queue.domain.TicketNumber;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
public class QueueApiImpl implements QueueApi {

    private final QueueTicketRepository repository;

    public QueueApiImpl(QueueTicketRepository repository) {
        this.repository = repository;
    }

    @Override
    public Optional<QueueTicketSummaryDto> findTicketById(String ticketId) {
        if (ticketId == null || ticketId.isBlank()) {
            return Optional.empty();
        }
        return repository.findById(TicketId.of(ticketId)).map(this::toDto);
    }

    @Override
    public Optional<QueueTicketSummaryDto> findTicketByNumber(int ticketNumber) {
        if (ticketNumber <= 0) {
            return Optional.empty();
        }
        return repository.findByTicketNumber(TicketNumber.of(ticketNumber)).map(this::toDto);
    }

    @Override
    public List<QueueTicketSummaryDto> getActiveTickets() {
        return repository.findActiveQueue().stream()
                .map(this::toDto)
                .toList();
    }

    @Override
    public int getActiveQueueCount() {
        return repository.findActiveQueue().size();
    }

    private QueueTicketSummaryDto toDto(QueueTicket domain) {
        return new QueueTicketSummaryDto(
                domain.getId().value(),
                domain.getTicketNumber().value(),
                domain.getCustomerName().value(),
                domain.getServiceId(),
                domain.getServicePrice(),
                domain.getState().name(),
                domain.getEstimatedWaitMinutes(),
                domain.isOnMyWayConfirmed(),
                domain.getCreatedAt(),
                domain.getCalledAt(),
                domain.getCompletedAt()
        );
    }
}

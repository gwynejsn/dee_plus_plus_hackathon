package com.deeplusplus.NextNa.queue.infrastructure;

import com.deeplusplus.NextNa.queue.domain.CustomerName;
import com.deeplusplus.NextNa.queue.domain.QueueTicket;
import com.deeplusplus.NextNa.queue.domain.QueueTicketRepository;
import com.deeplusplus.NextNa.queue.domain.TicketId;
import com.deeplusplus.NextNa.queue.domain.TicketNumber;
import com.deeplusplus.NextNa.queue.domain.TicketState;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class QueueTicketRepositoryImpl implements QueueTicketRepository {

    private final SpringDataQueueTicketRepository springDataRepository;

    public QueueTicketRepositoryImpl(SpringDataQueueTicketRepository springDataRepository) {
        this.springDataRepository = springDataRepository;
    }

    @Override
    public QueueTicket save(QueueTicket ticket) {
        QueueTicketJpaEntity entity = toEntity(ticket);
        QueueTicketJpaEntity saved = springDataRepository.save(entity);
        return toDomain(saved);
    }

    @Override
    public Optional<QueueTicket> findById(TicketId id) {
        return springDataRepository.findById(id.value()).map(this::toDomain);
    }

    @Override
    public Optional<QueueTicket> findByTicketNumber(TicketNumber number) {
        return springDataRepository.findByTicketNumber(number.value()).map(this::toDomain);
    }

    @Override
    public List<QueueTicket> findActiveQueue() {
        List<String> activeStates = List.of(
                TicketState.WAITING.name(),
                TicketState.ALMOST_NEXT.name(),
                TicketState.NOW_SERVING.name()
        );
        return springDataRepository.findByStateInOrderByTicketNumberAsc(activeStates)
                .stream()
                .map(this::toDomain)
                .toList();
    }

    @Override
    public List<QueueTicket> findByState(TicketState state) {
        return springDataRepository.findByStateOrderByTicketNumberAsc(state.name())
                .stream()
                .map(this::toDomain)
                .toList();
    }

    @Override
    public int findNextTicketNumber() {
        return springDataRepository.findMaxTicketNumber() + 1;
    }

    private QueueTicketJpaEntity toEntity(QueueTicket domain) {
        return new QueueTicketJpaEntity(
                domain.getId().value(),
                domain.getTicketNumber().value(),
                domain.getCustomerName().value(),
                domain.getServiceId(),
                domain.getServicePrice(),
                domain.getState().name(),
                domain.getEstimatedWaitMinutes(),
                domain.isManualOverride(),
                domain.isOnMyWayConfirmed(),
                domain.getCreatedAt(),
                domain.getCalledAt(),
                domain.getCompletedAt()
        );
    }

    private QueueTicket toDomain(QueueTicketJpaEntity entity) {
        return QueueTicket.reconstruct(
                TicketId.of(entity.getId()),
                TicketNumber.of(entity.getTicketNumber()),
                CustomerName.of(entity.getCustomerName()),
                entity.getServiceId(),
                entity.getServicePrice(),
                TicketState.valueOf(entity.getState()),
                entity.getEstimatedWaitMinutes(),
                entity.getManualOverride(),
                entity.getOnMyWayConfirmed(),
                entity.getCreatedAt(),
                entity.getCalledAt(),
                entity.getCompletedAt()
        );
    }
}

package com.deeplusplus.nextna.queue.application;

import com.deeplusplus.nextna.queue.domain.CustomerName;
import com.deeplusplus.nextna.queue.domain.InvalidTicketStateException;
import com.deeplusplus.nextna.queue.domain.QueueTicket;
import com.deeplusplus.nextna.queue.domain.QueueTicketRepository;
import com.deeplusplus.nextna.queue.domain.TicketId;
import com.deeplusplus.nextna.queue.domain.TicketNotFoundException;
import com.deeplusplus.nextna.queue.domain.TicketNumber;
import com.deeplusplus.nextna.queue.domain.TicketState;
import com.deeplusplus.nextna.queue.api.TicketAlmostNextEvent;
import com.deeplusplus.nextna.queue.api.TicketCalledEvent;
import com.deeplusplus.nextna.queue.api.TicketCancelledEvent;
import com.deeplusplus.nextna.queue.api.TicketCompletedEvent;
import com.deeplusplus.nextna.queue.api.TicketCreatedEvent;
import com.deeplusplus.nextna.queue.api.TicketOnMyWayEvent;
import com.deeplusplus.nextna.servicecatalog.api.ServiceCatalogApi;
import com.deeplusplus.nextna.servicecatalog.api.ServiceDetailsDto;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class QueueService {

    private final QueueTicketRepository repository;
    private final ServiceCatalogApi serviceCatalogApi;
    private final ApplicationEventPublisher eventPublisher;

    public QueueService(
            QueueTicketRepository repository,
            ServiceCatalogApi serviceCatalogApi,
            ApplicationEventPublisher eventPublisher
    ) {
        this.repository = repository;
        this.serviceCatalogApi = serviceCatalogApi;
        this.eventPublisher = eventPublisher;
    }

    public QueueTicketResponseDto issueTicket(IssueTicketCommand command) {
        ServiceDetailsDto serviceDetails = serviceCatalogApi.findServiceById(command.serviceId())
                .filter(ServiceDetailsDto::active)
                .orElseThrow(() -> new IllegalArgumentException("Selected service is inactive or not found: " + command.serviceId()));

        int estimatedWait = calculateInitialWaitMinutes(command.manualWaitMinutesOverride(), serviceDetails.baselineDurationMinutes());
        int nextNumber = repository.findNextTicketNumber();

        QueueTicket ticket = QueueTicket.issue(
                TicketNumber.of(nextNumber),
                CustomerName.of(command.customerName()),
                serviceDetails.id(),
                serviceDetails.unitPrice(),
                estimatedWait
        );

        QueueTicket saved = repository.save(ticket);

        eventPublisher.publishEvent(new TicketCreatedEvent(
                saved.getId().value(),
                saved.getTicketNumber().value(),
                saved.getCustomerName().value(),
                saved.getServiceId(),
                saved.getCreatedAt()
        ));

        return QueueTicketResponseDto.from(saved);
    }

    public QueueTicketResponseDto callNextTicket() {
        List<QueueTicket> waitingTickets = repository.findByState(TicketState.WAITING);
        List<QueueTicket> almostNextTickets = repository.findByState(TicketState.ALMOST_NEXT);

        QueueTicket ticketToCall = !almostNextTickets.isEmpty()
                ? almostNextTickets.get(0)
                : (!waitingTickets.isEmpty() ? waitingTickets.get(0) : null);

        if (ticketToCall == null) {
            throw new InvalidTicketStateException("No waiting customers in the queue to call");
        }

        ticketToCall.call();
        QueueTicket called = repository.save(ticketToCall);

        stageNextWaitingTicket(called.getId().value());

        eventPublisher.publishEvent(new TicketCalledEvent(
                called.getId().value(),
                called.getTicketNumber().value(),
                called.getCustomerName().value(),
                called.getCalledAt()
        ));

        return QueueTicketResponseDto.from(called);
    }

    public QueueTicketResponseDto callTicketById(String id) {
        QueueTicket ticket = repository.findById(TicketId.of(id))
                .orElseThrow(() -> TicketNotFoundException.of(id));

        ticket.call();
        QueueTicket called = repository.save(ticket);

        stageNextWaitingTicket(called.getId().value());

        eventPublisher.publishEvent(new TicketCalledEvent(
                called.getId().value(),
                called.getTicketNumber().value(),
                called.getCustomerName().value(),
                called.getCalledAt()
        ));

        return QueueTicketResponseDto.from(called);
    }

    public QueueTicketResponseDto serveTicket(String id) {
        QueueTicket ticket = repository.findById(TicketId.of(id))
                .orElseThrow(() -> TicketNotFoundException.of(id));

        ticket.serve();
        QueueTicket saved = repository.save(ticket);
        return QueueTicketResponseDto.from(saved);
    }

    public QueueTicketResponseDto completeTicket(String id) {
        QueueTicket ticket = repository.findById(TicketId.of(id))
                .orElseThrow(() -> TicketNotFoundException.of(id));

        ticket.complete();
        QueueTicket completed = repository.save(ticket);

        eventPublisher.publishEvent(new TicketCompletedEvent(
                completed.getId().value(),
                completed.getTicketNumber().value(),
                completed.getCustomerName().value(),
                completed.getServiceId(),
                completed.getServicePrice(),
                completed.getCreatedAt(),
                completed.getCalledAt(),
                completed.getCompletedAt(),
                completed.calculateActualDurationMinutes()
        ));

        return QueueTicketResponseDto.from(completed);
    }

    public QueueTicketResponseDto cancelTicket(String id) {
        QueueTicket ticket = repository.findById(TicketId.of(id))
                .orElseThrow(() -> TicketNotFoundException.of(id));

        ticket.cancel();
        QueueTicket cancelled = repository.save(ticket);

        eventPublisher.publishEvent(new TicketCancelledEvent(
                cancelled.getId().value(),
                cancelled.getTicketNumber().value(),
                cancelled.getCompletedAt()
        ));

        return QueueTicketResponseDto.from(cancelled);
    }

    public QueueTicketResponseDto confirmOnMyWay(String id) {
        QueueTicket ticket = repository.findById(TicketId.of(id))
                .orElseThrow(() -> TicketNotFoundException.of(id));

        ticket.confirmOnMyWay();
        QueueTicket saved = repository.save(ticket);

        eventPublisher.publishEvent(new TicketOnMyWayEvent(
                saved.getId().value(),
                saved.getTicketNumber().value(),
                saved.getCreatedAt()
        ));

        return QueueTicketResponseDto.from(saved);
    }

    public QueueTicketResponseDto overrideWaitTime(String id, int minutes) {
        QueueTicket ticket = repository.findById(TicketId.of(id))
                .orElseThrow(() -> TicketNotFoundException.of(id));

        ticket.overrideEstimatedWait(minutes);
        QueueTicket saved = repository.save(ticket);
        return QueueTicketResponseDto.from(saved);
    }

    @Transactional(readOnly = true)
    public QueueTicketResponseDto getTicketById(String id) {
        return repository.findById(TicketId.of(id))
                .map(QueueTicketResponseDto::from)
                .orElseThrow(() -> TicketNotFoundException.of(id));
    }

    @Transactional(readOnly = true)
    public List<QueueTicketResponseDto> getActiveQueue() {
        return repository.findActiveQueue().stream()
                .map(QueueTicketResponseDto::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public QueueSummaryDto getQueueSummary() {
        List<QueueTicket> active = repository.findActiveQueue();

        Optional<QueueTicket> nowServing = active.stream()
                .filter(t -> t.getState() == TicketState.NOW_SERVING)
                .findFirst();

        int waitingCount = (int) active.stream()
                .filter(t -> t.getState() == TicketState.WAITING || t.getState() == TicketState.ALMOST_NEXT)
                .count();

        int servingCount = nowServing.isPresent() ? 1 : 0;

        return new QueueSummaryDto(
                active.size(),
                waitingCount,
                servingCount,
                nowServing.map(QueueTicketResponseDto::from).orElse(null),
                active.stream().map(QueueTicketResponseDto::from).toList()
        );
    }

    private int calculateInitialWaitMinutes(Integer manualOverride, int baselineMinutes) {
        if (manualOverride != null && manualOverride >= 0) {
            return manualOverride;
        }

        List<QueueTicket> active = repository.findActiveQueue();
        int waitingCount = (int) active.stream()
                .filter(t -> t.getState() == TicketState.WAITING || t.getState() == TicketState.ALMOST_NEXT)
                .count();

        return waitingCount * baselineMinutes;
    }

    private void stageNextWaitingTicket(String currentCalledId) {
        List<QueueTicket> waiting = repository.findByState(TicketState.WAITING);
        for (QueueTicket ticket : waiting) {
            if (!ticket.getId().value().equals(currentCalledId) && ticket.getState() == TicketState.WAITING) {
                ticket.stageAlmostNext();
                QueueTicket saved = repository.save(ticket);
                eventPublisher.publishEvent(new TicketAlmostNextEvent(
                        saved.getId().value(),
                        saved.getTicketNumber().value(),
                        saved.getCustomerName().value(),
                        Instant.now()
                ));
                break;
            }
        }
    }
}

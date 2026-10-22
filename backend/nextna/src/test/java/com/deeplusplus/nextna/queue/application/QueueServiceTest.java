package com.deeplusplus.nextna.queue.application;

import com.deeplusplus.nextna.queue.domain.CustomerName;
import com.deeplusplus.nextna.queue.domain.QueueTicket;
import com.deeplusplus.nextna.queue.domain.QueueTicketRepository;
import com.deeplusplus.nextna.queue.domain.TicketId;
import com.deeplusplus.nextna.queue.domain.TicketNumber;
import com.deeplusplus.nextna.queue.domain.TicketState;
import com.deeplusplus.nextna.queue.domain.events.TicketCalledEvent;
import com.deeplusplus.nextna.queue.domain.events.TicketCompletedEvent;
import com.deeplusplus.nextna.queue.domain.events.TicketCreatedEvent;
import com.deeplusplus.nextna.servicecatalog.api.ServiceCatalogApi;
import com.deeplusplus.nextna.servicecatalog.api.ServiceDetailsDto;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class QueueServiceTest {

    @Mock
    private QueueTicketRepository repository;

    @Mock
    private ServiceCatalogApi serviceCatalogApi;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    private QueueService queueService;

    @BeforeEach
    void setUp() {
        queueService = new QueueService(repository, serviceCatalogApi, eventPublisher);
    }

    @Test
    void shouldIssueTicketSuccessfully() {
        ServiceDetailsDto serviceDto = new ServiceDetailsDto(
                "srv-haircut",
                "Classic Haircut",
                "BARBERSHOP",
                new BigDecimal("150.00"),
                30,
                true
        );

        when(serviceCatalogApi.findServiceById("srv-haircut")).thenReturn(Optional.of(serviceDto));
        when(repository.findActiveQueue()).thenReturn(List.of());
        when(repository.findNextTicketNumber()).thenReturn(1);
        when(repository.save(any(QueueTicket.class))).thenAnswer(invocation -> invocation.getArgument(0));

        IssueTicketCommand command = new IssueTicketCommand("Juan Cruz", "srv-haircut", null);
        QueueTicketResponseDto response = queueService.issueTicket(command);

        assertThat(response).isNotNull();
        assertThat(response.ticketNumber()).isEqualTo(1);
        assertThat(response.customerName()).isEqualTo("Juan Cruz");
        assertThat(response.serviceId()).isEqualTo("srv-haircut");
        assertThat(response.state()).isEqualTo("WAITING");

        ArgumentCaptor<TicketCreatedEvent> eventCaptor = ArgumentCaptor.forClass(TicketCreatedEvent.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());
        assertThat(eventCaptor.getValue().ticketNumber()).isEqualTo(1);
    }

    @Test
    void shouldFailWhenSelectedServiceIsInactiveOrMissing() {
        when(serviceCatalogApi.findServiceById("srv-none")).thenReturn(Optional.empty());

        IssueTicketCommand command = new IssueTicketCommand("Juan", "srv-none", null);

        assertThatThrownBy(() -> queueService.issueTicket(command))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void shouldCallNextWaitingTicketAndPromoteFollowup() {
        QueueTicket ticket1 = QueueTicket.issue(TicketNumber.of(1), CustomerName.of("Alice"), "srv-1", BigDecimal.TEN, 10);
        QueueTicket ticket2 = QueueTicket.issue(TicketNumber.of(2), CustomerName.of("Bob"), "srv-1", BigDecimal.TEN, 20);

        when(repository.findByState(TicketState.ALMOST_NEXT)).thenReturn(List.of());
        when(repository.findByState(TicketState.WAITING)).thenReturn(List.of(ticket1, ticket2));
        when(repository.save(any(QueueTicket.class))).thenAnswer(invocation -> invocation.getArgument(0));

        QueueTicketResponseDto response = queueService.callNextTicket();

        assertThat(response.state()).isEqualTo("NOW_SERVING");
        assertThat(ticket2.getState()).isEqualTo(TicketState.ALMOST_NEXT);

        verify(eventPublisher).publishEvent(any(TicketCalledEvent.class));
    }

    @Test
    void shouldCompleteTicketAndPublishEvent() {
        QueueTicket ticket = QueueTicket.issue(TicketNumber.of(1), CustomerName.of("Alice"), "srv-1", BigDecimal.TEN, 10);
        ticket.call();

        when(repository.findById(TicketId.of(ticket.getId().value()))).thenReturn(Optional.of(ticket));
        when(repository.save(any(QueueTicket.class))).thenAnswer(invocation -> invocation.getArgument(0));

        QueueTicketResponseDto response = queueService.completeTicket(ticket.getId().value());

        assertThat(response.state()).isEqualTo("COMPLETED");
        verify(eventPublisher).publishEvent(any(TicketCompletedEvent.class));
    }
}

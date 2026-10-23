package com.deeplusplus.nextna.notification.application;

import com.deeplusplus.nextna.notification.domain.NotificationConnection;
import com.deeplusplus.nextna.notification.domain.NotificationConnectionRepository;
import com.deeplusplus.nextna.queue.api.QueueApi;
import com.deeplusplus.nextna.queue.api.QueueTicketSummaryDto;
import com.deeplusplus.nextna.queue.api.TicketAlmostNextEvent;
import com.deeplusplus.nextna.queue.api.TicketCalledEvent;
import com.deeplusplus.nextna.queue.api.TicketCompletedEvent;
import com.deeplusplus.nextna.queue.api.TicketCreatedEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class NotificationServiceTest {

    private NotificationConnectionRepository connectionRepository;
    private QueueApi queueApi;
    private NotificationService notificationService;

    @BeforeEach
    void setUp() {
        connectionRepository = mock(NotificationConnectionRepository.class);
        queueApi = mock(QueueApi.class);
        notificationService = new NotificationService(connectionRepository, queueApi);
    }

    @Test
    void shouldSubscribeToBuzzerAndRegisterConnection() {
        QueueTicketSummaryDto ticket = new QueueTicketSummaryDto(
                "t-1",
                10,
                "Pedro",
                "srv-1",
                new BigDecimal("200.00"),
                "WAITING",
                20,
                false,
                Instant.now(),
                null,
                null
        );

        when(queueApi.findTicketById("t-1")).thenReturn(Optional.of(ticket));
        when(queueApi.getActiveTickets()).thenReturn(List.of(ticket));

        SseEmitter emitter = notificationService.subscribeBuzzer("t-1");

        assertNotNull(emitter);
        verify(connectionRepository).registerBuzzerConnection(eq("t-1"), any(NotificationConnection.class));
    }

    @Test
    void shouldSubscribeToDisplayBoard() {
        when(queueApi.getActiveTickets()).thenReturn(List.of());

        SseEmitter emitter = notificationService.subscribeDisplayBoard();

        assertNotNull(emitter);
        verify(connectionRepository).registerDisplayConnection(any(NotificationConnection.class));
    }

    @Test
    void shouldDispatchAlmostNextEventToBuzzer() {
        NotificationConnection connection = mock(NotificationConnection.class);
        when(connectionRepository.findBuzzerConnections("t-1")).thenReturn(List.of(connection));
        when(connectionRepository.findDisplayConnections()).thenReturn(List.of());
        when(queueApi.getActiveTickets()).thenReturn(List.of());

        notificationService.onTicketAlmostNext(new TicketAlmostNextEvent(
                "t-1",
                10,
                "Pedro",
                Instant.now()
        ));

        ArgumentCaptor<Object> captor = ArgumentCaptor.forClass(Object.class);
        verify(connection).send(eq("buzzer-almost-next"), captor.capture());
        BuzzerNotificationDto dto = (BuzzerNotificationDto) captor.getValue();
        assertEquals("ALMOST_NEXT", dto.status());
    }

    @Test
    void shouldDispatchCalledEventToBuzzer() {
        NotificationConnection connection = mock(NotificationConnection.class);
        when(connectionRepository.findBuzzerConnections("t-1")).thenReturn(List.of(connection));
        when(connectionRepository.findDisplayConnections()).thenReturn(List.of());
        when(queueApi.getActiveTickets()).thenReturn(List.of());

        notificationService.onTicketCalled(new TicketCalledEvent(
                "t-1",
                10,
                "Pedro",
                Instant.now()
        ));

        ArgumentCaptor<Object> captor = ArgumentCaptor.forClass(Object.class);
        verify(connection).send(eq("buzzer-now-serving"), captor.capture());
        BuzzerNotificationDto dto = (BuzzerNotificationDto) captor.getValue();
        assertEquals("NOW_SERVING", dto.status());
    }

    @Test
    void shouldDispatchCompletedEventAndCloseConnection() {
        NotificationConnection connection = mock(NotificationConnection.class);
        when(connection.connectionId()).thenReturn("conn-1");
        when(connectionRepository.findBuzzerConnections("t-1")).thenReturn(List.of(connection));
        when(connectionRepository.findDisplayConnections()).thenReturn(List.of());
        when(queueApi.getActiveTickets()).thenReturn(List.of());

        notificationService.onTicketCompleted(new TicketCompletedEvent(
                "t-1",
                10,
                "Pedro",
                "srv-1",
                new BigDecimal("200.00"),
                Instant.now().minusSeconds(1200),
                Instant.now().minusSeconds(600),
                Instant.now(),
                10
        ));

        verify(connection).send(eq("buzzer-completed"), any(BuzzerNotificationDto.class));
        verify(connection).complete();
        verify(connectionRepository).removeBuzzerConnection("t-1", "conn-1");
    }
}

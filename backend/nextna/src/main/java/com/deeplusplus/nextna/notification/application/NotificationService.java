package com.deeplusplus.nextna.notification.application;

import com.deeplusplus.nextna.notification.domain.BuzzerAlertStatus;
import com.deeplusplus.nextna.notification.domain.BuzzerNotification;
import com.deeplusplus.nextna.notification.domain.DisplayBoardUpdate;
import com.deeplusplus.nextna.notification.domain.NotificationConnection;
import com.deeplusplus.nextna.notification.domain.NotificationConnectionRepository;
import com.deeplusplus.nextna.notification.infrastructure.SpringSseNotificationConnection;
import com.deeplusplus.nextna.queue.api.QueueApi;
import com.deeplusplus.nextna.queue.api.QueueTicketSummaryDto;
import com.deeplusplus.nextna.queue.api.TicketAlmostNextEvent;
import com.deeplusplus.nextna.queue.api.TicketCalledEvent;
import com.deeplusplus.nextna.queue.api.TicketCancelledEvent;
import com.deeplusplus.nextna.queue.api.TicketCompletedEvent;
import com.deeplusplus.nextna.queue.api.TicketCreatedEvent;
import com.deeplusplus.nextna.queue.api.TicketOnMyWayEvent;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
public class NotificationService {

    private static final long DEFAULT_TIMEOUT_MS = 1_800_000L;

    private final NotificationConnectionRepository connectionRepository;
    private final QueueApi queueApi;

    public NotificationService(
            NotificationConnectionRepository connectionRepository,
            QueueApi queueApi
    ) {
        this.connectionRepository = connectionRepository;
        this.queueApi = queueApi;
    }

    public SseEmitter subscribeBuzzer(String ticketId) {
        QueueTicketSummaryDto ticket = queueApi.findTicketById(ticketId)
                .orElseThrow(() -> new IllegalArgumentException("Ticket not found for buzzer subscription: " + ticketId));

        SseEmitter emitter = new SseEmitter(DEFAULT_TIMEOUT_MS);
        SpringSseNotificationConnection connection = new SpringSseNotificationConnection(emitter);
        connectionRepository.registerBuzzerConnection(ticketId, connection);

        emitter.onCompletion(() -> connectionRepository.removeBuzzerConnection(ticketId, connection.connectionId()));
        emitter.onTimeout(() -> connectionRepository.removeBuzzerConnection(ticketId, connection.connectionId()));
        emitter.onError(e -> connectionRepository.removeBuzzerConnection(ticketId, connection.connectionId()));

        BuzzerNotification initialNotification = buildBuzzerNotification(ticket);
        connection.send("buzzer-status", BuzzerNotificationDto.from(initialNotification));

        return emitter;
    }

    public SseEmitter subscribeDisplayBoard() {
        SseEmitter emitter = new SseEmitter(DEFAULT_TIMEOUT_MS);
        SpringSseNotificationConnection connection = new SpringSseNotificationConnection(emitter);
        connectionRepository.registerDisplayConnection(connection);

        emitter.onCompletion(() -> connectionRepository.removeDisplayConnection(connection.connectionId()));
        emitter.onTimeout(() -> connectionRepository.removeDisplayConnection(connection.connectionId()));
        emitter.onError(e -> connectionRepository.removeDisplayConnection(connection.connectionId()));

        DisplayBoardUpdate snapshot = buildCurrentDisplaySnapshot("DISPLAY_CONNECTED", "Connected to live display stream");
        connection.send("display-refresh", DisplayBoardDto.from(snapshot));

        return emitter;
    }

    public void onTicketCreated(TicketCreatedEvent event) {
        DisplayBoardUpdate update = buildCurrentDisplaySnapshot(
                "TICKET_CREATED",
                "New ticket #" + event.ticketNumber() + " issued for " + event.customerName()
        );
        broadcastDisplay(update);
        refreshWaitingBuzzerPositions();
    }

    public void onTicketAlmostNext(TicketAlmostNextEvent event) {
        BuzzerNotification notification = new BuzzerNotification(
                event.ticketId(),
                event.ticketNumber(),
                event.customerName(),
                BuzzerAlertStatus.ALMOST_NEXT,
                1,
                10,
                false,
                "Almost your turn! Please start heading back to the shop.",
                event.stagedAt()
        );
        dispatchToBuzzer(event.ticketId(), "buzzer-almost-next", BuzzerNotificationDto.from(notification));

        DisplayBoardUpdate update = buildCurrentDisplaySnapshot(
                "TICKET_ALMOST_NEXT",
                "Ticket #" + event.ticketNumber() + " is almost next"
        );
        broadcastDisplay(update);
    }

    public void onTicketCalled(TicketCalledEvent event) {
        BuzzerNotification notification = new BuzzerNotification(
                event.ticketId(),
                event.ticketNumber(),
                event.customerName(),
                BuzzerAlertStatus.NOW_SERVING,
                0,
                0,
                false,
                "Your turn now! Please proceed to the service counter.",
                event.calledAt()
        );
        dispatchToBuzzer(event.ticketId(), "buzzer-now-serving", BuzzerNotificationDto.from(notification));

        DisplayBoardUpdate update = buildCurrentDisplaySnapshot(
                "TICKET_CALLED",
                "Calling ticket #" + event.ticketNumber() + " - " + event.customerName()
        );
        broadcastDisplay(update);
        refreshWaitingBuzzerPositions();
    }

    public void onTicketCompleted(TicketCompletedEvent event) {
        BuzzerNotification notification = new BuzzerNotification(
                event.ticketId(),
                event.ticketNumber(),
                event.customerName(),
                BuzzerAlertStatus.COMPLETED,
                0,
                0,
                false,
                "Service completed. Thank you for visiting!",
                event.completedAt()
        );
        dispatchToBuzzer(event.ticketId(), "buzzer-completed", BuzzerNotificationDto.from(notification));
        closeBuzzerConnections(event.ticketId());

        DisplayBoardUpdate update = buildCurrentDisplaySnapshot(
                "TICKET_COMPLETED",
                "Ticket #" + event.ticketNumber() + " completed"
        );
        broadcastDisplay(update);
        refreshWaitingBuzzerPositions();
    }

    public void onTicketCancelled(TicketCancelledEvent event) {
        BuzzerNotification notification = new BuzzerNotification(
                event.ticketId(),
                event.ticketNumber(),
                "",
                BuzzerAlertStatus.CANCELLED,
                0,
                0,
                false,
                "This ticket has been cancelled.",
                event.cancelledAt()
        );
        dispatchToBuzzer(event.ticketId(), "buzzer-cancelled", BuzzerNotificationDto.from(notification));
        closeBuzzerConnections(event.ticketId());

        DisplayBoardUpdate update = buildCurrentDisplaySnapshot(
                "TICKET_CANCELLED",
                "Ticket #" + event.ticketNumber() + " cancelled"
        );
        broadcastDisplay(update);
        refreshWaitingBuzzerPositions();
    }

    public void onTicketOnMyWay(TicketOnMyWayEvent event) {
        queueApi.findTicketById(event.ticketId()).ifPresent(ticket -> {
            BuzzerNotification notification = buildBuzzerNotification(ticket);
            notification.confirmOnMyWay();
            dispatchToBuzzer(event.ticketId(), "buzzer-on-my-way-ack", BuzzerNotificationDto.from(notification));
        });

        DisplayBoardUpdate update = buildCurrentDisplaySnapshot(
                "TICKET_ON_MY_WAY",
                "Customer for ticket #" + event.ticketNumber() + " is on their way!"
        );
        broadcastDisplay(update);
    }

    private void dispatchToBuzzer(String ticketId, String eventName, Object data) {
        List<NotificationConnection> connections = connectionRepository.findBuzzerConnections(ticketId);
        for (NotificationConnection conn : connections) {
            conn.send(eventName, data);
        }
    }

    private void closeBuzzerConnections(String ticketId) {
        List<NotificationConnection> connections = connectionRepository.findBuzzerConnections(ticketId);
        for (NotificationConnection conn : connections) {
            conn.complete();
            connectionRepository.removeBuzzerConnection(ticketId, conn.connectionId());
        }
    }

    private void broadcastDisplay(DisplayBoardUpdate update) {
        List<NotificationConnection> displayConnections = connectionRepository.findDisplayConnections();
        DisplayBoardDto dto = DisplayBoardDto.from(update);
        for (NotificationConnection conn : displayConnections) {
            conn.send("display-update", dto);
        }
    }

    private void refreshWaitingBuzzerPositions() {
        List<QueueTicketSummaryDto> activeTickets = queueApi.getActiveTickets();
        for (QueueTicketSummaryDto ticket : activeTickets) {
            List<NotificationConnection> connections = connectionRepository.findBuzzerConnections(ticket.ticketId());
            if (!connections.isEmpty()) {
                BuzzerNotification updated = buildBuzzerNotification(ticket);
                BuzzerNotificationDto dto = BuzzerNotificationDto.from(updated);
                for (NotificationConnection conn : connections) {
                    conn.send("buzzer-position-update", dto);
                }
            }
        }
    }

    private BuzzerNotification buildBuzzerNotification(QueueTicketSummaryDto ticket) {
        List<QueueTicketSummaryDto> activeTickets = queueApi.getActiveTickets();
        int peopleAhead = 0;
        for (QueueTicketSummaryDto other : activeTickets) {
            if (other.ticketNumber() < ticket.ticketNumber() && ("WAITING".equals(other.state()) || "ALMOST_NEXT".equals(other.state()))) {
                peopleAhead++;
            }
        }

        BuzzerAlertStatus status = mapStatus(ticket.state());
        String alertMessage = switch (status) {
            case IN_LINE -> "You are in line. Please keep this virtual buzzer active.";
            case ALMOST_NEXT -> "Almost your turn! Please start heading back to the shop.";
            case NOW_SERVING -> "Your turn now! Please proceed to the service counter.";
            case COMPLETED -> "Service completed. Thank you for visiting!";
            case CANCELLED -> "This ticket has been cancelled.";
        };

        return new BuzzerNotification(
                ticket.ticketId(),
                ticket.ticketNumber(),
                ticket.customerName(),
                status,
                peopleAhead,
                ticket.estimatedWaitMinutes(),
                ticket.onMyWayConfirmed(),
                alertMessage,
                Instant.now()
        );
    }

    private DisplayBoardUpdate buildCurrentDisplaySnapshot(String eventType, String alertMessage) {
        List<QueueTicketSummaryDto> activeTickets = queueApi.getActiveTickets();

        Optional<QueueTicketSummaryDto> nowServing = activeTickets.stream()
                .filter(t -> "NOW_SERVING".equals(t.state()))
                .findFirst();

        Optional<QueueTicketSummaryDto> almostNext = activeTickets.stream()
                .filter(t -> "ALMOST_NEXT".equals(t.state()))
                .findFirst();

        List<Integer> waitingNumbers = activeTickets.stream()
                .filter(t -> "WAITING".equals(t.state()))
                .map(QueueTicketSummaryDto::ticketNumber)
                .toList();

        int totalWaitingCount = (int) activeTickets.stream()
                .filter(t -> "WAITING".equals(t.state()) || "ALMOST_NEXT".equals(t.state()))
                .count();

        return new DisplayBoardUpdate(
                eventType,
                nowServing.map(QueueTicketSummaryDto::ticketNumber).orElse(null),
                nowServing.map(QueueTicketSummaryDto::customerName).orElse(null),
                almostNext.map(QueueTicketSummaryDto::ticketNumber).orElse(null),
                almostNext.map(QueueTicketSummaryDto::customerName).orElse(null),
                totalWaitingCount,
                waitingNumbers,
                alertMessage,
                Instant.now()
        );
    }

    private BuzzerAlertStatus mapStatus(String state) {
        return switch (state) {
            case "ALMOST_NEXT" -> BuzzerAlertStatus.ALMOST_NEXT;
            case "NOW_SERVING" -> BuzzerAlertStatus.NOW_SERVING;
            case "COMPLETED" -> BuzzerAlertStatus.COMPLETED;
            case "CANCELLED" -> BuzzerAlertStatus.CANCELLED;
            default -> BuzzerAlertStatus.IN_LINE;
        };
    }
}

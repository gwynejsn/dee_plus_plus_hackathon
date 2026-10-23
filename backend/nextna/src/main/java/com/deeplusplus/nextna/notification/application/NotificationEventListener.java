package com.deeplusplus.nextna.notification.application;

import com.deeplusplus.nextna.queue.api.TicketAlmostNextEvent;
import com.deeplusplus.nextna.queue.api.TicketCalledEvent;
import com.deeplusplus.nextna.queue.api.TicketCancelledEvent;
import com.deeplusplus.nextna.queue.api.TicketCompletedEvent;
import com.deeplusplus.nextna.queue.api.TicketCreatedEvent;
import com.deeplusplus.nextna.queue.api.TicketOnMyWayEvent;
import org.springframework.modulith.events.ApplicationModuleListener;
import org.springframework.stereotype.Component;

@Component
public class NotificationEventListener {

    private final NotificationService notificationService;

    public NotificationEventListener(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @ApplicationModuleListener
    public void onTicketCreated(TicketCreatedEvent event) {
        notificationService.onTicketCreated(event);
    }

    @ApplicationModuleListener
    public void onTicketAlmostNext(TicketAlmostNextEvent event) {
        notificationService.onTicketAlmostNext(event);
    }

    @ApplicationModuleListener
    public void onTicketCalled(TicketCalledEvent event) {
        notificationService.onTicketCalled(event);
    }

    @ApplicationModuleListener
    public void onTicketCompleted(TicketCompletedEvent event) {
        notificationService.onTicketCompleted(event);
    }

    @ApplicationModuleListener
    public void onTicketCancelled(TicketCancelledEvent event) {
        notificationService.onTicketCancelled(event);
    }

    @ApplicationModuleListener
    public void onTicketOnMyWay(TicketOnMyWayEvent event) {
        notificationService.onTicketOnMyWay(event);
    }
}

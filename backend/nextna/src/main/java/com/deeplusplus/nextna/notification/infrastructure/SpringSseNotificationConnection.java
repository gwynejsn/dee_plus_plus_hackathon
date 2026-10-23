package com.deeplusplus.nextna.notification.infrastructure;

import com.deeplusplus.nextna.notification.domain.NotificationConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicBoolean;

public class SpringSseNotificationConnection implements NotificationConnection {

    private static final Logger log = LoggerFactory.getLogger(SpringSseNotificationConnection.class);

    private final String connectionId;
    private final SseEmitter emitter;
    private final AtomicBoolean alive;

    public SpringSseNotificationConnection(SseEmitter emitter) {
        this.connectionId = UUID.randomUUID().toString();
        this.emitter = emitter;
        this.alive = new AtomicBoolean(true);

        this.emitter.onCompletion(() -> alive.set(false));
        this.emitter.onTimeout(() -> alive.set(false));
        this.emitter.onError(e -> alive.set(false));
    }

    public SpringSseNotificationConnection(String connectionId, SseEmitter emitter) {
        this.connectionId = connectionId;
        this.emitter = emitter;
        this.alive = new AtomicBoolean(true);

        this.emitter.onCompletion(() -> alive.set(false));
        this.emitter.onTimeout(() -> alive.set(false));
        this.emitter.onError(e -> alive.set(false));
    }

    @Override
    public String connectionId() {
        return connectionId;
    }

    @Override
    public void send(String eventName, Object data) {
        if (!alive.get()) {
            return;
        }
        try {
            SseEmitter.SseEventBuilder event = SseEmitter.event()
                    .name(eventName)
                    .data(data);
            emitter.send(event);
        } catch (IOException | IllegalStateException e) {
            alive.set(false);
            log.warn("Failed to dispatch SSE event {} to connection {}: {}", eventName, connectionId, e.getMessage());
        }
    }

    @Override
    public void complete() {
        if (alive.compareAndSet(true, false)) {
            try {
                emitter.complete();
            } catch (Exception ignored) {
            }
        }
    }

    @Override
    public void completeWithError(Throwable throwable) {
        if (alive.compareAndSet(true, false)) {
            try {
                emitter.completeWithError(throwable);
            } catch (Exception ignored) {
            }
        }
    }

    @Override
    public boolean isAlive() {
        return alive.get();
    }

    public SseEmitter getEmitter() {
        return emitter;
    }
}

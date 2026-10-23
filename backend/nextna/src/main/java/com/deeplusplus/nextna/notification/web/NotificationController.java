package com.deeplusplus.nextna.notification.web;

import com.deeplusplus.nextna.notification.api.NotificationApi;
import com.deeplusplus.nextna.notification.application.NotificationService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/notifications")
public class NotificationController {

    private final NotificationService notificationService;
    private final NotificationApi notificationApi;

    public NotificationController(
            NotificationService notificationService,
            NotificationApi notificationApi
    ) {
        this.notificationService = notificationService;
        this.notificationApi = notificationApi;
    }

    @GetMapping(value = "/buzzer/{ticketId}/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamBuzzerUpdates(@PathVariable String ticketId) {
        return notificationService.subscribeBuzzer(ticketId);
    }

    @GetMapping(value = "/display/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamDisplayBoardUpdates() {
        return notificationService.subscribeDisplayBoard();
    }

    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getStreamingStatus() {
        return ResponseEntity.ok(Map.of(
                "activeBuzzerStreams", notificationApi.getActiveBuzzerConnectionCount(),
                "activeDisplayStreams", notificationApi.getActiveDisplayConnectionCount()
        ));
    }
}

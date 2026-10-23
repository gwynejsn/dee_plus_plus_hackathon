package com.deeplusplus.nextna.notification.web;

import com.deeplusplus.nextna.notification.api.NotificationApi;
import com.deeplusplus.nextna.notification.application.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ExtendWith(MockitoExtension.class)
class NotificationControllerTest {

    private MockMvc mockMvc;

    @Mock
    private NotificationService notificationService;

    @Mock
    private NotificationApi notificationApi;

    @BeforeEach
    void setUp() {
        NotificationController controller = new NotificationController(notificationService, notificationApi);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new NotificationExceptionHandler())
                .build();
    }

    @Test
    void shouldSubscribeToBuzzerStream() throws Exception {
        when(notificationService.subscribeBuzzer("t-1")).thenReturn(new SseEmitter());

        mockMvc.perform(get("/api/v1/notifications/buzzer/t-1/stream")
                        .accept(MediaType.TEXT_EVENT_STREAM_VALUE))
                .andExpect(status().isOk());
    }

    @Test
    void shouldSubscribeToDisplayStream() throws Exception {
        when(notificationService.subscribeDisplayBoard()).thenReturn(new SseEmitter());

        mockMvc.perform(get("/api/v1/notifications/display/stream")
                        .accept(MediaType.TEXT_EVENT_STREAM_VALUE))
                .andExpect(status().isOk());
    }

    @Test
    void shouldReturnStreamingStatus() throws Exception {
        when(notificationApi.getActiveBuzzerConnectionCount()).thenReturn(3);
        when(notificationApi.getActiveDisplayConnectionCount()).thenReturn(1);

        mockMvc.perform(get("/api/v1/notifications/status")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.activeBuzzerStreams").value(3))
                .andExpect(jsonPath("$.activeDisplayStreams").value(1));
    }
}

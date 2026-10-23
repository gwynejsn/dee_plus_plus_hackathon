package com.deeplusplus.nextna.queue.web;

import com.deeplusplus.nextna.queue.application.IssueTicketCommand;
import com.deeplusplus.nextna.queue.application.QueueService;
import com.deeplusplus.nextna.queue.application.QueueSummaryDto;
import com.deeplusplus.nextna.queue.application.QueueTicketResponseDto;
import com.deeplusplus.nextna.queue.domain.InvalidTicketStateException;
import com.deeplusplus.nextna.queue.domain.TicketNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ExtendWith(MockitoExtension.class)
class QueueControllerTest {

    private MockMvc mockMvc;

    @Mock
    private QueueService queueService;

    @BeforeEach
    void setUp() {
        QueueController controller = new QueueController(queueService);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new QueueExceptionHandler())
                .build();
    }

    @Test
    void shouldIssueTicket() throws Exception {
        QueueTicketResponseDto dto = new QueueTicketResponseDto(
                "tkt-1",
                1,
                "Juan",
                "srv-1",
                new BigDecimal("150.00"),
                "WAITING",
                15,
                false,
                false,
                Instant.now(),
                null,
                null
        );

        when(queueService.issueTicket(any(IssueTicketCommand.class))).thenReturn(dto);

        String payload = """
                {
                    "customerName": "Juan",
                    "serviceId": "srv-1"
                }
                """;

        mockMvc.perform(post("/api/v1/queue/tickets")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value("tkt-1"))
                .andExpect(jsonPath("$.ticketNumber").value(1))
                .andExpect(jsonPath("$.customerName").value("Juan"))
                .andExpect(jsonPath("$.state").value("WAITING"));
    }

    @Test
    void shouldCallNextTicket() throws Exception {
        QueueTicketResponseDto dto = new QueueTicketResponseDto(
                "tkt-1",
                1,
                "Juan",
                "srv-1",
                new BigDecimal("150.00"),
                "NOW_SERVING",
                0,
                false,
                false,
                Instant.now(),
                Instant.now(),
                null
        );

        when(queueService.callNextTicket()).thenReturn(dto);

        mockMvc.perform(post("/api/v1/queue/tickets/call-next"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.state").value("NOW_SERVING"));
    }

    @Test
    void shouldReturn409WhenNoTicketToCall() throws Exception {
        when(queueService.callNextTicket())
                .thenThrow(new InvalidTicketStateException("No waiting customers in the queue to call"));

        mockMvc.perform(post("/api/v1/queue/tickets/call-next"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409))
                .andExpect(jsonPath("$.message").value("No waiting customers in the queue to call"));
    }

    @Test
    void shouldReturn404WhenTicketNotFound() throws Exception {
        when(queueService.getTicketById("tkt-none"))
                .thenThrow(new TicketNotFoundException("Queue ticket with id 'tkt-none' was not found"));

        mockMvc.perform(get("/api/v1/queue/tickets/tkt-none"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    @Test
    void shouldConfirmOnMyWay() throws Exception {
        QueueTicketResponseDto dto = new QueueTicketResponseDto(
                "tkt-1",
                1,
                "Juan",
                "srv-1",
                new BigDecimal("150.00"),
                "ALMOST_NEXT",
                5,
                false,
                true,
                Instant.now(),
                null,
                null
        );

        when(queueService.confirmOnMyWay("tkt-1")).thenReturn(dto);

        mockMvc.perform(patch("/api/v1/queue/tickets/tkt-1/on-my-way"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.onMyWayConfirmed").value(true));
    }

    @Test
    void shouldGetQueueSummary() throws Exception {
        QueueSummaryDto summary = new QueueSummaryDto(
                1,
                1,
                0,
                null,
                List.of()
        );

        when(queueService.getQueueSummary()).thenReturn(summary);

        mockMvc.perform(get("/api/v1/queue/summary"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalActive").value(1))
                .andExpect(jsonPath("$.waitingCount").value(1))
                .andExpect(jsonPath("$.servingCount").value(0));
    }
}

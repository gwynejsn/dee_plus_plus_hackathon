package com.deeplusplus.nextna.queue.web;

import com.deeplusplus.nextna.queue.application.QueueService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "2. Queue Operations", description = "Endpoints for ticketing, state transitions, calling, and 'On My Way' signals")
@RestController
@RequestMapping("/api/v1/queue")
public class QueueController {

    private final QueueService queueService;

    public QueueController(QueueService queueService) {
        this.queueService = queueService;
    }

    @Operation(summary = "Issue a new virtual queue ticket")
    @PostMapping("/tickets")
    @ResponseStatus(HttpStatus.CREATED)
    public QueueTicketResponse issueTicket(@Valid @RequestBody IssueTicketRequest request) {
        return QueueTicketResponse.from(queueService.issueTicket(request.toCommand()));
    }

    @Operation(summary = "Get list of all active tickets currently in the queue")
    @GetMapping("/tickets")
    public List<QueueTicketResponse> getActiveQueue() {
        return queueService.getActiveQueue().stream()
                .map(QueueTicketResponse::from)
                .toList();
    }

    @Operation(summary = "Get ticket details by ticket ID")
    @GetMapping("/tickets/{id}")
    public QueueTicketResponse getTicketById(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.getTicketById(id));
    }

    @Operation(summary = "Get current queue overview and summary metrics")
    @GetMapping("/summary")
    public QueueSummaryResponse getQueueSummary() {
        return QueueSummaryResponse.from(queueService.getQueueSummary());
    }

    @Operation(summary = "Call the next waiting customer in sequence")
    @PostMapping("/tickets/call-next")
    public QueueTicketResponse callNextTicket() {
        return QueueTicketResponse.from(queueService.callNextTicket());
    }

    @Operation(summary = "Call a specific ticket by ticket ID")
    @PatchMapping("/tickets/{id}/call")
    public QueueTicketResponse callTicketById(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.callTicketById(id));
    }

    @Operation(summary = "Commence service on a called ticket")
    @PatchMapping("/tickets/{id}/serve")
    public QueueTicketResponse serveTicket(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.serveTicket(id));
    }

    @Operation(summary = "Complete service for a ticket")
    @PatchMapping("/tickets/{id}/complete")
    public QueueTicketResponse completeTicket(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.completeTicket(id));
    }

    @Operation(summary = "Cancel a ticket")
    @PatchMapping("/tickets/{id}/cancel")
    public QueueTicketResponse cancelTicket(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.cancelTicket(id));
    }

    @Operation(summary = "Signal that customer is on their way (Papunta Na Ako)")
    @PatchMapping("/tickets/{id}/on-my-way")
    public QueueTicketResponse confirmOnMyWay(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.confirmOnMyWay(id));
    }

    @Operation(summary = "Manually override estimated wait time for a ticket")
    @PatchMapping("/tickets/{id}/override-wait")
    public QueueTicketResponse overrideWaitTime(
            @PathVariable String id,
            @Valid @RequestBody OverrideWaitTimeRequest request
    ) {
        return QueueTicketResponse.from(queueService.overrideWaitTime(id, request.estimatedWaitMinutes()));
    }
}

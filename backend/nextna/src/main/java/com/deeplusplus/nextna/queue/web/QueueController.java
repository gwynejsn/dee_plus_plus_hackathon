package com.deeplusplus.NextNa.queue.web;

import com.deeplusplus.NextNa.queue.application.QueueService;
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

@RestController
@RequestMapping("/api/v1/queue")
public class QueueController {

    private final QueueService queueService;

    public QueueController(QueueService queueService) {
        this.queueService = queueService;
    }

    @PostMapping("/tickets")
    @ResponseStatus(HttpStatus.CREATED)
    public QueueTicketResponse issueTicket(@Valid @RequestBody IssueTicketRequest request) {
        return QueueTicketResponse.from(queueService.issueTicket(request.toCommand()));
    }

    @GetMapping("/tickets")
    public List<QueueTicketResponse> getActiveQueue() {
        return queueService.getActiveQueue().stream()
                .map(QueueTicketResponse::from)
                .toList();
    }

    @GetMapping("/tickets/{id}")
    public QueueTicketResponse getTicketById(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.getTicketById(id));
    }

    @GetMapping("/summary")
    public QueueSummaryResponse getQueueSummary() {
        return QueueSummaryResponse.from(queueService.getQueueSummary());
    }

    @PostMapping("/tickets/call-next")
    public QueueTicketResponse callNextTicket() {
        return QueueTicketResponse.from(queueService.callNextTicket());
    }

    @PatchMapping("/tickets/{id}/call")
    public QueueTicketResponse callTicketById(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.callTicketById(id));
    }

    @PatchMapping("/tickets/{id}/serve")
    public QueueTicketResponse serveTicket(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.serveTicket(id));
    }

    @PatchMapping("/tickets/{id}/complete")
    public QueueTicketResponse completeTicket(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.completeTicket(id));
    }

    @PatchMapping("/tickets/{id}/cancel")
    public QueueTicketResponse cancelTicket(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.cancelTicket(id));
    }

    @PatchMapping("/tickets/{id}/on-my-way")
    public QueueTicketResponse confirmOnMyWay(@PathVariable String id) {
        return QueueTicketResponse.from(queueService.confirmOnMyWay(id));
    }

    @PatchMapping("/tickets/{id}/override-wait")
    public QueueTicketResponse overrideWaitTime(
            @PathVariable String id,
            @Valid @RequestBody OverrideWaitTimeRequest request
    ) {
        return QueueTicketResponse.from(queueService.overrideWaitTime(id, request.estimatedWaitMinutes()));
    }
}

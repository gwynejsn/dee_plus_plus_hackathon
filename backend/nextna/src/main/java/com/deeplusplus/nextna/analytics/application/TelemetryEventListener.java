package com.deeplusplus.nextna.analytics.application;

import com.deeplusplus.nextna.analytics.domain.TelemetryLog;
import com.deeplusplus.nextna.analytics.domain.TelemetryLogRepository;
import com.deeplusplus.nextna.queue.api.TicketCompletedEvent;
import com.deeplusplus.nextna.servicecatalog.api.ServiceCatalogApi;
import com.deeplusplus.nextna.servicecatalog.api.ServiceDetailsDto;
import org.springframework.modulith.events.ApplicationModuleListener;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class TelemetryEventListener {

    private final TelemetryLogRepository repository;
    private final ServiceCatalogApi serviceCatalogApi;

    public TelemetryEventListener(
            TelemetryLogRepository repository,
            ServiceCatalogApi serviceCatalogApi
    ) {
        this.repository = repository;
        this.serviceCatalogApi = serviceCatalogApi;
    }

    @ApplicationModuleListener
    public void onTicketCompleted(TicketCompletedEvent event) {
        String serviceName = serviceCatalogApi.findServiceById(event.serviceId())
                .map(ServiceDetailsDto::name)
                .orElse("Standard Service");

        int baselineDuration = serviceCatalogApi.findServiceById(event.serviceId())
                .map(ServiceDetailsDto::baselineDurationMinutes)
                .orElse(event.actualDurationMinutes());

        Instant intake = event.createdAt();
        Instant commenced = event.calledAt() != null ? event.calledAt() : intake;
        Instant fulfilled = event.completedAt() != null ? event.completedAt() : Instant.now();

        TelemetryLog log = TelemetryLog.record(
                event.ticketId(),
                event.ticketNumber(),
                event.customerName(),
                event.serviceId(),
                serviceName,
                event.servicePrice(),
                intake,
                commenced,
                fulfilled,
                event.actualDurationMinutes(),
                baselineDuration
        );

        repository.save(log);
    }
}

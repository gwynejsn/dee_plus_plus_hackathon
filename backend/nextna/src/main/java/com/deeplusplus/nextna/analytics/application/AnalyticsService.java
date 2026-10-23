package com.deeplusplus.nextna.analytics.application;

import com.deeplusplus.nextna.analytics.domain.AiPredictionRecommendation;
import com.deeplusplus.nextna.analytics.domain.DailyFinancialSummary;
import com.deeplusplus.nextna.analytics.domain.HistoricalDurationStat;
import com.deeplusplus.nextna.analytics.domain.TelemetryLogRepository;
import com.deeplusplus.nextna.analytics.infrastructure.AiWaitTimePredictor;
import com.deeplusplus.nextna.queue.api.QueueApi;
import com.deeplusplus.nextna.servicecatalog.api.ServiceCatalogApi;
import com.deeplusplus.nextna.servicecatalog.api.ServiceDetailsDto;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class AnalyticsService {

    private final TelemetryLogRepository repository;
    private final ServiceCatalogApi serviceCatalogApi;
    private final QueueApi queueApi;
    private final AiWaitTimePredictor aiWaitTimePredictor;

    public AnalyticsService(
            TelemetryLogRepository repository,
            ServiceCatalogApi serviceCatalogApi,
            QueueApi queueApi,
            AiWaitTimePredictor aiWaitTimePredictor
    ) {
        this.repository = repository;
        this.serviceCatalogApi = serviceCatalogApi;
        this.queueApi = queueApi;
        this.aiWaitTimePredictor = aiWaitTimePredictor;
    }

    public DashboardOverviewDto getDashboardOverview() {
        LocalDate today = LocalDate.now();
        List<DailyFinancialSummary> financials = repository.findDailyFinancialSummaries(today.minusDays(7), today);

        DailyFinancialSummary todaySummary = financials.stream()
                .filter(f -> f.reportDate().equals(today))
                .findFirst()
                .orElse(new DailyFinancialSummary(today, 0, BigDecimal.ZERO, 0.0, BigDecimal.ZERO));

        int activeQueueCount = queueApi.getActiveQueueCount();
        List<TelemetryLogDto> recentLogs = repository.findRecent(10).stream()
                .map(TelemetryLogDto::from)
                .toList();

        return new DashboardOverviewDto(
                todaySummary.totalServicesCompleted(),
                todaySummary.totalRevenuePhp(),
                todaySummary.averageServiceDurationMinutes(),
                activeQueueCount,
                financials,
                recentLogs
        );
    }

    public List<DailyFinancialSummary> getFinancialSummaries(LocalDate fromDate, LocalDate toDate) {
        LocalDate end = (toDate != null) ? toDate : LocalDate.now();
        LocalDate start = (fromDate != null) ? fromDate : end.minusDays(30);
        return repository.findDailyFinancialSummaries(start, end);
    }

    public List<HistoricalDurationStat> getHistoricalStats(String serviceId) {
        return repository.findHistoricalStatsByService(serviceId);
    }

    public AiPredictionDto getAiPrediction(String serviceId, Integer dayOfWeek, Integer hourOfDay) {
        ServiceDetailsDto service = serviceCatalogApi.findServiceById(serviceId)
                .orElseThrow(() -> new IllegalArgumentException("Service with id '" + serviceId + "' not found"));

        ZonedDateTime now = ZonedDateTime.now();
        int targetDay = (dayOfWeek != null && dayOfWeek >= 1 && dayOfWeek <= 7) ? dayOfWeek : now.getDayOfWeek().getValue();
        int targetHour = (hourOfDay != null && hourOfDay >= 0 && hourOfDay <= 23) ? hourOfDay : now.getHour();

        HistoricalDurationStat stat = repository.findHistoricalStatByServiceDayHour(serviceId, targetDay, targetHour)
                .orElse(new HistoricalDurationStat(
                        serviceId,
                        service.name(),
                        targetDay,
                        targetHour,
                        0,
                        service.baselineDurationMinutes(),
                        service.baselineDurationMinutes(),
                        service.baselineDurationMinutes()
                ));

        int waitingCount = queueApi.getActiveQueueCount();

        AiPredictionRecommendation recommendation = aiWaitTimePredictor.predict(
                service.name(),
                service.baselineDurationMinutes(),
                targetDay,
                targetHour,
                waitingCount,
                stat.averageDurationMinutes(),
                stat.totalSamples(),
                stat.minDurationMinutes(),
                stat.maxDurationMinutes()
        );

        return AiPredictionDto.from(serviceId, service.name(), recommendation);
    }
}

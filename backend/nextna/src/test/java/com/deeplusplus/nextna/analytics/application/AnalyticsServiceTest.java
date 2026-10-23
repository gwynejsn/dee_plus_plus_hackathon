package com.deeplusplus.nextna.analytics.application;

import com.deeplusplus.nextna.analytics.domain.AiPredictionRecommendation;
import com.deeplusplus.nextna.analytics.domain.DailyFinancialSummary;
import com.deeplusplus.nextna.analytics.domain.HistoricalDurationStat;
import com.deeplusplus.nextna.analytics.domain.TelemetryLogRepository;
import com.deeplusplus.nextna.analytics.infrastructure.AiWaitTimePredictor;
import com.deeplusplus.nextna.queue.api.QueueApi;
import com.deeplusplus.nextna.servicecatalog.api.ServiceCatalogApi;
import com.deeplusplus.nextna.servicecatalog.api.ServiceDetailsDto;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AnalyticsServiceTest {

    @Mock
    private TelemetryLogRepository repository;

    @Mock
    private ServiceCatalogApi serviceCatalogApi;

    @Mock
    private QueueApi queueApi;

    @Mock
    private AiWaitTimePredictor aiWaitTimePredictor;

    private AnalyticsService analyticsService;

    @BeforeEach
    void setUp() {
        analyticsService = new AnalyticsService(repository, serviceCatalogApi, queueApi, aiWaitTimePredictor);
    }

    @Test
    void shouldReturnDashboardOverview() {
        LocalDate today = LocalDate.now();
        DailyFinancialSummary summary = new DailyFinancialSummary(
                today,
                15,
                new BigDecimal("3500.00"),
                28.5,
                new BigDecimal("8.33")
        );

        when(repository.findDailyFinancialSummaries(today.minusDays(7), today)).thenReturn(List.of(summary));
        when(queueApi.getActiveQueueCount()).thenReturn(3);
        when(repository.findRecent(10)).thenReturn(List.of());

        DashboardOverviewDto overview = analyticsService.getDashboardOverview();

        assertThat(overview).isNotNull();
        assertThat(overview.totalCompletedToday()).isEqualTo(15);
        assertThat(overview.todayRevenuePhp()).isEqualByComparingTo("3500.00");
        assertThat(overview.activeQueueCount()).isEqualTo(3);
    }

    @Test
    void shouldGetAiPredictionForService() {
        ServiceDetailsDto service = new ServiceDetailsDto(
                "srv-haircut",
                "Fade Cut",
                "BARBERSHOP",
                new BigDecimal("200.00"),
                30,
                true
        );

        HistoricalDurationStat stat = new HistoricalDurationStat(
                "srv-haircut",
                "Fade Cut",
                5,
                18,
                12,
                38,
                25,
                48
        );

        AiPredictionRecommendation rec = new AiPredictionRecommendation(
                38,
                0.85,
                1.26,
                "Friday peak rush detected.",
                "Allocate extra 8m buffer.",
                "MEDIUM",
                Instant.now()
        );

        when(serviceCatalogApi.findServiceById("srv-haircut")).thenReturn(Optional.of(service));
        when(queueApi.getActiveQueueCount()).thenReturn(4);
        when(repository.findHistoricalStatByServiceDayHour("srv-haircut", 5, 18)).thenReturn(Optional.of(stat));
        when(aiWaitTimePredictor.predict(anyString(), anyInt(), anyInt(), anyInt(), anyInt(), anyInt(), anyLong(), anyInt(), anyInt()))
                .thenReturn(rec);

        AiPredictionDto prediction = analyticsService.getAiPrediction("srv-haircut", 5, 18);

        assertThat(prediction).isNotNull();
        assertThat(prediction.serviceId()).isEqualTo("srv-haircut");
        assertThat(prediction.predictedDurationMinutes()).isEqualTo(38);
        assertThat(prediction.bottleneckRisk()).isEqualTo("MEDIUM");
    }
}

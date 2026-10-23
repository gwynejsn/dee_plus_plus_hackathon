package com.deeplusplus.nextna.analytics.web;

import com.deeplusplus.nextna.analytics.application.AiPredictionDto;
import com.deeplusplus.nextna.analytics.application.AnalyticsService;
import com.deeplusplus.nextna.analytics.application.DashboardOverviewDto;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ExtendWith(MockitoExtension.class)
class AnalyticsControllerTest {

    private MockMvc mockMvc;

    @Mock
    private AnalyticsService analyticsService;

    @BeforeEach
    void setUp() {
        AnalyticsController controller = new AnalyticsController(analyticsService);
        mockMvc = MockMvcBuilders.standaloneSetup(controller)
                .setControllerAdvice(new AnalyticsExceptionHandler())
                .build();
    }

    @Test
    void shouldReturnDashboardOverview() throws Exception {
        DashboardOverviewDto dto = new DashboardOverviewDto(
                12,
                new BigDecimal("2800.00"),
                25.0,
                2,
                List.of(),
                List.of()
        );

        when(analyticsService.getDashboardOverview()).thenReturn(dto);

        mockMvc.perform(get("/api/v1/analytics/overview"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalCompletedToday").value(12))
                .andExpect(jsonPath("$.todayRevenuePhp").value(2800.00))
                .andExpect(jsonPath("$.activeQueueCount").value(2));
    }

    @Test
    void shouldReturnAiPrediction() throws Exception {
        AiPredictionDto prediction = new AiPredictionDto(
                "srv-fade",
                "Fade Cut",
                35,
                0.88,
                1.16,
                "Slight duration overrun on peak evening.",
                "Buffer with 5m interval.",
                "LOW",
                Instant.now()
        );

        when(analyticsService.getAiPrediction("srv-fade", 5, 18)).thenReturn(prediction);

        mockMvc.perform(get("/api/v1/analytics/ai-prediction")
                        .param("serviceId", "srv-fade")
                        .param("dayOfWeek", "5")
                        .param("hourOfDay", "18"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.serviceId").value("srv-fade"))
                .andExpect(jsonPath("$.predictedDurationMinutes").value(35))
                .andExpect(jsonPath("$.confidenceScore").value(0.88))
                .andExpect(jsonPath("$.bottleneckRisk").value("LOW"));
    }
}

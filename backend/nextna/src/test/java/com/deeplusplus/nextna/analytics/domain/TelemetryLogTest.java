package com.deeplusplus.nextna.analytics.domain;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

import static org.assertj.core.api.Assertions.assertThat;

class TelemetryLogTest {

    @Test
    void shouldRecordTelemetryLogAndCalculateVariance() {
        Instant intake = Instant.now().minus(40, ChronoUnit.MINUTES);
        Instant commenced = Instant.now().minus(30, ChronoUnit.MINUTES);
        Instant fulfilled = Instant.now();

        TelemetryLog log = TelemetryLog.record(
                "tkt-101",
                1,
                "Maria Santos",
                "srv-haircut",
                "Classic Haircut",
                new BigDecimal("180.00"),
                intake,
                commenced,
                fulfilled,
                30,
                25
        );

        assertThat(log.getId()).isNotNull();
        assertThat(log.getId().value()).startsWith("tel-");
        assertThat(log.getTicketId()).isEqualTo("tkt-101");
        assertThat(log.getActualDurationMinutes()).isEqualTo(30);
        assertThat(log.getEstimatedDurationMinutes()).isEqualTo(25);
        assertThat(log.getDurationVarianceMinutes()).isEqualTo(5);
        assertThat(log.getDayOfWeek()).isBetween(1, 7);
        assertThat(log.getHourOfDay()).isBetween(0, 23);
    }
}

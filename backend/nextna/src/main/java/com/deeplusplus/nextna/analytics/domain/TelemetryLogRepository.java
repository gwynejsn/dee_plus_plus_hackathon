package com.deeplusplus.nextna.analytics.domain;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface TelemetryLogRepository {

    TelemetryLog save(TelemetryLog log);

    Optional<TelemetryLog> findById(TelemetryLogId id);

    List<TelemetryLog> findRecent(int limit);

    List<HistoricalDurationStat> findHistoricalStatsByService(String serviceId);

    Optional<HistoricalDurationStat> findHistoricalStatByServiceDayHour(String serviceId, int dayOfWeek, int hourOfDay);

    List<DailyFinancialSummary> findDailyFinancialSummaries(LocalDate fromDate, LocalDate toDate);
}

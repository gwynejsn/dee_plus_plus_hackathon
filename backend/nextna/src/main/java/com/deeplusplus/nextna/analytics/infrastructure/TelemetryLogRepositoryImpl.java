package com.deeplusplus.nextna.analytics.infrastructure;

import com.deeplusplus.nextna.analytics.domain.DailyFinancialSummary;
import com.deeplusplus.nextna.analytics.domain.HistoricalDurationStat;
import com.deeplusplus.nextna.analytics.domain.TelemetryLog;
import com.deeplusplus.nextna.analytics.domain.TelemetryLogId;
import com.deeplusplus.nextna.analytics.domain.TelemetryLogRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public class TelemetryLogRepositoryImpl implements TelemetryLogRepository {

    private final SpringDataTelemetryLogRepository springDataRepository;
    private final JdbcTemplate jdbcTemplate;

    public TelemetryLogRepositoryImpl(
            SpringDataTelemetryLogRepository springDataRepository,
            JdbcTemplate jdbcTemplate
    ) {
        this.springDataRepository = springDataRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public TelemetryLog save(TelemetryLog log) {
        TelemetryLogJpaEntity entity = toEntity(log);
        TelemetryLogJpaEntity saved = springDataRepository.save(entity);
        return toDomain(saved);
    }

    @Override
    public Optional<TelemetryLog> findById(TelemetryLogId id) {
        return springDataRepository.findById(id.value()).map(this::toDomain);
    }

    @Override
    public List<TelemetryLog> findRecent(int limit) {
        return springDataRepository.findTop50ByOrderByTimeFulfilledDesc().stream()
                .limit(limit)
                .map(this::toDomain)
                .toList();
    }

    @Override
    public List<HistoricalDurationStat> findHistoricalStatsByService(String serviceId) {
        String sql = """
                SELECT service_id, service_name, day_of_week, hour_of_day, total_samples,
                       average_duration_minutes, min_duration_minutes, max_duration_minutes
                FROM view_predictive_duration_stats
                WHERE service_id = ?
                ORDER BY day_of_week ASC, hour_of_day ASC
                """;

        return jdbcTemplate.query(sql, historicalStatRowMapper, serviceId);
    }

    @Override
    public Optional<HistoricalDurationStat> findHistoricalStatByServiceDayHour(String serviceId, int dayOfWeek, int hourOfDay) {
        String sql = """
                SELECT service_id, service_name, day_of_week, hour_of_day, total_samples,
                       average_duration_minutes, min_duration_minutes, max_duration_minutes
                FROM view_predictive_duration_stats
                WHERE service_id = ? AND day_of_week = ? AND hour_of_day = ?
                """;

        List<HistoricalDurationStat> list = jdbcTemplate.query(sql, historicalStatRowMapper, serviceId, dayOfWeek, hourOfDay);
        return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
    }

    @Override
    public List<DailyFinancialSummary> findDailyFinancialSummaries(LocalDate fromDate, LocalDate toDate) {
        String sql = """
                SELECT report_date, total_services_completed, total_revenue_php,
                       average_service_duration_minutes, revenue_per_minute_php
                FROM view_daily_financial_summary
                WHERE report_date BETWEEN ? AND ?
                ORDER BY report_date DESC
                """;

        return jdbcTemplate.query(sql, financialSummaryRowMapper, Date.valueOf(fromDate), Date.valueOf(toDate));
    }

    private final RowMapper<HistoricalDurationStat> historicalStatRowMapper = (rs, rowNum) -> new HistoricalDurationStat(
            rs.getString("service_id"),
            rs.getString("service_name"),
            rs.getInt("day_of_week"),
            rs.getInt("hour_of_day"),
            rs.getLong("total_samples"),
            rs.getInt("average_duration_minutes"),
            rs.getInt("min_duration_minutes"),
            rs.getInt("max_duration_minutes")
    );

    private final RowMapper<DailyFinancialSummary> financialSummaryRowMapper = (rs, rowNum) -> new DailyFinancialSummary(
            rs.getDate("report_date").toLocalDate(),
            rs.getLong("total_services_completed"),
            rs.getBigDecimal("total_revenue_php") != null ? rs.getBigDecimal("total_revenue_php") : BigDecimal.ZERO,
            rs.getDouble("average_service_duration_minutes"),
            rs.getBigDecimal("revenue_per_minute_php") != null ? rs.getBigDecimal("revenue_per_minute_php") : BigDecimal.ZERO
    );

    private TelemetryLogJpaEntity toEntity(TelemetryLog domain) {
        return new TelemetryLogJpaEntity(
                domain.getId().value(),
                domain.getTicketId(),
                domain.getTicketNumber(),
                domain.getCustomerName(),
                domain.getServiceId(),
                domain.getServiceName(),
                domain.getServicePrice(),
                domain.getTimeIntake(),
                domain.getTimeCommenced(),
                domain.getTimeFulfilled(),
                domain.getActualDurationMinutes(),
                domain.getEstimatedDurationMinutes(),
                domain.getDurationVarianceMinutes(),
                domain.getDayOfWeek(),
                domain.getHourOfDay(),
                domain.getCreatedAt()
        );
    }

    private TelemetryLog toDomain(TelemetryLogJpaEntity entity) {
        return TelemetryLog.reconstruct(
                TelemetryLogId.of(entity.getId()),
                entity.getTicketId(),
                entity.getTicketNumber(),
                entity.getCustomerName(),
                entity.getServiceId(),
                entity.getServiceName(),
                entity.getServicePrice(),
                entity.getTimeIntake(),
                entity.getTimeCommenced(),
                entity.getTimeFulfilled(),
                entity.getActualDurationMinutes(),
                entity.getEstimatedDurationMinutes(),
                entity.getDurationVarianceMinutes(),
                entity.getDayOfWeek(),
                entity.getHourOfDay(),
                entity.getCreatedAt()
        );
    }
}

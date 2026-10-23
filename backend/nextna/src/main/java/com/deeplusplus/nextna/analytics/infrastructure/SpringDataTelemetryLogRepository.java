package com.deeplusplus.nextna.analytics.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SpringDataTelemetryLogRepository extends JpaRepository<TelemetryLogJpaEntity, String> {

    List<TelemetryLogJpaEntity> findTop50ByOrderByTimeFulfilledDesc();
}

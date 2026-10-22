package com.deeplusplus.NextNa.servicecatalog.infrastructure;

import com.deeplusplus.NextNa.servicecatalog.domain.CatalogService;
import com.deeplusplus.NextNa.servicecatalog.domain.DurationMinutes;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceCategory;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceId;
import com.deeplusplus.NextNa.servicecatalog.domain.ServicePrice;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceRepository;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

@Component
public class ServiceRepositoryImpl implements ServiceRepository {

    private final SpringDataServiceRepository jpaRepository;

    public ServiceRepositoryImpl(SpringDataServiceRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public CatalogService save(CatalogService service) {
        ServiceJpaEntity entity = toEntity(service);
        ServiceJpaEntity saved = jpaRepository.save(entity);
        return toDomain(saved);
    }

    @Override
    public Optional<CatalogService> findById(ServiceId id) {
        return jpaRepository.findById(id.value()).map(this::toDomain);
    }

    @Override
    public List<CatalogService> findAllActive() {
        return jpaRepository.findByActiveTrue().stream()
                .map(this::toDomain)
                .toList();
    }

    @Override
    public List<CatalogService> findAll() {
        return jpaRepository.findAll().stream()
                .map(this::toDomain)
                .toList();
    }

    @Override
    public boolean existsByName(String name) {
        return jpaRepository.existsByNameIgnoreCase(name);
    }

    private ServiceJpaEntity toEntity(CatalogService domain) {
        return new ServiceJpaEntity(
                domain.getId().value(),
                domain.getName(),
                domain.getCategory().name(),
                domain.getPrice().amount(),
                domain.getBaselineDuration().minutes(),
                domain.isActive(),
                domain.getCreatedAt(),
                domain.getUpdatedAt()
        );
    }

    private CatalogService toDomain(ServiceJpaEntity entity) {
        return CatalogService.reconstitute(
                ServiceId.of(entity.getId()),
                entity.getName(),
                ServiceCategory.fromString(entity.getCategory()),
                ServicePrice.of(entity.getUnitPrice()),
                DurationMinutes.of(entity.getBaselineDurationMinutes()),
                Boolean.TRUE.equals(entity.getActive()),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}

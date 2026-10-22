package com.deeplusplus.NextNa.servicecatalog.api;

import com.deeplusplus.NextNa.servicecatalog.domain.CatalogService;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceId;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceRepository;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class ServiceCatalogApiImpl implements ServiceCatalogApi {

    private final ServiceRepository repository;

    public ServiceCatalogApiImpl(ServiceRepository repository) {
        this.repository = repository;
    }

    @Override
    public Optional<ServiceDetailsDto> findServiceById(String serviceId) {
        if (serviceId == null || serviceId.isBlank()) {
            return Optional.empty();
        }
        return repository.findById(ServiceId.of(serviceId)).map(this::toDto);
    }

    @Override
    public boolean isServiceActive(String serviceId) {
        if (serviceId == null || serviceId.isBlank()) {
            return false;
        }
        return repository.findById(ServiceId.of(serviceId))
                .map(CatalogService::isActive)
                .orElse(false);
    }

    private ServiceDetailsDto toDto(CatalogService domain) {
        return new ServiceDetailsDto(
                domain.getId().value(),
                domain.getName(),
                domain.getCategory().name(),
                domain.getPrice().amount(),
                domain.getBaselineDuration().minutes(),
                domain.isActive()
        );
    }
}

package com.deeplusplus.NextNa.servicecatalog.application;

import com.deeplusplus.NextNa.servicecatalog.domain.CatalogService;
import com.deeplusplus.NextNa.servicecatalog.domain.DurationMinutes;
import com.deeplusplus.NextNa.servicecatalog.domain.InvalidServiceNameException;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceCategory;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceId;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceNotFoundException;
import com.deeplusplus.NextNa.servicecatalog.domain.ServicePrice;
import com.deeplusplus.NextNa.servicecatalog.domain.ServiceRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class ServiceCatalogService {

    private final ServiceRepository repository;

    public ServiceCatalogService(ServiceRepository repository) {
        this.repository = repository;
    }

    public ServiceResponseDto createService(CreateServiceCommand command) {
        if (command.name() == null || command.name().isBlank()) {
            throw new InvalidServiceNameException("Service name cannot be empty");
        }
        if (repository.existsByName(command.name().trim())) {
            throw new InvalidServiceNameException("Service with name '" + command.name().trim() + "' already exists");
        }

        CatalogService service = CatalogService.create(
                command.name(),
                ServiceCategory.fromString(command.category()),
                ServicePrice.of(command.unitPrice()),
                DurationMinutes.of(command.baselineDurationMinutes())
        );

        CatalogService saved = repository.save(service);
        return ServiceResponseDto.from(saved);
    }

    public ServiceResponseDto updateService(String id, UpdateServiceCommand command) {
        CatalogService service = repository.findById(ServiceId.of(id))
                .orElseThrow(() -> ServiceNotFoundException.of(id));

        service.updateDetails(
                command.name(),
                ServiceCategory.fromString(command.category()),
                ServicePrice.of(command.unitPrice()),
                DurationMinutes.of(command.baselineDurationMinutes())
        );

        CatalogService updated = repository.save(service);
        return ServiceResponseDto.from(updated);
    }

    public void deactivateService(String id) {
        CatalogService service = repository.findById(ServiceId.of(id))
                .orElseThrow(() -> ServiceNotFoundException.of(id));
        service.deactivate();
        repository.save(service);
    }

    public void activateService(String id) {
        CatalogService service = repository.findById(ServiceId.of(id))
                .orElseThrow(() -> ServiceNotFoundException.of(id));
        service.activate();
        repository.save(service);
    }

    @Transactional(readOnly = true)
    public ServiceResponseDto getServiceById(String id) {
        return repository.findById(ServiceId.of(id))
                .map(ServiceResponseDto::from)
                .orElseThrow(() -> ServiceNotFoundException.of(id));
    }

    @Transactional(readOnly = true)
    public List<ServiceResponseDto> getAllActiveServices() {
        return repository.findAllActive().stream()
                .map(ServiceResponseDto::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ServiceResponseDto> getAllServices() {
        return repository.findAll().stream()
                .map(ServiceResponseDto::from)
                .toList();
    }
}

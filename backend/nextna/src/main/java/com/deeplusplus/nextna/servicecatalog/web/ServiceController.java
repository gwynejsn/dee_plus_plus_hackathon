package com.deeplusplus.nextna.servicecatalog.web;

import com.deeplusplus.nextna.servicecatalog.application.ServiceCatalogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "1. Service Catalog", description = "Endpoints for managing MSME services, baseline durations, and pricing")
@RestController
@RequestMapping("/api/v1/services")
public class ServiceController {

    private final ServiceCatalogService service;

    public ServiceController(ServiceCatalogService service) {
        this.service = service;
    }

    @Operation(summary = "Create a new service offering")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ServiceResponse createService(@Valid @RequestBody CreateServiceRequest request) {
        return ServiceResponse.from(service.createService(request.toCommand()));
    }

    @Operation(summary = "Get list of all services, optionally filtered by active status")
    @GetMapping
    public List<ServiceResponse> getAllServices(@RequestParam(name = "activeOnly", defaultValue = "false") boolean activeOnly) {
        if (activeOnly) {
            return service.getAllActiveServices().stream()
                    .map(ServiceResponse::from)
                    .toList();
        }
        return service.getAllServices().stream()
                .map(ServiceResponse::from)
                .toList();
    }

    @Operation(summary = "Get service details by ID")
    @GetMapping("/{id}")
    public ServiceResponse getServiceById(@PathVariable String id) {
        return ServiceResponse.from(service.getServiceById(id));
    }

    @Operation(summary = "Update service details")
    @PutMapping("/{id}")
    public ServiceResponse updateService(@PathVariable String id, @Valid @RequestBody UpdateServiceRequest request) {
        return ServiceResponse.from(service.updateService(id, request.toCommand()));
    }

    @Operation(summary = "Deactivate a service")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deactivateService(@PathVariable String id) {
        service.deactivateService(id);
    }

    @Operation(summary = "Reactivate a service")
    @PatchMapping("/{id}/activate")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void activateService(@PathVariable String id) {
        service.activateService(id);
    }
}

package com.deeplusplus.nextna.servicecatalog.web;

import com.deeplusplus.nextna.servicecatalog.application.ServiceCatalogService;
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

@RestController
@RequestMapping("/api/v1/services")
public class ServiceController {

    private final ServiceCatalogService service;

    public ServiceController(ServiceCatalogService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ServiceResponse createService(@Valid @RequestBody CreateServiceRequest request) {
        return ServiceResponse.from(service.createService(request.toCommand()));
    }

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

    @GetMapping("/{id}")
    public ServiceResponse getServiceById(@PathVariable String id) {
        return ServiceResponse.from(service.getServiceById(id));
    }

    @PutMapping("/{id}")
    public ServiceResponse updateService(@PathVariable String id, @Valid @RequestBody UpdateServiceRequest request) {
        return ServiceResponse.from(service.updateService(id, request.toCommand()));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deactivateService(@PathVariable String id) {
        service.deactivateService(id);
    }

    @PatchMapping("/{id}/activate")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void activateService(@PathVariable String id) {
        service.activateService(id);
    }
}

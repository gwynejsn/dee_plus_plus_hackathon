package com.deeplusplus.nextna.servicecatalog.api;

import java.util.Optional;

public interface ServiceCatalogApi {
    Optional<ServiceDetailsDto> findServiceById(String serviceId);
    boolean isServiceActive(String serviceId);
}

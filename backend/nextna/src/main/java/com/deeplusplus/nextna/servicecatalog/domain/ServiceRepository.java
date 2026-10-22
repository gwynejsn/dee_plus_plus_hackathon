package com.deeplusplus.NextNa.servicecatalog.domain;

import java.util.List;
import java.util.Optional;

public interface ServiceRepository {
    CatalogService save(CatalogService service);
    Optional<CatalogService> findById(ServiceId id);
    List<CatalogService> findAllActive();
    List<CatalogService> findAll();
    boolean existsByName(String name);
}

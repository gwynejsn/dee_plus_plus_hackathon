package com.deeplusplus.nextna.servicecatalog.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SpringDataServiceRepository extends JpaRepository<ServiceJpaEntity, String> {
    List<ServiceJpaEntity> findByActiveTrue();
    boolean existsByNameIgnoreCase(String name);
}

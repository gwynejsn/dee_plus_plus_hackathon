package com.deeplusplus.nextna.servicecatalog.domain;

public class ServiceNotFoundException extends RuntimeException {
    public ServiceNotFoundException(String message) {
        super(message);
    }

    public static ServiceNotFoundException of(ServiceId id) {
        return new ServiceNotFoundException("Service with id '" + id.value() + "' was not found");
    }

    public static ServiceNotFoundException of(String id) {
        return new ServiceNotFoundException("Service with id '" + id + "' was not found");
    }
}

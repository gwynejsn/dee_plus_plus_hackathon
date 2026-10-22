package com.deeplusplus.nextna.servicecatalog.domain;

public class InvalidServicePriceException extends RuntimeException {
    public InvalidServicePriceException(String message) {
        super(message);
    }
}

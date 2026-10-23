package com.deeplusplus.nextna.servicecatalog.domain;

public class InvalidServiceNameException extends RuntimeException {
    public InvalidServiceNameException(String message) {
        super(message);
    }
}

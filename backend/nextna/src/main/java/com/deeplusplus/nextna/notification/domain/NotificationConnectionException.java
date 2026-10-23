package com.deeplusplus.nextna.notification.domain;

public class NotificationConnectionException extends RuntimeException {

    public NotificationConnectionException(String message) {
        super(message);
    }

    public NotificationConnectionException(String message, Throwable cause) {
        super(message, cause);
    }
}

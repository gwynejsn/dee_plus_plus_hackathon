package com.deeplusplus.nextna.notification.domain;

public interface NotificationConnection {

    String connectionId();

    void send(String eventName, Object data);

    void complete();

    void completeWithError(Throwable throwable);

    boolean isAlive();
}

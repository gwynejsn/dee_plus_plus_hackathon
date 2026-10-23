package com.deeplusplus.nextna.notification.domain;

import java.util.List;

public interface NotificationConnectionRepository {

    void registerBuzzerConnection(String ticketId, NotificationConnection connection);

    void removeBuzzerConnection(String ticketId, String connectionId);

    List<NotificationConnection> findBuzzerConnections(String ticketId);

    void registerDisplayConnection(NotificationConnection connection);

    void removeDisplayConnection(String connectionId);

    List<NotificationConnection> findDisplayConnections();

    int countActiveBuzzerConnections();

    int countActiveDisplayConnections();
}

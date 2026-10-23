package com.deeplusplus.nextna.notification.api;

import com.deeplusplus.nextna.notification.domain.NotificationConnectionRepository;
import org.springframework.stereotype.Component;

@Component
public class NotificationApiImpl implements NotificationApi {

    private final NotificationConnectionRepository connectionRepository;

    public NotificationApiImpl(NotificationConnectionRepository connectionRepository) {
        this.connectionRepository = connectionRepository;
    }

    @Override
    public int getActiveBuzzerConnectionCount() {
        return connectionRepository.countActiveBuzzerConnections();
    }

    @Override
    public int getActiveDisplayConnectionCount() {
        return connectionRepository.countActiveDisplayConnections();
    }
}

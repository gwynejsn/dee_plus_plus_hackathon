package com.deeplusplus.nextna.notification.infrastructure;

import com.deeplusplus.nextna.notification.domain.NotificationConnection;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class InMemoryNotificationConnectionRepositoryTest {

    private InMemoryNotificationConnectionRepository repository;

    @BeforeEach
    void setUp() {
        repository = new InMemoryNotificationConnectionRepository();
    }

    @Test
    void shouldRegisterAndRetrieveBuzzerConnection() {
        TestConnection conn1 = new TestConnection("conn-1", true);
        TestConnection conn2 = new TestConnection("conn-2", true);

        repository.registerBuzzerConnection("t-100", conn1);
        repository.registerBuzzerConnection("t-100", conn2);

        List<NotificationConnection> connections = repository.findBuzzerConnections("t-100");
        assertEquals(2, connections.size());
        assertEquals(2, repository.countActiveBuzzerConnections());

        repository.removeBuzzerConnection("t-100", "conn-1");
        assertEquals(1, repository.findBuzzerConnections("t-100").size());
    }

    @Test
    void shouldPruneDeadConnections() {
        TestConnection active = new TestConnection("conn-1", true);
        TestConnection dead = new TestConnection("conn-2", false);

        repository.registerBuzzerConnection("t-100", active);
        repository.registerBuzzerConnection("t-100", dead);

        List<NotificationConnection> connections = repository.findBuzzerConnections("t-100");
        assertEquals(1, connections.size());
        assertEquals("conn-1", connections.get(0).connectionId());
    }

    @Test
    void shouldRegisterAndRetrieveDisplayConnections() {
        TestConnection conn1 = new TestConnection("disp-1", true);
        repository.registerDisplayConnection(conn1);

        assertEquals(1, repository.findDisplayConnections().size());
        assertEquals(1, repository.countActiveDisplayConnections());

        repository.removeDisplayConnection("disp-1");
        assertTrue(repository.findDisplayConnections().isEmpty());
    }

    private static class TestConnection implements NotificationConnection {
        private final String id;
        private final boolean alive;

        TestConnection(String id, boolean alive) {
            this.id = id;
            this.alive = alive;
        }

        @Override
        public String connectionId() {
            return id;
        }

        @Override
        public void send(String eventName, Object data) {}

        @Override
        public void complete() {}

        @Override
        public void completeWithError(Throwable throwable) {}

        @Override
        public boolean isAlive() {
            return alive;
        }
    }
}

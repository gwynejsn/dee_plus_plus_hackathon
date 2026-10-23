package com.deeplusplus.nextna.notification.infrastructure;

import com.deeplusplus.nextna.notification.domain.NotificationConnection;
import com.deeplusplus.nextna.notification.domain.NotificationConnectionRepository;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Repository
public class InMemoryNotificationConnectionRepository implements NotificationConnectionRepository {

    private final Map<String, List<NotificationConnection>> buzzerConnections = new ConcurrentHashMap<>();
    private final List<NotificationConnection> displayConnections = new CopyOnWriteArrayList<>();

    @Override
    public void registerBuzzerConnection(String ticketId, NotificationConnection connection) {
        buzzerConnections.computeIfAbsent(ticketId, k -> new CopyOnWriteArrayList<>()).add(connection);
    }

    @Override
    public void removeBuzzerConnection(String ticketId, String connectionId) {
        List<NotificationConnection> connections = buzzerConnections.get(ticketId);
        if (connections != null) {
            connections.removeIf(conn -> conn.connectionId().equals(connectionId) || !conn.isAlive());
            if (connections.isEmpty()) {
                buzzerConnections.remove(ticketId);
            }
        }
    }

    @Override
    public List<NotificationConnection> findBuzzerConnections(String ticketId) {
        List<NotificationConnection> connections = buzzerConnections.get(ticketId);
        if (connections == null) {
            return List.of();
        }
        connections.removeIf(conn -> !conn.isAlive());
        return List.copyOf(connections);
    }

    @Override
    public void registerDisplayConnection(NotificationConnection connection) {
        displayConnections.add(connection);
    }

    @Override
    public void removeDisplayConnection(String connectionId) {
        displayConnections.removeIf(conn -> conn.connectionId().equals(connectionId) || !conn.isAlive());
    }

    @Override
    public List<NotificationConnection> findDisplayConnections() {
        displayConnections.removeIf(conn -> !conn.isAlive());
        return List.copyOf(displayConnections);
    }

    @Override
    public int countActiveBuzzerConnections() {
        return buzzerConnections.values().stream()
                .mapToInt(list -> (int) list.stream().filter(NotificationConnection::isAlive).count())
                .sum();
    }

    @Override
    public int countActiveDisplayConnections() {
        return (int) displayConnections.stream()
                .filter(NotificationConnection::isAlive)
                .count();
    }
}

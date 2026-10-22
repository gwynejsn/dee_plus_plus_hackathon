package com.deeplusplus.nextna.queue.infrastructure;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SpringDataQueueTicketRepository extends JpaRepository<QueueTicketJpaEntity, String> {

    List<QueueTicketJpaEntity> findByStateInOrderByTicketNumberAsc(List<String> states);

    List<QueueTicketJpaEntity> findByStateOrderByTicketNumberAsc(String state);

    Optional<QueueTicketJpaEntity> findByTicketNumber(Integer ticketNumber);

    @Query("SELECT COALESCE(MAX(q.ticketNumber), 0) FROM QueueTicketJpaEntity q")
    int findMaxTicketNumber();
}

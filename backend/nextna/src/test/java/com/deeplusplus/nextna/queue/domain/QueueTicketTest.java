package com.deeplusplus.nextna.queue.domain;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class QueueTicketTest {

    @Test
    void shouldIssueNewTicketWithWaitingState() {
        QueueTicket ticket = QueueTicket.issue(
                TicketNumber.of(1),
                CustomerName.of("Alice"),
                "srv-haircut",
                new BigDecimal("150.00"),
                15
        );

        assertThat(ticket.getId()).isNotNull();
        assertThat(ticket.getTicketNumber().value()).isEqualTo(1);
        assertThat(ticket.getCustomerName().value()).isEqualTo("Alice");
        assertThat(ticket.getState()).isEqualTo(TicketState.WAITING);
        assertThat(ticket.getEstimatedWaitMinutes()).isEqualTo(15);
        assertThat(ticket.isManualOverride()).isFalse();
        assertThat(ticket.isOnMyWayConfirmed()).isFalse();
        assertThat(ticket.getCalledAt()).isNull();
        assertThat(ticket.getCompletedAt()).isNull();
    }

    @Test
    void shouldProgressThroughLifecycleSuccessfully() {
        QueueTicket ticket = QueueTicket.issue(
                TicketNumber.of(2),
                CustomerName.of("Bob"),
                "srv-shave",
                new BigDecimal("100.00"),
                10
        );

        ticket.stageAlmostNext();
        assertThat(ticket.getState()).isEqualTo(TicketState.ALMOST_NEXT);

        ticket.confirmOnMyWay();
        assertThat(ticket.isOnMyWayConfirmed()).isTrue();

        ticket.call();
        assertThat(ticket.getState()).isEqualTo(TicketState.NOW_SERVING);
        assertThat(ticket.getCalledAt()).isNotNull();

        ticket.complete();
        assertThat(ticket.getState()).isEqualTo(TicketState.COMPLETED);
        assertThat(ticket.getCompletedAt()).isNotNull();
    }

    @Test
    void shouldNotCompleteTicketIfNotServing() {
        QueueTicket ticket = QueueTicket.issue(
                TicketNumber.of(3),
                CustomerName.of("Charlie"),
                "srv-coffee",
                new BigDecimal("80.00"),
                5
        );

        assertThatThrownBy(ticket::complete)
                .isInstanceOf(InvalidTicketStateException.class);
    }

    @Test
    void shouldCancelActiveTicket() {
        QueueTicket ticket = QueueTicket.issue(
                TicketNumber.of(4),
                CustomerName.of("Diana"),
                "srv-manicure",
                new BigDecimal("200.00"),
                20
        );

        ticket.cancel();
        assertThat(ticket.getState()).isEqualTo(TicketState.CANCELLED);
    }

    @Test
    void shouldNotCancelCompletedTicket() {
        QueueTicket ticket = QueueTicket.issue(
                TicketNumber.of(5),
                CustomerName.of("Evan"),
                "srv-carwash",
                new BigDecimal("300.00"),
                30
        );
        ticket.call();
        ticket.complete();

        assertThatThrownBy(ticket::cancel)
                .isInstanceOf(InvalidTicketStateException.class);
    }

    @Test
    void shouldOverrideEstimatedWait() {
        QueueTicket ticket = QueueTicket.issue(
                TicketNumber.of(6),
                CustomerName.of("Frank"),
                "srv-laundry",
                new BigDecimal("120.00"),
                25
        );

        ticket.overrideEstimatedWait(45);
        assertThat(ticket.getEstimatedWaitMinutes()).isEqualTo(45);
        assertThat(ticket.isManualOverride()).isTrue();

        ticket.updateCalculatedWait(10);
        assertThat(ticket.getEstimatedWaitMinutes()).isEqualTo(45);
    }
}

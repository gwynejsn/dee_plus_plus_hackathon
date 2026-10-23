package com.deeplusplus.nextna.notification.domain;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class BuzzerNotificationTest {

    @Test
    void shouldCreateInitialBuzzerNotificationInWaitingState() {
        BuzzerNotification buzzer = BuzzerNotification.createInitial(
                "ticket-123",
                5,
                "Juan Dela Cruz",
                3,
                45
        );

        assertEquals("ticket-123", buzzer.getTicketId());
        assertEquals(5, buzzer.getTicketNumber());
        assertEquals("Juan Dela Cruz", buzzer.getCustomerName());
        assertEquals(BuzzerAlertStatus.IN_LINE, buzzer.getStatus());
        assertEquals(3, buzzer.getPeopleAhead());
        assertEquals(45, buzzer.getEstimatedWaitMinutes());
        assertFalse(buzzer.isOnMyWayConfirmed());
    }

    @Test
    void shouldTransitionToAlmostNext() {
        BuzzerNotification buzzer = BuzzerNotification.createInitial(
                "ticket-123",
                5,
                "Juan Dela Cruz",
                3,
                45
        );

        buzzer.markAlmostNext();

        assertEquals(BuzzerAlertStatus.ALMOST_NEXT, buzzer.getStatus());
        assertEquals(1, buzzer.getPeopleAhead());
    }

    @Test
    void shouldTransitionToNowServing() {
        BuzzerNotification buzzer = BuzzerNotification.createInitial(
                "ticket-123",
                5,
                "Juan Dela Cruz",
                3,
                45
        );

        buzzer.markNowServing();

        assertEquals(BuzzerAlertStatus.NOW_SERVING, buzzer.getStatus());
        assertEquals(0, buzzer.getPeopleAhead());
        assertEquals(0, buzzer.getEstimatedWaitMinutes());
    }

    @Test
    void shouldConfirmOnMyWay() {
        BuzzerNotification buzzer = BuzzerNotification.createInitial(
                "ticket-123",
                5,
                "Juan Dela Cruz",
                1,
                15
        );

        buzzer.confirmOnMyWay();

        assertTrue(buzzer.isOnMyWayConfirmed());
    }

    @Test
    void shouldRejectInvalidInvariants() {
        assertThrows(IllegalArgumentException.class, () -> BuzzerNotification.createInitial(
                "",
                5,
                "Juan",
                1,
                10
        ));

        assertThrows(IllegalArgumentException.class, () -> BuzzerNotification.createInitial(
                "t-1",
                0,
                "Juan",
                1,
                10
        ));

        assertThrows(IllegalArgumentException.class, () -> BuzzerNotification.createInitial(
                "t-1",
                1,
                "Juan",
                -1,
                10
        ));
    }

    @Test
    void shouldValidateDisplayBoardUpdate() {
        DisplayBoardUpdate update = new DisplayBoardUpdate(
                "TICKET_CALLED",
                5,
                "Juan Dela Cruz",
                6,
                "Maria Clara",
                2,
                List.of(7, 8),
                "Ticket 5 called",
                null
        );

        assertEquals("TICKET_CALLED", update.getEventType());
        assertEquals(5, update.getCurrentServingNumber());
        assertEquals("Juan Dela Cruz", update.getCurrentServingCustomer());
        assertEquals(2, update.getTotalWaitingCount());
        assertEquals(2, update.getWaitingNumbers().size());
    }
}

package com.deeplusplus.nextna.notification.application;

import com.deeplusplus.nextna.notification.domain.BuzzerNotification;

import java.time.Instant;

public record BuzzerNotificationDto(
        String ticketId,
        int ticketNumber,
        String customerName,
        String status,
        int peopleAhead,
        int estimatedWaitMinutes,
        boolean onMyWayConfirmed,
        String alertMessage,
        Instant timestamp
) {
    public static BuzzerNotificationDto from(BuzzerNotification buzzer) {
        return new BuzzerNotificationDto(
                buzzer.getTicketId(),
                buzzer.getTicketNumber(),
                buzzer.getCustomerName(),
                buzzer.getStatus().name(),
                buzzer.getPeopleAhead(),
                buzzer.getEstimatedWaitMinutes(),
                buzzer.isOnMyWayConfirmed(),
                buzzer.getAlertMessage(),
                buzzer.getUpdatedAt()
        );
    }
}

package com.deeplusplus.nextna.notification.application;

import com.deeplusplus.nextna.notification.domain.DisplayBoardUpdate;

import java.time.Instant;
import java.util.List;

public record DisplayBoardDto(
        String eventType,
        Integer currentServingNumber,
        String currentServingCustomer,
        Integer almostNextNumber,
        String almostNextCustomer,
        int totalWaitingCount,
        List<Integer> waitingNumbers,
        String alertMessage,
        Instant timestamp
) {
    public static DisplayBoardDto from(DisplayBoardUpdate update) {
        return new DisplayBoardDto(
                update.getEventType(),
                update.getCurrentServingNumber(),
                update.getCurrentServingCustomer(),
                update.getAlmostNextNumber(),
                update.getAlmostNextCustomer(),
                update.getTotalWaitingCount(),
                update.getWaitingNumbers(),
                update.getAlertMessage(),
                update.getTimestamp()
        );
    }
}

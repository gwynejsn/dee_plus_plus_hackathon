package com.deeplusplus.nextna.analytics.api;

public interface PredictiveWaitTimeApi {

    PredictiveDurationDto getSuggestedDuration(String serviceId, int dayOfWeek, int hourOfDay);
}

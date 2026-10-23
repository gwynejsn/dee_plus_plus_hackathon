import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String liveCloudUrl = 'https://nextna-backend.onrender.com';
  static const String localDevUrl = 'http://localhost:8080';

  // ValueNotifier so the whole app reacts instantly when the environment changes
  static final ValueNotifier<String> baseUrlNotifier = ValueNotifier<String>(liveCloudUrl);

  static String get baseUrl => baseUrlNotifier.value;

  static void setBaseUrl(String url) {
    var cleaned = url.trim();
    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    baseUrlNotifier.value = cleaned;
  }

  static bool get isLocal => baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1');

  // Endpoints
  static String get servicesEndpoint => '$baseUrl/api/v1/services';
  static String serviceByIdEndpoint(String id) => '$baseUrl/api/v1/services/$id';
  static String activateServiceEndpoint(String id) => '$baseUrl/api/v1/services/$id/activate';

  static String get queueTicketsEndpoint => '$baseUrl/api/v1/queue/tickets';
  static String queueTicketByIdEndpoint(String id) => '$baseUrl/api/v1/queue/tickets/$id';
  static String get queueSummaryEndpoint => '$baseUrl/api/v1/queue/summary';
  static String get callNextTicketEndpoint => '$baseUrl/api/v1/queue/tickets/call-next';
  static String callTicketEndpoint(String id) => '$baseUrl/api/v1/queue/tickets/$id/call';
  static String serveTicketEndpoint(String id) => '$baseUrl/api/v1/queue/tickets/$id/serve';
  static String completeTicketEndpoint(String id) => '$baseUrl/api/v1/queue/tickets/$id/complete';
  static String cancelTicketEndpoint(String id) => '$baseUrl/api/v1/queue/tickets/$id/cancel';
  static String onMyWayEndpoint(String id) => '$baseUrl/api/v1/queue/tickets/$id/on-my-way';
  static String overrideWaitEndpoint(String id) => '$baseUrl/api/v1/queue/tickets/$id/override-wait';

  static String streamBuzzerEndpoint(String id) => '$baseUrl/api/v1/notifications/buzzer/$id/stream';
  static String get streamDisplayEndpoint => '$baseUrl/api/v1/notifications/display/stream';
  static String get streamingStatusEndpoint => '$baseUrl/api/v1/notifications/status';

  static String get analyticsOverviewEndpoint => '$baseUrl/api/v1/analytics/overview';
  static String get financialSummaryEndpoint => '$baseUrl/api/v1/analytics/financial-summary';
  static String predictiveStatsEndpoint(String serviceId) => '$baseUrl/api/v1/analytics/predictive-stats/$serviceId';
  static String get aiPredictionEndpoint => '$baseUrl/api/v1/analytics/ai-prediction';
}

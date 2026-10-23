import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/queue_ticket.dart';
import '../models/queue_summary.dart';
import '../models/service_model.dart';
import '../models/ai_prediction.dart';
import '../models/analytics_overview.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // Health check
  Future<bool> checkBackendHealth() async {
    try {
      final res = await http.get(Uri.parse(ApiConfig.streamingStatusEndpoint)).timeout(
        const Duration(seconds: 4),
      );
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // Service Catalog
  Future<List<ServiceModel>> getServices({bool activeOnly = true}) async {
    final uri = Uri.parse('${ApiConfig.servicesEndpoint}?activeOnly=$activeOnly');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load services (${res.statusCode})');
  }

  Future<ServiceModel> createService(ServiceModel service) async {
    final uri = Uri.parse(ApiConfig.servicesEndpoint);
    final res = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(service.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create service: ${res.body}');
  }

  Future<ServiceModel> updateService(String id, ServiceModel service) async {
    final uri = Uri.parse(ApiConfig.serviceByIdEndpoint(id));
    final res = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(service.toJson()),
    );
    if (res.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update service: ${res.body}');
  }

  Future<void> deleteService(String id) async {
    final uri = Uri.parse(ApiConfig.serviceByIdEndpoint(id));
    final res = await http.delete(uri, headers: _headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to deactivate service');
    }
  }

  // Queue Operations
  Future<QueueSummary> getQueueSummary() async {
    final uri = Uri.parse(ApiConfig.queueSummaryEndpoint);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      return QueueSummary.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load queue summary (${res.statusCode})');
  }

  Future<List<QueueTicket>> getActiveTickets() async {
    final uri = Uri.parse(ApiConfig.queueTicketsEndpoint);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => QueueTicket.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load active tickets (${res.statusCode})');
  }

  Future<QueueTicket> getTicketById(String id) async {
    final uri = Uri.parse(ApiConfig.queueTicketByIdEndpoint(id));
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Ticket not found or network error (${res.statusCode})');
  }

  Future<QueueTicket> issueTicket({
    required String customerName,
    required String serviceId,
    int? manualWaitMinutesOverride,
  }) async {
    final uri = Uri.parse(ApiConfig.queueTicketsEndpoint);
    final body = {
      'customerName': customerName,
      'serviceId': serviceId,
      'manualWaitMinutesOverride': manualWaitMinutesOverride,
    };
    final res = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to issue ticket: ${res.body}');
  }

  Future<QueueTicket> callNextTicket() async {
    final uri = Uri.parse(ApiConfig.callNextTicketEndpoint);
    final res = await http.post(uri, headers: _headers);
    if (res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('No tickets to call next or error (${res.statusCode})');
  }

  Future<QueueTicket> callTicket(String id) async {
    final uri = Uri.parse(ApiConfig.callTicketEndpoint(id));
    final res = await http.patch(uri, headers: _headers);
    if (res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to call ticket (${res.statusCode})');
  }

  Future<QueueTicket> serveTicket(String id) async {
    final uri = Uri.parse(ApiConfig.serveTicketEndpoint(id));
    final res = await http.patch(uri, headers: _headers);
    if (res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to serve ticket (${res.statusCode})');
  }

  Future<QueueTicket> completeTicket(String id) async {
    final uri = Uri.parse(ApiConfig.completeTicketEndpoint(id));
    final res = await http.patch(uri, headers: _headers);
    if (res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to complete ticket (${res.statusCode})');
  }

  Future<QueueTicket> cancelTicket(String id) async {
    final uri = Uri.parse(ApiConfig.cancelTicketEndpoint(id));
    final res = await http.patch(uri, headers: _headers);
    if (res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to cancel ticket (${res.statusCode})');
  }

  Future<QueueTicket> confirmOnMyWay(String id) async {
    final uri = Uri.parse(ApiConfig.onMyWayEndpoint(id));
    final res = await http.patch(uri, headers: _headers);
    if (res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to confirm On My Way (${res.statusCode})');
  }

  Future<QueueTicket> overrideWaitTime(String id, int minutes) async {
    final uri = Uri.parse(ApiConfig.overrideWaitEndpoint(id));
    final res = await http.patch(
      uri,
      headers: _headers,
      body: jsonEncode({'estimatedWaitMinutes': minutes}),
    );
    if (res.statusCode == 200) {
      return QueueTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to override wait time (${res.statusCode})');
  }

  // Analytics & AI Advisor
  Future<AnalyticsOverview> getAnalyticsOverview() async {
    final uri = Uri.parse(ApiConfig.analyticsOverviewEndpoint);
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      return AnalyticsOverview.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load analytics overview (${res.statusCode})');
  }

  Future<AiPrediction> getAiPrediction(
    String serviceId, {
    int? dayOfWeek,
    int? hourOfDay,
  }) async {
    final now = DateTime.now();
    final d = dayOfWeek ?? (now.weekday);
    final h = hourOfDay ?? (now.hour);
    final uri = Uri.parse('${ApiConfig.aiPredictionEndpoint}?serviceId=$serviceId&dayOfWeek=$d&hourOfDay=$h');
    final res = await http.get(uri, headers: _headers);
    if (res.statusCode == 200) {
      return AiPrediction.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load AI prediction (${res.statusCode})');
  }
}

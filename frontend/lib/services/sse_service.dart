import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

enum StreamConnectionState {
  connecting,
  connected,
  disconnected,
}

class SseEvent {
  final String type;
  final Map<String, dynamic> data;

  SseEvent({required this.type, required this.data});
}

class SseSubscription {
  final StreamSubscription? _subscription;
  final http.Client? _client;
  final Timer? _reconnectTimer;

  SseSubscription({
    StreamSubscription? subscription,
    http.Client? client,
    Timer? reconnectTimer,
  })  : _subscription = subscription,
        _client = client,
        _reconnectTimer = reconnectTimer;

  void cancel() {
    _subscription?.cancel();
    _client?.close();
    _reconnectTimer?.cancel();
  }
}

class SseService {
  static final SseService _instance = SseService._internal();
  factory SseService() => _instance;
  SseService._internal();

  SseSubscription subscribeBuzzer(
    String ticketId, {
    required void Function(SseEvent event) onEvent,
    void Function(StreamConnectionState state)? onStateChange,
  }) {
    final url = ApiConfig.streamBuzzerEndpoint(ticketId);
    return _connectStream(url, onEvent, onStateChange);
  }

  SseSubscription subscribeDisplay({
    required void Function(SseEvent event) onEvent,
    void Function(StreamConnectionState state)? onStateChange,
  }) {
    final url = ApiConfig.streamDisplayEndpoint;
    return _connectStream(url, onEvent, onStateChange);
  }

  SseSubscription _connectStream(
    String url,
    void Function(SseEvent event) onEvent,
    void Function(StreamConnectionState state)? onStateChange,
  ) {
    http.Client? client;
    StreamSubscription? subscription;
    Timer? reconnectTimer;
    bool isClosed = false;

    void connect() async {
      if (isClosed) return;
      onStateChange?.call(StreamConnectionState.connecting);

      client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(url));
        request.headers['Accept'] = 'text/event-stream';
        request.headers['Cache-Control'] = 'no-cache';

        final response = await client!.send(request);
        if (response.statusCode == 200) {
          onStateChange?.call(StreamConnectionState.connected);

          String currentEvent = 'message';
          final lineStream = response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter());

          subscription = lineStream.listen(
            (line) {
              final trimmed = line.trim();
              if (trimmed.isEmpty) return;

              if (trimmed.startsWith('event:')) {
                currentEvent = trimmed.substring(6).trim();
              } else if (trimmed.startsWith('data:')) {
                final dataStr = trimmed.substring(5).trim();
                try {
                  final decoded = jsonDecode(dataStr);
                  if (decoded is Map<String, dynamic>) {
                    onEvent(SseEvent(type: currentEvent, data: decoded));
                  }
                } catch (e) {
                  debugPrint('Failed to parse SSE data: $dataStr');
                }
              }
            },
            onError: (err) {
              debugPrint('SSE Stream Error: $err');
              onStateChange?.call(StreamConnectionState.disconnected);
              if (!isClosed) {
                reconnectTimer = Timer(const Duration(seconds: 4), connect);
              }
            },
            onDone: () {
              onStateChange?.call(StreamConnectionState.disconnected);
              if (!isClosed) {
                reconnectTimer = Timer(const Duration(seconds: 4), connect);
              }
            },
            cancelOnError: true,
          );
        } else {
          onStateChange?.call(StreamConnectionState.disconnected);
          if (!isClosed) {
            reconnectTimer = Timer(const Duration(seconds: 5), connect);
          }
        }
      } catch (err) {
        debugPrint('SSE Connection failed: $err');
        onStateChange?.call(StreamConnectionState.disconnected);
        if (!isClosed) {
          reconnectTimer = Timer(const Duration(seconds: 5), connect);
        }
      }
    }

    connect();

    return SseSubscription(
      subscription: subscription,
      client: client,
      reconnectTimer: reconnectTimer,
    );
  }
}

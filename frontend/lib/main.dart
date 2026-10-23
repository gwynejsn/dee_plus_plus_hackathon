import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'config/soft_ui_theme.dart';
import 'screens/buzzer_screen.dart';
import 'screens/counter_screen.dart';
import 'screens/display_screen.dart';
import 'screens/services_screen.dart';
import 'widgets/app_header.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NextNaApp());
}

class NextNaApp extends StatelessWidget {
  const NextNaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextNa - MSME Smart Queue & Virtual Buzzer',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: SoftUiTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;
  String _activeBuzzerTicketId = '';
  bool _isBackendOnline = false;
  Timer? _healthCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkHealth();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) => _checkHealth());
    // On web, read the ?ticket= query param to deep-link into the buzzer
    _readTicketFromUrl();
  }

  /// If the app was opened with `?ticket=<id>` (e.g. from a QR code scan),
  /// automatically switch to the Buzzer tab pre-loaded with that ticket.
  void _readTicketFromUrl() {
    if (!kIsWeb) return;
    try {
      final uri = Uri.base;
      final ticketId = uri.queryParameters['ticket'];
      if (ticketId != null && ticketId.isNotEmpty) {
        _activeBuzzerTicketId = ticketId;
        _selectedIndex = 0; // Buzzer tab
      }
    } catch (_) {
      // URI parsing failed – ignore and show default screen
    }
  }

  @override
  void dispose() {
    _healthCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    final online = await ApiService().checkBackendHealth();
    if (mounted) {
      setState(() => _isBackendOnline = online);
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openBuzzerForTicket(String ticketId) {
    setState(() {
      _activeBuzzerTicketId = ticketId;
      _selectedIndex = 0; // Switch to Buzzer screen
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeScreen;

    switch (_selectedIndex) {
      case 0:
        activeScreen = BuzzerScreen(
          initialTicketId: _activeBuzzerTicketId,
          onTicketChanged: (id) => setState(() => _activeBuzzerTicketId = id),
        );
        break;
      case 1:
        activeScreen = CounterScreen(
          onOpenBuzzer: _openBuzzerForTicket,
        );
        break;
      case 2:
        activeScreen = const DisplayScreen();
        break;
      case 3:
        activeScreen = const ServicesScreen();
        break;
      default:
        activeScreen = BuzzerScreen(
          initialTicketId: _activeBuzzerTicketId,
          onTicketChanged: (id) => setState(() => _activeBuzzerTicketId = id),
        );
    }

    return Scaffold(
      appBar: AppHeader(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
        isBackendOnline: _isBackendOnline,
      ),
      body: activeScreen,
    );
  }
}

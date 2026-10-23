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
import 'services/sound_haptics_service.dart';

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
    _readTicketFromUrl();
  }

  void _readTicketFromUrl() {
    if (!kIsWeb) return;
    try {
      final uri = Uri.base;
      final ticketId = uri.queryParameters['ticket'];
      if (ticketId != null && ticketId.isNotEmpty) {
        _activeBuzzerTicketId = ticketId;
        _selectedIndex = 0;
      }
    } catch (_) {}
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
    SoundHapticsService().triggerTapFeedback();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openBuzzerForTicket(String ticketId) {
    setState(() {
      _activeBuzzerTicketId = ticketId;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;

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
      bottomNavigationBar: isMobile ? _buildMobileBottomBar() : null,
    );
  }

  Widget _buildMobileBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: SoftUiTheme.cardBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F1E293B),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: Color(0xFFEEF2F6), width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.phone_android_rounded, 'Buzzer'),
              _buildBottomNavItem(1, Icons.storefront_rounded, 'Counter'),
              _buildBottomNavItem(2, Icons.tv_rounded, 'Display'),
              _buildBottomNavItem(3, Icons.list_alt_rounded, 'Services'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SoftUiTheme.mintLight : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? SoftUiTheme.mintDark : SoftUiTheme.textSecondary,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? SoftUiTheme.mintDark : SoftUiTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../config/soft_ui_theme.dart';
import '../models/display_board_data.dart';
import '../models/queue_summary.dart';
import '../services/api_service.dart';
import '../services/sound_haptics_service.dart';
import '../services/sse_service.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  DisplayBoardData? _data;
  int? _lastServedNumber;
  SseSubscription? _sseSubscription;
  Timer? _pollingTimer;
  StreamConnectionState _connectionState = StreamConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startSse();
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final summary = await ApiService().getQueueSummary();
      _updateFromSummary(summary);
    } catch (_) {}
  }

  void _updateFromSummary(QueueSummary summary) {
    final serving = summary.currentlyServing;
    final active = summary.activeTickets;
    final waiting = active.where((t) => t.isWaiting || t.isAlmostNext).toList();
    final almost = active.firstWhere(
      (t) => t.isAlmostNext,
      orElse: () => waiting.isNotEmpty ? waiting.first : active.first,
    );

    final waitingNumbers = waiting
        .where((t) => t.id != serving?.id && t.id != almost.id)
        .map((t) => t.ticketNumber)
        .toList();

    setState(() {
      _data = DisplayBoardData(
        currentServingNumber: serving?.ticketNumber,
        currentServingCustomer: serving?.customerName,
        almostNextNumber: almost.ticketNumber,
        almostNextCustomer: almost.customerName,
        totalWaitingCount: summary.waitingCount,
        waitingNumbers: waitingNumbers,
      );
    });
  }

  void _startSse() {
    _sseSubscription = SseService().subscribeDisplay(
      onEvent: (event) {
        if (!mounted) return;
        final payload = event.data;
        final boardData = DisplayBoardData.fromJson(payload);

        if (boardData.currentServingNumber != null &&
            boardData.currentServingNumber != _lastServedNumber) {
          SoundHapticsService().triggerNowServingFeedback();
          _lastServedNumber = boardData.currentServingNumber;
        }

        setState(() {
          _data = boardData;
        });
      },
      onStateChange: (state) {
        if (!mounted) return;
        setState(() => _connectionState = state);
        if (state == StreamConnectionState.disconnected &&
            _pollingTimer == null) {
          _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
            try {
              final summary = await ApiService().getQueueSummary();
              _updateFromSummary(summary);
            } catch (_) {}
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    final servingNumber = _data?.currentServingNumber;
    final servingCustomer = _data?.currentServingCustomer;
    final almostNumber = _data?.almostNextNumber;
    final almostCustomer = _data?.almostNextCustomer;
    final waitingNumbers = _data?.waitingNumbers ?? [];

    return Container(
      color: SoftUiTheme.background,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Store Display Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tv_rounded,
                      color: SoftUiTheme.primaryMint,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isWide ? 'STORE DISPLAY BOARD' : 'Store Display',
                        style: const TextStyle(
                          color: SoftUiTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: SoftUiTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: SoftUiTheme.subtlePillShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _connectionState == StreamConnectionState.connected
                            ? SoftUiTheme.primaryMint
                            : SoftUiTheme.amberWarning,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_connectionState ==
                                            StreamConnectionState.connected
                                        ? SoftUiTheme.primaryMint
                                        : SoftUiTheme.amberWarning)
                                    .withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Live TV Sync',
                      style: TextStyle(
                        color: SoftUiTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Layout
          Expanded(
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left 60%: NOW SERVING HERO
                      Expanded(
                        flex: 60,
                        child: _buildNowServingCard(
                          servingNumber,
                          servingCustomer,
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right 40%: ALMOST NEXT + IN LINE
                      Expanded(
                        flex: 40,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 45,
                              child: _buildAlmostNextCard(
                                almostNumber,
                                almostCustomer,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              flex: 55,
                              child: _buildInLineCard(waitingNumbers),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildNowServingCard(
                          servingNumber,
                          servingCustomer,
                          isMobile: true,
                        ),
                        const SizedBox(height: 16),
                        _buildAlmostNextCard(
                          almostNumber,
                          almostCustomer,
                          isMobile: true,
                        ),
                        const SizedBox(height: 16),
                        _buildInLineCard(
                          waitingNumbers,
                          isMobile: true,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowServingCard(
    int? number,
    String? customer, {
    bool isMobile = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 32),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: BorderRadius.circular(isMobile ? 24 : 28),
        border: Border.all(color: SoftUiTheme.primaryMint, width: isMobile ? 2.5 : 3),
        boxShadow: [
          ...SoftUiTheme.floatingHeroShadow,
          const BoxShadow(
            color: Color(0x3300D19E),
            blurRadius: 36,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 18,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: SoftUiTheme.mintLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: SoftUiTheme.primaryMint.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'NOW SERVING',
              style: TextStyle(
                color: SoftUiTheme.mintDark,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 10 : 14),
          if (number != null) ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '#$number',
                style: TextStyle(
                  color: SoftUiTheme.textPrimary,
                  fontSize: isMobile ? 88 : 120,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: -4,
                ),
              ),
            ),
            Text(
              customer ?? 'Guest Customer',
              style: TextStyle(
                color: SoftUiTheme.textPrimary,
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 12 : 18),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 18 : 22,
                vertical: isMobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: SoftUiTheme.mintLight,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: SoftUiTheme.primaryMint),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    color: SoftUiTheme.mintDark,
                    size: isMobile ? 16 : 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Counter 1',
                    style: TextStyle(
                      color: SoftUiTheme.mintDark,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 24.0 : 40.0),
              child: Text(
                'Counter Ready\nNext patron will be called shortly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SoftUiTheme.textSecondary,
                  fontSize: isMobile ? 17 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlmostNextCard(
    int? number,
    String? customer, {
    bool isMobile = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SoftUiTheme.amberWarning, width: 2),
        boxShadow: SoftUiTheme.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: SoftUiTheme.amberLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_walk_rounded,
                    color: Color(0xFFB45309),
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'ALMOST NEXT (PLEASE PREPARE)',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          if (number != null) ...[
            Text(
              '#$number',
              style: TextStyle(
                color: SoftUiTheme.textPrimary,
                fontSize: isMobile ? 44 : 54,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: -2,
              ),
            ),
            Text(
              customer ?? 'Next Customer',
              style: TextStyle(
                color: SoftUiTheme.textPrimary,
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 0),
              child: const Text(
                'No ticket on deck',
                style: TextStyle(
                  color: SoftUiTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInLineCard(
    List<int> waitingNumbers, {
    bool isMobile = false,
  }) {
    final listWidget = waitingNumbers.isEmpty
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No other patrons waiting in line',
                style: TextStyle(
                  color: SoftUiTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          )
        : (isMobile
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: waitingNumbers.map((ticketNum) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      '#$ticketNum',
                      style: const TextStyle(
                        color: SoftUiTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }).toList(),
              )
            : SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: waitingNumbers.map((ticketNum) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '#$ticketNum',
                        style: const TextStyle(
                          color: SoftUiTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: SoftUiTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      color: SoftUiTheme.primaryMint,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'IN LINE (${waitingNumbers.length})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SoftUiTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Waiting',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isMobile) listWidget else Expanded(child: listWidget),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../config/soft_ui_theme.dart';
import '../models/queue_ticket.dart';
import '../services/api_service.dart';
import '../services/sound_haptics_service.dart';
import '../services/sse_service.dart';
import '../widgets/buzzer_disc.dart';
import '../widgets/papunta_na_button.dart';

class BuzzerScreen extends StatefulWidget {
  final String? initialTicketId;
  final ValueChanged<String>? onTicketChanged;

  const BuzzerScreen({super.key, this.initialTicketId, this.onTicketChanged});

  @override
  State<BuzzerScreen> createState() => _BuzzerScreenState();
}

class _BuzzerScreenState extends State<BuzzerScreen> {
  String? _currentTicketId;
  QueueTicket? _ticket;
  List<QueueTicket> _activeTickets = [];
  bool _isLoading = false;
  bool _isSubmittingOnMyWay = false;
  bool _isIssuingDemoTicket = false;
  SseSubscription? _sseSubscription;
  Timer? _pollingTimer;
  StreamConnectionState _connectionState = StreamConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _currentTicketId = widget.initialTicketId;
    if (_currentTicketId != null && _currentTicketId!.isNotEmpty) {
      _loadTicket(_currentTicketId!);
    } else {
      _loadActiveTickets();
    }
  }

  @override
  void didUpdateWidget(covariant BuzzerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTicketId != oldWidget.initialTicketId &&
        widget.initialTicketId != _currentTicketId) {
      _currentTicketId = widget.initialTicketId;
      if (_currentTicketId != null && _currentTicketId!.isNotEmpty) {
        _loadTicket(_currentTicketId!);
      } else {
        _sseSubscription?.cancel();
        _pollingTimer?.cancel();
        setState(() {
          _ticket = null;
        });
        _loadActiveTickets();
      }
    }
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startBuzzerStream(String ticketId) {
    _sseSubscription?.cancel();
    _pollingTimer?.cancel();

    _sseSubscription = SseService().subscribeBuzzer(
      ticketId,
      onEvent: (event) {
        if (!mounted) return;
        final payload = event.data;
        final updatedTicket = QueueTicket.fromJson(payload);

        if (_ticket != null && _ticket!.state != updatedTicket.state) {
          if (updatedTicket.isNowServing) {
            SoundHapticsService().triggerNowServingFeedback();
          } else if (updatedTicket.isAlmostNext) {
            SoundHapticsService().triggerAlmostNextFeedback();
          }
        }

        setState(() {
          _ticket = updatedTicket;
        });
      },
      onStateChange: (state) {
        if (!mounted) return;
        setState(() => _connectionState = state);

        if (state == StreamConnectionState.disconnected &&
            _pollingTimer == null) {
          _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
            if (_currentTicketId != null) {
              _silentRefreshTicket(_currentTicketId!);
            }
          });
        } else if (state == StreamConnectionState.connected) {
          _pollingTimer?.cancel();
          _pollingTimer = null;
        }
      },
    );
  }

  Future<void> _loadTicket(String ticketId) async {
    setState(() => _isLoading = true);
    try {
      final ticket = await ApiService().getTicketById(ticketId);
      setState(() {
        _ticket = ticket;
        _currentTicketId = ticketId;
      });
      _startBuzzerStream(ticketId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket not found: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
      _loadActiveTickets();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _silentRefreshTicket(String ticketId) async {
    try {
      final ticket = await ApiService().getTicketById(ticketId);
      if (mounted) {
        setState(() => _ticket = ticket);
      }
    } catch (_) {}
  }

  Future<void> _loadActiveTickets() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService().getActiveTickets();
      setState(() => _activeTickets = list);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOnMyWay() async {
    if (_currentTicketId == null || _isSubmittingOnMyWay) return;
    setState(() => _isSubmittingOnMyWay = true);
    SoundHapticsService().triggerTapFeedback();

    try {
      final updated = await ApiService().confirmOnMyWay(_currentTicketId!);
      setState(() => _ticket = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Confirmed! Merchant has been notified you are on your way.',
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF00D19E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingOnMyWay = false);
    }
  }

  Future<void> _handleIssueDemoTicket() async {
    if (_isIssuingDemoTicket) return;
    setState(() => _isIssuingDemoTicket = true);
    SoundHapticsService().triggerTapFeedback();

    try {
      final services = await ApiService().getServices(activeOnly: true);
      final serviceId = services.isNotEmpty ? services.first.id : 'srv-001';

      final sampleNames = [
        'Juan Dela Cruz',
        'Maria Clara',
        'Kuya Dennis',
        'Ate Liza',
        'Paolo Roxas',
      ];
      final name = sampleNames[DateTime.now().second % sampleNames.length];

      final newTicket = await ApiService().issueTicket(
        customerName: name,
        serviceId: serviceId,
      );

      widget.onTicketChanged?.call(newTicket.id);
      _loadTicket(newTicket.id);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $err'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isIssuingDemoTicket = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTicketId == null ||
        _currentTicketId!.isEmpty ||
        _ticket == null) {
      return _buildTicketSelectorView();
    }

    final t = _ticket!;
    final peopleAhead =
        t.peopleAhead ?? (t.ticketNumber > 1 ? t.ticketNumber - 1 : 0);
    final estimatedMinutes = t.estimatedWaitMinutes;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // Header Controls (Switch Ticket & Live Sync Pill)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _sseSubscription?.cancel();
                      setState(() {
                        _currentTicketId = null;
                        _ticket = null;
                      });
                      widget.onTicketChanged?.call('');
                      _loadActiveTickets();
                    },
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: const Text('Switch Ticket'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SoftUiTheme.textPrimary,
                      backgroundColor: SoftUiTheme.cardBg,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: const Color(0x0A000000),
                      elevation: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: SoftUiTheme.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: SoftUiTheme.subtlePillShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _connectionState ==
                                        StreamConnectionState.connected
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
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _connectionState == StreamConnectionState.connected
                              ? 'Live Stream'
                              : 'Reconnecting...',
                          style: const TextStyle(
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

              const SizedBox(height: 16),

              // Alert Notification Banner
              _buildAlertBanner(t),

              const SizedBox(height: 22),

              // Hero Buzzer Disc
              BuzzerDisc(ticket: t),

              const SizedBox(height: 22),

              // Queue Metrics (People Ahead & Estimated Wait)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: SoftUiTheme.cardBg,
                        borderRadius: SoftUiTheme.cardRadius,
                        border: Border.all(color: const Color(0xFFEEF2F6)),
                        boxShadow: SoftUiTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Text(
                            t.isNowServing ? '0' : '$peopleAhead',
                            style: const TextStyle(
                              color: SoftUiTheme.primaryMint,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'People Ahead',
                            style: TextStyle(
                              color: SoftUiTheme.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: SoftUiTheme.cardBg,
                        borderRadius: SoftUiTheme.cardRadius,
                        border: Border.all(color: const Color(0xFFEEF2F6)),
                        boxShadow: SoftUiTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Text(
                            t.isNowServing ? 'Now' : '~$estimatedMinutes m',
                            style: const TextStyle(
                              color: SoftUiTheme.amberWarning,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Estimated Wait',
                            style: TextStyle(
                              color: SoftUiTheme.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Papunta Na Ako Button
              if (!t.isCompleted && !t.isCancelled) ...[
                PapuntaNaButton(
                  isConfirmed: t.onMyWayConfirmed,
                  isLoading: _isSubmittingOnMyWay,
                  onPressed: _handleOnMyWay,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap when heading back so the merchant knows not to skip your number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SoftUiTheme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBanner(QueueTicket t) {
    Color bg;
    Color border;
    Color text;
    IconData icon;
    String message;

    if (t.isNowServing) {
      bg = SoftUiTheme.mintLight;
      border = SoftUiTheme.primaryMint;
      text = SoftUiTheme.mintDark;
      icon = Icons.notifications_active_rounded;
      message =
          t.alertMessage ??
          'Your turn now! Please proceed to the service counter.';
    } else if (t.isAlmostNext) {
      bg = SoftUiTheme.amberLight;
      border = SoftUiTheme.amberWarning;
      text = const Color(0xFFB45309);
      icon = Icons.directions_walk_rounded;
      message =
          t.alertMessage ??
          'Almost your turn! Please start heading back to the shop.';
    } else if (t.isCompleted) {
      bg = const Color(0xFFF1F5F9);
      border = const Color(0xFFCBD5E1);
      text = SoftUiTheme.textSecondary;
      icon = Icons.check_circle_outline_rounded;
      message = 'Service completed. Maraming salamat sa pagbisita!';
    } else {
      bg = const Color(0xFFEFF6FF);
      border = const Color(0xFF93C5FD);
      text = const Color(0xFF1D4ED8);
      icon = Icons.hourglass_top_rounded;
      message =
          t.alertMessage ??
          'You are #${t.ticketNumber} in line. Relax while you wait!';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: SoftUiTheme.cardRadius,
        border: Border.all(color: border.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: text, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSelectorView() {
    final ticketIdController = TextEditingController();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SoftUiTheme.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEEF2F6)),
              boxShadow: SoftUiTheme.floatingHeroShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      color: SoftUiTheme.primaryMint,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Virtual Buzzer Portal',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: SoftUiTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter your Ticket ID or select from active tickets in line to open your mobile buzzer.',
                  style: TextStyle(
                    color: SoftUiTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 18),

                // Manual ID Entry
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ticketIdController,
                        style: const TextStyle(
                          color: SoftUiTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Ticket ID or UUID',
                          hintStyle: const TextStyle(
                            color: SoftUiTheme.textMuted,
                            fontSize: 12.5,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: SoftUiTheme.primaryMint,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final val = ticketIdController.text.trim();
                        if (val.isNotEmpty) {
                          widget.onTicketChanged?.call(val);
                          _loadTicket(val);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SoftUiTheme.primaryMint,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Open',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: Color(0xFFEEF2F6)),
                const SizedBox(height: 14),

                // Active Tickets Picker
                const Text(
                  'Or Select An Active Ticket in Line:',
                  style: TextStyle(
                    color: SoftUiTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),

                if (_isLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: SoftUiTheme.primaryMint,
                      ),
                    ),
                  ),
                ] else if (_activeTickets.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      'No active tickets right now. Issue a walk-in demo ticket below to test the buzzer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SoftUiTheme.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _activeTickets.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final t = _activeTickets[i];
                      return InkWell(
                        onTap: () {
                          widget.onTicketChanged?.call(t.id);
                          _loadTicket(t.id);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      '#${t.ticketNumber}',
                                      style: const TextStyle(
                                        color: SoftUiTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        t.customerName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: SoftUiTheme.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: t.isNowServing
                                      ? SoftUiTheme.mintLight
                                      : t.isAlmostNext
                                      ? SoftUiTheme.amberLight
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  t.state.displayName,
                                  style: TextStyle(
                                    color: t.isNowServing
                                        ? SoftUiTheme.mintDark
                                        : t.isAlmostNext
                                        ? const Color(0xFFB45309)
                                        : const Color(0xFF2563EB),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 18),

                // 1-Click Demo Walk-in Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isIssuingDemoTicket
                        ? null
                        : _handleIssueDemoTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SoftUiTheme.primaryMint,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: _isIssuingDemoTicket
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.flash_on_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Issue 1-Click Test Ticket (Demo)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../config/soft_ui_theme.dart';
import '../models/ai_prediction.dart';
import '../models/analytics_overview.dart';
import '../models/queue_summary.dart';
import '../models/queue_ticket.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import '../services/sound_haptics_service.dart';
import '../services/sse_service.dart';
import '../widgets/ai_advisor_card.dart';
import '../widgets/override_wait_dialog.dart';
import '../widgets/ticket_card.dart';
import '../widgets/ticket_qr_dialog.dart';
import '../widgets/walkin_ticket_dialog.dart';

class CounterScreen extends StatefulWidget {
  final ValueChanged<String>? onOpenBuzzer;

  const CounterScreen({super.key, this.onOpenBuzzer});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  QueueSummary? _summary;
  List<QueueTicket> _activeTickets = [];
  List<ServiceModel> _services = [];
  AnalyticsOverview? _analyticsOverview;
  AiPrediction? _aiPrediction;
  String? _selectedAiServiceId;

  bool _isCallingNext = false;
  bool _isLoadingAi = false;
  SseSubscription? _sseSubscription;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _startSse();
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startSse() {
    _sseSubscription = SseService().subscribeDisplay(
      onEvent: (event) {
        _refreshQueueSilently();
      },
      onStateChange: (state) {
        if (state == StreamConnectionState.disconnected &&
            _pollingTimer == null) {
          _pollingTimer = Timer.periodic(
            const Duration(seconds: 4),
            (_) => _refreshQueueSilently(),
          );
        }
      },
    );
  }

  Future<void> _loadAllData() async {
    try {
      final results = await Future.wait([
        ApiService().getQueueSummary(),
        ApiService().getActiveTickets(),
        ApiService().getServices(activeOnly: true),
        ApiService().getAnalyticsOverview(),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as QueueSummary;
          _activeTickets = results[1] as List<QueueTicket>;
          _services = results[2] as List<ServiceModel>;
          _analyticsOverview = results[3] as AnalyticsOverview;
          if (_selectedAiServiceId == null && _services.isNotEmpty) {
            _selectedAiServiceId = _services.first.id;
          }
        });
      }

      if (_selectedAiServiceId != null) {
        _fetchAiPrediction(_selectedAiServiceId!);
      }
    } catch (err) {
      debugPrint('Error loading counter data: $err');
    }
  }

  Future<void> _refreshQueueSilently() async {
    try {
      final results = await Future.wait([
        ApiService().getQueueSummary(),
        ApiService().getActiveTickets(),
        ApiService().getAnalyticsOverview(),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as QueueSummary;
          _activeTickets = results[1] as List<QueueTicket>;
          _analyticsOverview = results[2] as AnalyticsOverview;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchAiPrediction(String serviceId) async {
    setState(() => _isLoadingAi = true);
    try {
      final prediction = await ApiService().getAiPrediction(serviceId);
      if (mounted) {
        setState(() {
          _aiPrediction = prediction;
          _selectedAiServiceId = serviceId;
        });
      }
    } catch (e) {
      debugPrint('AI prediction error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAi = false);
    }
  }

  Future<void> _handleCallNext() async {
    if (_isCallingNext) return;
    setState(() => _isCallingNext = true);
    SoundHapticsService().triggerTapFeedback();

    try {
      final called = await ApiService().callNextTicket();
      SoundHapticsService().triggerNowServingFeedback();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Called Ticket #${called.ticketNumber} (${called.customerName})!',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
      _refreshQueueSilently();
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not call next ticket: $err'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCallingNext = false);
    }
  }

  Future<void> _handleTicketAction(String action, String ticketId) async {
    SoundHapticsService().triggerTapFeedback();
    try {
      if (action == 'call') await ApiService().callTicket(ticketId);
      if (action == 'serve') await ApiService().serveTicket(ticketId);
      if (action == 'complete') await ApiService().completeTicket(ticketId);
      if (action == 'cancel') await ApiService().cancelTicket(ticketId);

      _refreshQueueSilently();
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action failed: $err'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;
    final isMobile = screenWidth < 600;

    final totalActive = _summary?.totalActive ?? _activeTickets.length;
    final waitingCount =
        _summary?.waitingCount ??
        _activeTickets.where((t) => t.isWaiting || t.isAlmostNext).length;
    final servingCount =
        _summary?.servingCount ??
        _activeTickets.where((t) => t.isNowServing).length;
    final revenue = _analyticsOverview?.totalRevenuePhp ?? 0.0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 20,
          vertical: isMobile ? 14 : 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar (Responsive for Phones)
                if (isMobile) ...[
                  const Row(
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        color: SoftUiTheme.primaryMint,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Merchant Counter',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: SoftUiTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Cashier desk and active queue coordinator',
                    style: TextStyle(
                      color: SoftUiTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _openWalkInDialog(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Issue Walk-In Ticket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SoftUiTheme.primaryMint,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.storefront_rounded, color: SoftUiTheme.primaryMint, size: 26),
                              SizedBox(width: 8),
                              Text(
                                'Merchant Counter',
                                style: TextStyle(
                                  color: SoftUiTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Cashier desk and active queue coordinator',
                            style: TextStyle(
                              color: SoftUiTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openWalkInDialog(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Issue Walk-In Ticket'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SoftUiTheme.primaryMint,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // KPI Bar (2x2 Grid on Mobile, Row on Desktop)
                _buildKpiBar(totalActive, waitingCount, servingCount, revenue),

                const SizedBox(height: 16),

                // Hero Call Next Action Card
                _buildCallNextHero(waitingCount),

                const SizedBox(height: 20),

                // Main Layout Split
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 65, child: _buildQueueListSection()),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 35,
                        child: Column(
                          children: [
                            AiAdvisorCard(
                              services: _services,
                              selectedServiceId: _selectedAiServiceId,
                              prediction: _aiPrediction,
                              isLoading: _isLoadingAi,
                              onServiceSelected: (id) {
                                if (id != null) _fetchAiPrediction(id);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildOperationsSummaryCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildQueueListSection(),
                      const SizedBox(height: 18),
                      AiAdvisorCard(
                        services: _services,
                        selectedServiceId: _selectedAiServiceId,
                        prediction: _aiPrediction,
                        isLoading: _isLoadingAi,
                        onServiceSelected: (id) {
                          if (id != null) _fetchAiPrediction(id);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildOperationsSummaryCard(),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openWalkInDialog() async {
    final created = await WalkinTicketDialog.show(context, _services);
    if (created != null && mounted) {
      _refreshQueueSilently();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Issued Ticket #${created.ticketNumber} for ${created.customerName}!',
          ),
          backgroundColor: SoftUiTheme.primaryMint,
        ),
      );
      await TicketQrDialog.show(context, created);
    }
  }

  Widget _buildKpiBar(int active, int waiting, int serving, double revenue) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isSmall = constraints.maxWidth < 640;
        final cardWidth = isSmall ? (constraints.maxWidth - 12) / 2 : 180.0;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildKpiCard(
              'ACTIVE QUEUE',
              '$active',
              const Color(0xFF2563EB),
              cardWidth,
            ),
            _buildKpiCard(
              'WAITING',
              '$waiting',
              SoftUiTheme.amberWarning,
              cardWidth,
            ),
            _buildKpiCard(
              'NOW SERVING',
              '$serving',
              SoftUiTheme.primaryMint,
              cardWidth,
            ),
            _buildKpiCard(
              'TODAY\'S SALES',
              '₱${revenue.toStringAsFixed(0)}',
              const Color(0xFF9333EA),
              cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String val, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: SoftUiTheme.cardRadius,
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: SoftUiTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SoftUiTheme.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallNextHero(int waitingCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5AB), Color(0xFF00B887)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: SoftUiTheme.primaryMint.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isNarrow = constraints.maxWidth < 500;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Ready to serve next?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  waitingCount > 0
                      ? '$waitingCount customer(s) waiting in queue'
                      : 'No waiting tickets in line right now',
                  style: const TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: waitingCount > 0 && !_isCallingNext
                        ? _handleCallNext
                        : null,
                    icon: _isCallingNext
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: SoftUiTheme.mintDark,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.campaign_rounded, size: 20),
                    label: const Text(
                      'CALL NEXT TICKET',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SoftUiTheme.mintDark,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ready to serve next customer?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    waitingCount > 0
                        ? '$waitingCount customer(s) waiting in queue'
                        : 'No waiting tickets in line right now',
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: waitingCount > 0 && !_isCallingNext
                    ? _handleCallNext
                    : null,
                icon: _isCallingNext
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: SoftUiTheme.mintDark,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.campaign_rounded, size: 20),
                label: const Text(
                  'CALL NEXT TICKET',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: SoftUiTheme.mintDark,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQueueListSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: SoftUiTheme.cardRadius,
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: SoftUiTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.list_alt_rounded,
                    color: SoftUiTheme.primaryMint,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Active Queue Line',
                    style: TextStyle(
                      color: SoftUiTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_activeTickets.length}',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _refreshQueueSilently,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                  foregroundColor: SoftUiTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_activeTickets.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    color: SoftUiTheme.primaryMint,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All caught up! No active tickets in queue.',
                    style: TextStyle(
                      color: SoftUiTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeTickets.length,
              itemBuilder: (ctx, i) {
                final t = _activeTickets[i];
                return TicketCard(
                  ticket: t,
                  onCall: () => _handleTicketAction('call', t.id),
                  onServe: () => _handleTicketAction('serve', t.id),
                  onComplete: () => _handleTicketAction('complete', t.id),
                  onCancel: () => _handleTicketAction('cancel', t.id),
                  onOverrideWait: () async {
                    final newMins = await OverrideWaitDialog.show(
                      context,
                      t.id,
                      t.estimatedWaitMinutes,
                    );
                    if (newMins == true && mounted) {
                      _refreshQueueSilently();
                    }
                  },
                  onOpenBuzzer: () {
                    widget.onOpenBuzzer?.call(t.id);
                  },
                  onShowQr: () {
                    TicketQrDialog.show(context, t);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOperationsSummaryCard() {
    final avgWait = (_analyticsOverview?.averageDurationMinutes ?? 15)
        .toDouble();
    final totalCompleted = _analyticsOverview?.completedTicketsCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: SoftUiTheme.cardRadius,
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: SoftUiTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: SoftUiTheme.primaryMint,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Shift Operations Metrics',
                style: TextStyle(
                  color: SoftUiTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Avg Turnaround Time',
                style: TextStyle(
                  color: SoftUiTheme.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              Text(
                '${avgWait.toStringAsFixed(1)} mins',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: SoftUiTheme.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Customers Served',
                style: TextStyle(
                  color: SoftUiTheme.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              Text(
                '$totalCompleted',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: SoftUiTheme.primaryMint,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

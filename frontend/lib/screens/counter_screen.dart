import 'dart:async';
import 'package:flutter/material.dart';
import '../config/soft_ui_theme.dart';
import '../models/queue_ticket.dart';
import '../models/queue_summary.dart';
import '../models/service_model.dart';
import '../models/ai_prediction.dart';
import '../models/analytics_overview.dart';
import '../services/api_service.dart';
import '../services/sse_service.dart';
import '../services/sound_haptics_service.dart';
import '../widgets/ticket_card.dart';
import '../widgets/ai_advisor_card.dart';
import '../widgets/walkin_ticket_dialog.dart';
import '../widgets/override_wait_dialog.dart';
import '../widgets/ticket_qr_dialog.dart';

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

  bool _isLoading = false;
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
        // Any queue update triggers instant silent refresh
        _refreshQueueSilently();
      },
      onStateChange: (state) {
        if (state == StreamConnectionState.disconnected && _pollingTimer == null) {
          _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _refreshQueueSilently());
        }
      },
    );
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService().getQueueSummary(),
        ApiService().getActiveTickets(),
        ApiService().getServices(activeOnly: true),
        ApiService().getAnalyticsOverview(),
      ]);

      setState(() {
        _summary = results[0] as QueueSummary;
        _activeTickets = results[1] as List<QueueTicket>;
        _services = results[2] as List<ServiceModel>;
        _analyticsOverview = results[3] as AnalyticsOverview;
        if (_selectedAiServiceId == null && _services.isNotEmpty) {
          _selectedAiServiceId = _services.first.id;
        }
      });

      if (_selectedAiServiceId != null) {
        _fetchAiPrediction(_selectedAiServiceId!);
      }
    } catch (err) {
      debugPrint('Error loading counter data: $err');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            content: Text('📢 Called Ticket #${called.ticketNumber} (${called.customerName})!'),
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

    final totalActive = _summary?.totalActive ?? _activeTickets.length;
    final waitingCount = _summary?.waitingCount ?? _activeTickets.where((t) => t.isWaiting || t.isAlmostNext).length;
    final servingCount = _summary?.servingCount ?? _activeTickets.where((t) => t.isNowServing).length;
    final revenue = _analyticsOverview?.totalRevenuePhp ?? 0.0;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🏪 Merchant Counter',
                          style: TextStyle(
                            color: SoftUiTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Cashier desk and active queue coordinator',
                          style: TextStyle(color: SoftUiTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final created = await WalkinTicketDialog.show(context, _services);
                        if (created != null && mounted) {
                          _refreshQueueSilently();
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Issued Ticket #${created.ticketNumber} for ${created.customerName}!'),
                              backgroundColor: SoftUiTheme.primaryMint,
                            ),
                          );
                          // Show QR code for the customer to scan their queue number
                          // ignore: use_build_context_synchronously
                          await TicketQrDialog.show(context, created);
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Issue Walk-In Ticket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SoftUiTheme.primaryMint,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // KPI Bar
                _buildKpiBar(totalActive, waitingCount, servingCount, revenue),

                const SizedBox(height: 18),

                // Hero Call Next Action Card
                _buildCallNextHero(waitingCount),

                const SizedBox(height: 22),

                // Main Layout Split
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Queue List (Left 65%)
                      Expanded(
                        flex: 65,
                        child: _buildQueueListSection(),
                      ),
                      const SizedBox(width: 20),
                      // AI & Financials (Right 35%)
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
                      const SizedBox(height: 20),
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

  Widget _buildKpiBar(int active, int waiting, int serving, double revenue) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isSmall = constraints.maxWidth < 600;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildKpiCard('ACTIVE QUEUE', '$active', const Color(0xFF2563EB), isSmall),
            _buildKpiCard('WAITING', '$waiting', SoftUiTheme.amberWarning, isSmall),
            _buildKpiCard('NOW SERVING', '$serving', SoftUiTheme.primaryMint, isSmall),
            _buildKpiCard('TODAY\'S SALES', '₱${revenue.toStringAsFixed(0)}', const Color(0xFF9333EA), isSmall),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String val, Color color, bool isSmall) {
    return Container(
      width: isSmall ? double.infinity : 180,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: SoftUiTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 26,
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: SoftUiTheme.floatingHeroShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Advance The Line',
                  style: TextStyle(
                    color: SoftUiTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  waitingCount > 0 
                      ? '$waitingCount customer(s) waiting. Calls next number and buzzes their phone.'
                      : 'No waiting customers in line right now.',
                  style: const TextStyle(color: SoftUiTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ElevatedButton.icon(
            onPressed: (waitingCount == 0 || _isCallingNext) ? null : _handleCallNext,
            icon: _isCallingNext
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.campaign_rounded, size: 20),
            label: Text(_isCallingNext ? 'Calling...' : 'CALL NEXT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SoftUiTheme.primaryMint,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueListSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Text(
                '📋 Active Tickets (${_activeTickets.length})',
                style: const TextStyle(
                  color: SoftUiTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: SoftUiTheme.textSecondary, size: 20),
                onPressed: _refreshQueueSilently,
                tooltip: 'Refresh Queue',
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_activeTickets.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Text('🛋️', style: TextStyle(fontSize: 36)),
                  SizedBox(height: 10),
                  Text(
                    'No active tickets in queue.',
                    style: TextStyle(
                      color: SoftUiTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All customers have been served. Tap "Issue Walk-In Ticket" to queue a new patron.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SoftUiTheme.textSecondary, fontSize: 13),
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
                    final res = await OverrideWaitDialog.show(context, t.id, t.estimatedWaitMinutes);
                    if (res == true) _refreshQueueSilently();
                  },
                  onOpenBuzzer: () {
                    widget.onOpenBuzzer?.call(t.id);
                  },
                  onShowQr: () => TicketQrDialog.show(context, t),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOperationsSummaryCard() {
    final overview = _analyticsOverview;
    final completedCount = overview?.completedTicketsCount ?? 0;
    final totalSales = overview?.totalRevenuePhp ?? 0.0;
    final avgDuration = overview?.averageDurationMinutes ?? 18;

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Text(
                '📊 Daily Telemetry',
                style: TextStyle(
                  color: SoftUiTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SoftUiTheme.mintLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TODAY',
                  style: TextStyle(
                    color: SoftUiTheme.mintDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTelemetryRow('Services Completed', '$completedCount patrons'),
          _buildTelemetryRow('Total Revenue', '₱${totalSales.toStringAsFixed(0)}', color: SoftUiTheme.primaryMint),
          _buildTelemetryRow('Avg Service Time', '$avgDuration mins'),
          _buildTelemetryRow('Walk-In Retention', '94.2% (Estimated)', color: SoftUiTheme.amberWarning),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String val, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: SoftUiTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(
            val,
            style: TextStyle(
              color: color ?? SoftUiTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

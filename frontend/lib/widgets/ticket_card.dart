import 'package:flutter/material.dart';

import '../config/soft_ui_theme.dart';
import '../models/queue_ticket.dart';

class TicketCard extends StatelessWidget {
  final QueueTicket ticket;
  final VoidCallback onCall;
  final VoidCallback onServe;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onOverrideWait;
  final VoidCallback onOpenBuzzer;
  final VoidCallback? onShowQr;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onCall,
    required this.onServe,
    required this.onComplete,
    required this.onCancel,
    required this.onOverrideWait,
    required this.onOpenBuzzer,
    this.onShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final state = ticket.state;
    final isServing = state == TicketState.nowServing;
    final isAlmost = state == TicketState.almostNext;

    Color stateColor = SoftUiTheme.primaryMint;
    Color stateBg = SoftUiTheme.mintLight;

    if (isServing) {
      stateColor = SoftUiTheme.primaryMint;
      stateBg = SoftUiTheme.mintLight;
    } else if (isAlmost) {
      stateColor = SoftUiTheme.amberWarning;
      stateBg = SoftUiTheme.amberLight;
    } else if (state == TicketState.waiting) {
      stateColor = const Color(0xFF2563EB);
      stateBg = const Color(0xFFEFF6FF);
    } else if (state == TicketState.completed) {
      stateColor = SoftUiTheme.textSecondary;
      stateBg = const Color(0xFFF1F5F9);
    } else if (state == TicketState.cancelled) {
      stateColor = SoftUiTheme.redDanger;
      stateBg = SoftUiTheme.redLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        borderRadius: SoftUiTheme.cardRadius,
        border: Border.all(
          color: isServing ? SoftUiTheme.primaryMint : const Color(0xFFEEF2F6),
          width: isServing ? 2 : 1,
        ),
        boxShadow: [
          ...SoftUiTheme.cardShadow,
          if (isServing)
            const BoxShadow(
              color: Color(0x3300D19E),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Ticket Number, Customer Name, and Status Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Neumorphic Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: stateBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: stateColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '#${ticket.ticketNumber}',
                    style: TextStyle(
                      color: stateColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.customerName,
                        style: const TextStyle(
                          color: SoftUiTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ticket.serviceName} • ₱${ticket.servicePrice.toStringAsFixed(0)} • ~${ticket.estimatedWaitMinutes}m',
                        style: const TextStyle(
                          color: SoftUiTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // State Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: stateBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: stateColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    state.displayName,
                    style: TextStyle(
                      color: stateColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            // PAPUNTA NA AKO BADGE (Dedicated Banner if confirmed)
            if (ticket.onMyWayConfirmed) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: SoftUiTheme.mintLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SoftUiTheme.primaryMint,
                    width: 1.2,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🚶', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 6),
                    Text(
                      'Customer tapped "Papunta Na Ako" — heading to counter!',
                      style: TextStyle(
                        color: SoftUiTheme.mintDark,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (!isServing) ...[
                  ElevatedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.campaign_rounded, size: 15),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onServe,
                    icon: const Icon(Icons.play_arrow_rounded, size: 15),
                    label: const Text('Serve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SoftUiTheme.primaryMint,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_rounded, size: 15),
                    label: const Text('Done (Complete)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SoftUiTheme.primaryMint,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],

                OutlinedButton.icon(
                  onPressed: onOpenBuzzer,
                  icon: const Icon(
                    Icons.phone_android_rounded,
                    size: 14,
                    color: SoftUiTheme.primaryMint,
                  ),
                  label: const Text('Buzzer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SoftUiTheme.mintDark,
                    backgroundColor: SoftUiTheme.mintLight,
                    side: BorderSide(
                      color: SoftUiTheme.primaryMint.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                if (onShowQr != null)
                  OutlinedButton.icon(
                    onPressed: onShowQr,
                    icon: const Icon(
                      Icons.qr_code_rounded,
                      size: 14,
                      color: SoftUiTheme.textSecondary,
                    ),
                    label: const Text('QR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SoftUiTheme.textPrimary,
                      backgroundColor: const Color(0xFFF8FAFC),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                OutlinedButton.icon(
                  onPressed: onOverrideWait,
                  icon: const Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: SoftUiTheme.textSecondary,
                  ),
                  label: const Text('Wait ETA'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SoftUiTheme.textPrimary,
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: SoftUiTheme.redDanger,
                  ),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SoftUiTheme.redDanger,
                    backgroundColor: SoftUiTheme.redLight,
                    side: BorderSide(
                      color: SoftUiTheme.redDanger.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

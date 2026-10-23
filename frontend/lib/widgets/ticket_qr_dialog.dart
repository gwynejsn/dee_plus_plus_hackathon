import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/soft_ui_theme.dart';
import '../models/queue_ticket.dart';

/// A dialog that displays a QR code for a newly issued queue ticket.
/// The customer scans the QR code to open their virtual buzzer on their phone.
class TicketQrDialog extends StatelessWidget {
  final QueueTicket ticket;

  const TicketQrDialog({super.key, required this.ticket});

  String get _buzzerUrl {
    if (kIsWeb) {
      try {
        final base = Uri.base;
        final origin =
            '${base.scheme}://${base.host}${base.port != 80 && base.port != 443 && base.port != 0 ? ":${base.port}" : ""}';
        return '$origin/?ticket=${ticket.id}';
      } catch (_) {}
    }
    return 'https://nextna-frontend.onrender.com/?ticket=${ticket.id}';
  }

  static Future<void> show(BuildContext context, QueueTicket ticket) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => TicketQrDialog(ticket: ticket),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = _buzzerUrl;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SoftUiTheme.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEEF2F6)),
            boxShadow: SoftUiTheme.floatingHeroShadow,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            color: SoftUiTheme.primaryMint,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Scan Your Queue Ticket',
                              style: TextStyle(
                                color: SoftUiTheme.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: SoftUiTheme.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 2),
                const Text(
                  'Show this QR to the customer so they can track their queue status live on their phone.',
                  style: TextStyle(
                    color: SoftUiTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Ticket Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
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
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ticket.serviceName,
                              style: const TextStyle(
                                color: SoftUiTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: SoftUiTheme.mintLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: SoftUiTheme.primaryMint.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '#${ticket.ticketNumber}',
                          style: const TextStyle(
                            color: SoftUiTheme.primaryMint,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // QR Code in soft container
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 180,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF1E293B),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Scan instruction
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      color: SoftUiTheme.primaryMint,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Scan to open Virtual Buzzer on your phone',
                        style: TextStyle(
                          color: SoftUiTheme.mintDark,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Estimated Wait Info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: SoftUiTheme.amberLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: SoftUiTheme.amberWarning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⏱️', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated Wait: ~${ticket.estimatedWaitMinutes} mins',
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Copy URL Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Buzzer link copied to clipboard!'),
                              ),
                            ],
                          ),
                          backgroundColor: SoftUiTheme.primaryMint,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: const Text('Copy Buzzer Link'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SoftUiTheme.textPrimary,
                      backgroundColor: const Color(0xFFF8FAFC),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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

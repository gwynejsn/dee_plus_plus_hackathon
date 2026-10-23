import 'package:flutter/material.dart';
import '../config/soft_ui_theme.dart';
import '../models/service_model.dart';
import '../models/queue_ticket.dart';
import '../services/api_service.dart';

class WalkinTicketDialog extends StatefulWidget {
  final List<ServiceModel> services;

  const WalkinTicketDialog({super.key, required this.services});

  static Future<QueueTicket?> show(BuildContext context, List<ServiceModel> services) {
    return showDialog<QueueTicket>(
      context: context,
      builder: (ctx) => WalkinTicketDialog(services: services),
    );
  }

  @override
  State<WalkinTicketDialog> createState() => _WalkinTicketDialogState();
}

class _WalkinTicketDialogState extends State<WalkinTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _waitOverrideController = TextEditingController();
  String? _selectedServiceId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.services.isNotEmpty) {
      _selectedServiceId = widget.services.first.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _waitOverrideController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedServiceId == null) return;

    setState(() => _isSubmitting = true);

    try {
      final overrideText = _waitOverrideController.text.trim();
      final manualWait = overrideText.isNotEmpty ? int.tryParse(overrideText) : null;

      final ticket = await ApiService().issueTicket(
        customerName: _nameController.text.trim(),
        serviceId: _selectedServiceId!,
        manualWaitMinutesOverride: manualWait,
      );

      if (mounted) {
        Navigator.of(context).pop(ticket);
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to issue ticket: $err'),
            backgroundColor: SoftUiTheme.redDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SoftUiTheme.cardBg,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      shadowColor: const Color(0x3312263F),
      elevation: 20,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '➕ Issue Walk-In Ticket',
                      style: TextStyle(
                        color: SoftUiTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: SoftUiTheme.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Customer Name
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: SoftUiTheme.textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Customer Name *',
                    hintText: 'e.g. Juan Dela Cruz or Kuya Rey',
                    hintStyle: const TextStyle(color: SoftUiTheme.textMuted),
                    labelStyle: const TextStyle(color: SoftUiTheme.textSecondary),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: SoftUiTheme.primaryMint, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Customer name is required';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Service Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedServiceId,
                  decoration: InputDecoration(
                    labelText: 'Select Service Offering *',
                    labelStyle: const TextStyle(color: SoftUiTheme.textSecondary),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: SoftUiTheme.primaryMint, width: 2),
                    ),
                  ),
                  dropdownColor: SoftUiTheme.cardBg,
                  style: const TextStyle(color: SoftUiTheme.textPrimary, fontWeight: FontWeight.w600),
                  items: widget.services.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.id,
                      child: Text('${s.name} — ₱${s.unitPrice.toStringAsFixed(0)} (~${s.baselineDurationMinutes}m)'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedServiceId = v),
                ),

                const SizedBox(height: 16),

                // Optional Wait Time Override
                TextFormField(
                  controller: _waitOverrideController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: SoftUiTheme.textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Manual Wait Time Estimate (Optional)',
                    hintText: 'Leave blank to use default baseline duration',
                    hintStyle: const TextStyle(color: SoftUiTheme.textMuted),
                    labelStyle: const TextStyle(color: SoftUiTheme.textSecondary),
                    suffixText: 'mins',
                    suffixStyle: const TextStyle(color: SoftUiTheme.textSecondary),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: SoftUiTheme.primaryMint, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: SoftUiTheme.textSecondary,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SoftUiTheme.primaryMint,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Issue Ticket Now', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

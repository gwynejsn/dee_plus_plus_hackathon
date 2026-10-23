import 'package:flutter/material.dart';
import '../config/soft_ui_theme.dart';
import '../services/api_service.dart';

class OverrideWaitDialog extends StatefulWidget {
  final String ticketId;
  final int currentMinutes;

  const OverrideWaitDialog({
    super.key,
    required this.ticketId,
    required this.currentMinutes,
  });

  static Future<bool?> show(BuildContext context, String ticketId, int currentMinutes) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => OverrideWaitDialog(ticketId: ticketId, currentMinutes: currentMinutes),
    );
  }

  @override
  State<OverrideWaitDialog> createState() => _OverrideWaitDialogState();
}

class _OverrideWaitDialogState extends State<OverrideWaitDialog> {
  late TextEditingController _controller;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentMinutes.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final mins = int.tryParse(_controller.text.trim());
    if (mins == null || mins <= 0) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiService().overrideWaitTime(widget.ticketId, mins);
      if (mounted) Navigator.of(context).pop(true);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update wait time: $err'),
            backgroundColor: SoftUiTheme.redDanger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⏱️ Override Estimated Wait',
                style: TextStyle(
                  color: SoftUiTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(color: SoftUiTheme.textPrimary, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'New Estimated Wait Time',
                  suffixText: 'mins',
                  suffixStyle: const TextStyle(color: SoftUiTheme.textSecondary),
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
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(foregroundColor: SoftUiTheme.textSecondary),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SoftUiTheme.primaryMint,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save Override', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

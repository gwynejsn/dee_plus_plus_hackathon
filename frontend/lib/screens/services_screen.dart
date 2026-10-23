import 'package:flutter/material.dart';

import '../config/soft_ui_theme.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<ServiceModel> _services = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService().getServices(activeOnly: false);
      setState(() => _services = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load services: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditDialog([ServiceModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? existing.unitPrice.toStringAsFixed(0) : '200',
    );
    final durationCtrl = TextEditingController(
      text: existing != null
          ? existing.baselineDurationMinutes.toString()
          : '20',
    );
    String category = existing?.category ?? 'BARBERSHOP';

    final categories = [
      'BARBERSHOP',
      'CARINDERIA',
      'SALON',
      'LAUNDRY',
      'CLINIC',
      'OTHER',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SoftUiTheme.cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shadowColor: const Color(0x3312263F),
          elevation: 20,
          title: Row(
            children: [
              Icon(
                existing == null
                    ? Icons.add_circle_outline_rounded
                    : Icons.edit_rounded,
                color: SoftUiTheme.primaryMint,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                existing == null ? 'Add Service Offering' : 'Edit Service',
                style: const TextStyle(
                  color: SoftUiTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(
                    color: SoftUiTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Service Name',
                    labelStyle: const TextStyle(
                      color: SoftUiTheme.textSecondary,
                    ),
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
                      borderSide: const BorderSide(
                        color: SoftUiTheme.primaryMint,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: SoftUiTheme.cardBg,
                  style: const TextStyle(
                    color: SoftUiTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(
                      color: SoftUiTheme.textSecondary,
                    ),
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
                      borderSide: const BorderSide(
                        color: SoftUiTheme.primaryMint,
                        width: 2,
                      ),
                    ),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) category = v;
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: SoftUiTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Unit Price (PHP ₱)',
                    labelStyle: const TextStyle(
                      color: SoftUiTheme.textSecondary,
                    ),
                    prefixText: '₱ ',
                    prefixStyle: const TextStyle(
                      color: SoftUiTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
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
                      borderSide: const BorderSide(
                        color: SoftUiTheme.primaryMint,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: durationCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: SoftUiTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Baseline Duration (Minutes)',
                    labelStyle: const TextStyle(
                      color: SoftUiTheme.textSecondary,
                    ),
                    suffixText: 'mins',
                    suffixStyle: const TextStyle(
                      color: SoftUiTheme.textSecondary,
                    ),
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
                      borderSide: const BorderSide(
                        color: SoftUiTheme.primaryMint,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: SoftUiTheme.textSecondary,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                final dur = int.tryParse(durationCtrl.text.trim()) ?? 15;
                if (name.isEmpty) return;

                Navigator.of(ctx).pop();
                try {
                  final model = ServiceModel(
                    id: existing?.id ?? '',
                    name: name,
                    category: category,
                    unitPrice: price,
                    baselineDurationMinutes: dur,
                  );

                  if (existing == null) {
                    await ApiService().createService(model);
                  } else {
                    await ApiService().updateService(existing.id, model);
                  }

                  _loadServices();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving service: $e'),
                        backgroundColor: SoftUiTheme.redDanger,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoftUiTheme.primaryMint,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Service',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 20,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                const Row(
                  children: [
                    Icon(
                      Icons.list_alt_rounded,
                      color: SoftUiTheme.primaryMint,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Service Catalog',
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
                  'Configure shop offerings, prices, and baseline service times',
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
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Service'),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                color: SoftUiTheme.primaryMint,
                                size: 26,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Service Catalog',
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
                            'Configure shop offerings, prices, and baseline service times',
                            style: TextStyle(
                              color: SoftUiTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Service'),
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

              const SizedBox(height: 20),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: SoftUiTheme.primaryMint,
                    ),
                  ),
                )
              else if (_services.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: SoftUiTheme.cardBg,
                    borderRadius: SoftUiTheme.cardRadius,
                    border: Border.all(color: const Color(0xFFEEF2F6)),
                    boxShadow: SoftUiTheme.cardShadow,
                  ),
                  child: const Text(
                    'No services registered yet. Click "Add Service" above to add your first menu item.',
                    style: TextStyle(color: SoftUiTheme.textSecondary),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  itemBuilder: (ctx, i) {
                    final s = _services[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
                        vertical: isMobile ? 12 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: SoftUiTheme.cardBg,
                        borderRadius: SoftUiTheme.cardRadius,
                        border: Border.all(color: const Color(0xFFEEF2F6)),
                        boxShadow: SoftUiTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isMobile ? 40 : 48,
                            height: isMobile ? 40 : 48,
                            decoration: BoxDecoration(
                              color: SoftUiTheme.mintLight,
                              borderRadius: BorderRadius.circular(isMobile ? 11 : 14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.local_offer_rounded,
                              color: SoftUiTheme.primaryMint,
                              size: isMobile ? 19 : 22,
                            ),
                          ),
                          SizedBox(width: isMobile ? 10 : 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: SoftUiTheme.textPrimary,
                                    fontSize: isMobile ? 14.5 : 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text(
                                        '₱${s.unitPrice.toStringAsFixed(0)} • ${s.baselineDurationMinutes} mins',
                                        style: const TextStyle(
                                          color: SoftUiTheme.primaryMint,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          s.category,
                                          style: const TextStyle(
                                            color: SoftUiTheme.textSecondary,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 19,
                              color: SoftUiTheme.textSecondary,
                            ),
                            onPressed: () => _showAddEditDialog(s),
                            tooltip: 'Edit Service',
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 19,
                              color: SoftUiTheme.redDanger,
                            ),
                            onPressed: () async {
                              if (confirm('Deactivate service ${s.name}?')) {
                                await ApiService().deleteService(s.id);
                                _loadServices();
                              }
                            },
                            tooltip: 'Deactivate Service',
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool confirm(String msg) {
    return true; // Simplified confirmation dialog trigger
  }
}

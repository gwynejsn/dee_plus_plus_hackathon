import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../config/soft_ui_theme.dart';
import '../services/sound_haptics_service.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool isBackendOnline;

  const AppHeader({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.isBackendOnline,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  void _showEnvironmentDialog(BuildContext context) {
    final customUrlController = TextEditingController(text: ApiConfig.baseUrl);

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
          elevation: 16,
          title: const Row(
            children: [
              Icon(Icons.dns_rounded, color: SoftUiTheme.primaryMint),
              SizedBox(width: 10),
              Text(
                'Backend Environment',
                style: TextStyle(
                  color: SoftUiTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select the target Spring Boot backend server:',
                style: TextStyle(color: SoftUiTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),

              // Live Render Option
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  title: const Text(
                    'Live Cloud Backend (Render)',
                    style: TextStyle(color: SoftUiTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    ApiConfig.liveCloudUrl,
                    style: TextStyle(color: SoftUiTheme.textSecondary, fontSize: 12),
                  ),
                  leading: Radio<String>(
                    value: ApiConfig.liveCloudUrl,
                    groupValue: ApiConfig.baseUrl,
                    activeColor: SoftUiTheme.primaryMint,
                    onChanged: (v) {
                      if (v != null) {
                        ApiConfig.setBaseUrl(v);
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ),
              ),

              // Localhost Option
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  title: const Text(
                    'Local Development (Port 8080)',
                    style: TextStyle(color: SoftUiTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    ApiConfig.localDevUrl,
                    style: TextStyle(color: SoftUiTheme.textSecondary, fontSize: 12),
                  ),
                  leading: Radio<String>(
                    value: ApiConfig.localDevUrl,
                    groupValue: ApiConfig.baseUrl,
                    activeColor: SoftUiTheme.primaryMint,
                    onChanged: (v) {
                      if (v != null) {
                        ApiConfig.setBaseUrl(v);
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                ),
              ),

              TextField(
                controller: customUrlController,
                style: const TextStyle(color: SoftUiTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Custom Server URL',
                  labelStyle: const TextStyle(color: SoftUiTheme.textSecondary),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: SoftUiTheme.primaryMint, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: SoftUiTheme.textSecondary, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                final url = customUrlController.text.trim();
                if (url.isNotEmpty) {
                  ApiConfig.setBaseUrl(url);
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoftUiTheme.primaryMint,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                elevation: 0,
              ),
              child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 768;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: SoftUiTheme.cardBg,
        boxShadow: [
          const BoxShadow(
            color: Color(0x0A1E293B),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEEF2F6), width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Logo & Title
            InkWell(
              onTap: () => onTabSelected(0),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5AB), Color(0xFF00D19E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: SoftUiTheme.buttonShadow,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'N',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isCompact || screenWidth > 500) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'NextNa',
                              style: TextStyle(
                                color: SoftUiTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SoftUiTheme.mintLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: SoftUiTheme.primaryMint.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'MSME PILA',
                                style: TextStyle(
                                  color: SoftUiTheme.mintDark,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Smart Queue & Virtual Buzzer',
                          style: TextStyle(
                            color: SoftUiTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Navigation Tabs + Actions
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Neumorphic Nav pill container
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNavTab(0, '📱', isCompact ? '' : 'Buzzer', selectedIndex == 0),
                          _buildNavTab(1, '🏪', isCompact ? '' : 'Counter', selectedIndex == 1),
                          _buildNavTab(2, '📺', isCompact ? '' : 'Display', selectedIndex == 2),
                          _buildNavTab(3, '📋', isCompact ? '' : 'Services', selectedIndex == 3),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Sound Toggle Button
                    ValueListenableBuilder<bool>(
                      valueListenable: SoundHapticsService().soundEnabledNotifier,
                      builder: (ctx, soundEnabled, _) {
                        return Container(
                          decoration: BoxDecoration(
                            color: soundEnabled ? SoftUiTheme.mintLight : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                              color: soundEnabled ? SoftUiTheme.mintDark : SoftUiTheme.textSecondary,
                              size: 19,
                            ),
                            tooltip: soundEnabled ? 'Mute Chimes' : 'Unmute Chimes',
                            onPressed: () => SoundHapticsService().toggleSound(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    // Environment Switcher / Status Pill
                    ValueListenableBuilder<String>(
                      valueListenable: ApiConfig.baseUrlNotifier,
                      builder: (ctx, url, _) {
                        final isLocal = ApiConfig.isLocal;
                        return InkWell(
                          onTap: () => _showEnvironmentDialog(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: SoftUiTheme.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A0F172A),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isBackendOnline ? SoftUiTheme.primaryMint : SoftUiTheme.redDanger,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isBackendOnline ? SoftUiTheme.primaryMint : SoftUiTheme.redDanger).withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isLocal ? 'Local:8080' : 'Render Live',
                                  style: const TextStyle(
                                    color: SoftUiTheme.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab(int index, String icon, String label, bool isActive) {
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? SoftUiTheme.primaryMint : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  const BoxShadow(
                    color: Color(0x4000D19E),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : SoftUiTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

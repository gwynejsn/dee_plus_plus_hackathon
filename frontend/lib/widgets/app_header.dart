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
  Size get preferredSize => const Size.fromHeight(64);

  void _showEnvironmentDialog(BuildContext context) {
    final customUrlController = TextEditingController(text: ApiConfig.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final currentBase = ApiConfig.baseUrl;

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
                    'Backend Server',
                    style: TextStyle(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select the target Spring Boot backend server:',
                      style: TextStyle(
                        color: SoftUiTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Live Render Option
                    InkWell(
                      onTap: () {
                        ApiConfig.setBaseUrl(ApiConfig.liveCloudUrl);
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: currentBase == ApiConfig.liveCloudUrl
                              ? SoftUiTheme.mintLight
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: currentBase == ApiConfig.liveCloudUrl
                                ? SoftUiTheme.primaryMint
                                : const Color(0xFFE2E8F0),
                            width: currentBase == ApiConfig.liveCloudUrl ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              currentBase == ApiConfig.liveCloudUrl
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: currentBase == ApiConfig.liveCloudUrl
                                  ? SoftUiTheme.primaryMint
                                  : SoftUiTheme.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Live Cloud (Render)',
                                    style: TextStyle(
                                      color: SoftUiTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    ApiConfig.liveCloudUrl,
                                    style: TextStyle(
                                      color: SoftUiTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Localhost Option
                    InkWell(
                      onTap: () {
                        ApiConfig.setBaseUrl(ApiConfig.localDevUrl);
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: currentBase == ApiConfig.localDevUrl
                              ? SoftUiTheme.mintLight
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: currentBase == ApiConfig.localDevUrl
                                ? SoftUiTheme.primaryMint
                                : const Color(0xFFE2E8F0),
                            width: currentBase == ApiConfig.localDevUrl ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              currentBase == ApiConfig.localDevUrl
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: currentBase == ApiConfig.localDevUrl
                                  ? SoftUiTheme.primaryMint
                                  : SoftUiTheme.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Local Development (Port 8080)',
                                    style: TextStyle(
                                      color: SoftUiTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    ApiConfig.localDevUrl,
                                    style: TextStyle(
                                      color: SoftUiTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    TextField(
                      controller: customUrlController,
                      style: const TextStyle(
                        color: SoftUiTheme.textPrimary,
                        fontSize: 13,
                      ),
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: SoftUiTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 850;
    final isVerySmall = screenWidth < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 8,
      ),
      decoration: const BoxDecoration(
        color: SoftUiTheme.cardBg,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A1E293B),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
        border: Border(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isMobile ? 32 : 40,
                    height: isMobile ? 32 : 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5AB), Color(0xFF00D19E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                      boxShadow: SoftUiTheme.buttonShadow,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'N',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 18 : 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'NextNa',
                    style: TextStyle(
                      color: SoftUiTheme.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (!isVerySmall) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SoftUiTheme.mintLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: SoftUiTheme.primaryMint.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: const Text(
                        'PILA',
                        style: TextStyle(
                          color: SoftUiTheme.mintDark,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Desktop Navigation Tabs (Hidden on mobile phones)
            if (!isMobile) ...[
              Container(
                padding: const EdgeInsets.all(4),
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
                    _buildNavTab(0, Icons.phone_android_rounded, 'Buzzer', selectedIndex == 0),
                    _buildNavTab(1, Icons.storefront_rounded, 'Counter', selectedIndex == 1),
                    _buildNavTab(2, Icons.tv_rounded, 'Display', selectedIndex == 2),
                    _buildNavTab(3, Icons.list_alt_rounded, 'Services', selectedIndex == 3),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],

            // Sound Toggle Button
            ValueListenableBuilder<bool>(
              valueListenable: SoundHapticsService().soundEnabledNotifier,
              builder: (ctx, soundEnabled, _) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: soundEnabled
                        ? SoftUiTheme.mintLight
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: soundEnabled
                          ? SoftUiTheme.mintDark
                          : SoftUiTheme.textSecondary,
                      size: 16,
                    ),
                    tooltip: soundEnabled ? 'Mute Chimes' : 'Unmute Chimes',
                    onPressed: () => SoundHapticsService().toggleSound(),
                  ),
                );
              },
            ),

            const SizedBox(width: 6),

            // Environment Switcher / Status Pill
            ValueListenableBuilder<String>(
              valueListenable: ApiConfig.baseUrlNotifier,
              builder: (ctx, url, _) {
                final isLocal = ApiConfig.isLocal;
                return InkWell(
                  onTap: () => _showEnvironmentDialog(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: SoftUiTheme.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
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
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isBackendOnline
                                ? SoftUiTheme.primaryMint
                                : SoftUiTheme.redDanger,
                            boxShadow: [
                              BoxShadow(
                                color: (isBackendOnline
                                        ? SoftUiTheme.primaryMint
                                        : SoftUiTheme.redDanger)
                                    .withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        if (!isVerySmall) ...[
                          const SizedBox(width: 5),
                          Text(
                            isLocal ? 'Local' : 'Live',
                            style: const TextStyle(
                              color: SoftUiTheme.textPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab(int index, IconData icon, String label, bool isSelected) {
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? SoftUiTheme.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? SoftUiTheme.mintDark : SoftUiTheme.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? SoftUiTheme.textPrimary
                    : SoftUiTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

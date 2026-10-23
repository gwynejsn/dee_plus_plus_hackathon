import 'package:flutter/material.dart';
import '../config/soft_ui_theme.dart';

class PapuntaNaButton extends StatelessWidget {
  final bool isConfirmed;
  final bool isLoading;
  final VoidCallback onPressed;

  const PapuntaNaButton({
    super.key,
    required this.isConfirmed,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isConfirmed) {
      return Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: SoftUiTheme.cardBg,
          borderRadius: SoftUiTheme.cardRadius,
          border: Border.all(color: SoftUiTheme.primaryMint, width: 2),
          boxShadow: SoftUiTheme.cardShadow,
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: SoftUiTheme.primaryMint, size: 24),
            SizedBox(width: 10),
            Text(
              '✓ Shop Notified: Papunta Ka Na!',
              style: TextStyle(
                color: SoftUiTheme.primaryMint,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: SoftUiTheme.cardRadius,
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5AB), Color(0xFF00D19E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x4000D19E),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            const BoxShadow(
              color: Color(0xFFFFFFFF),
              blurRadius: 8,
              offset: Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: SoftUiTheme.cardRadius,
            ),
          ),
          child: isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Notifying Shop...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🚶', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 10),
                    Text(
                      'PAPUNTA NA AKO (On My Way)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

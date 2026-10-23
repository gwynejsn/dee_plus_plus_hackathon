import 'package:flutter/material.dart';
import '../config/soft_ui_theme.dart';
import '../models/queue_ticket.dart';

class BuzzerDisc extends StatefulWidget {
  final QueueTicket ticket;

  const BuzzerDisc({super.key, required this.ticket});

  @override
  State<BuzzerDisc> createState() => _BuzzerDiscState();
}

class _BuzzerDiscState extends State<BuzzerDisc> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.ticket.state;

    Color accentColor;
    Color badgeBg;
    Color glowColor;
    String statusTitle;
    bool shouldAnimate = false;

    switch (state) {
      case TicketState.almostNext:
        accentColor = SoftUiTheme.amberWarning;
        badgeBg = SoftUiTheme.amberLight;
        glowColor = const Color(0x66F59E0B);
        statusTitle = 'ALMOST YOUR TURN!';
        shouldAnimate = true;
        break;
      case TicketState.nowServing:
        accentColor = SoftUiTheme.primaryMint;
        badgeBg = SoftUiTheme.mintLight;
        glowColor = const Color(0x6600D19E);
        statusTitle = 'NOW SERVING!';
        shouldAnimate = true;
        break;
      case TicketState.completed:
        accentColor = SoftUiTheme.textSecondary;
        badgeBg = const Color(0xFFF1F5F9);
        glowColor = Colors.transparent;
        statusTitle = 'SERVICE COMPLETED';
        break;
      case TicketState.cancelled:
        accentColor = SoftUiTheme.redDanger;
        badgeBg = SoftUiTheme.redLight;
        glowColor = const Color(0x44EF4444);
        statusTitle = 'TICKET CANCELLED';
        break;
      case TicketState.waiting:
        accentColor = SoftUiTheme.primaryMint;
        badgeBg = SoftUiTheme.mintLight;
        glowColor = const Color(0x3300D19E);
        statusTitle = 'IN LINE';
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxAvailable = constraints.maxWidth > 0 ? constraints.maxWidth : 320.0;
        final double discSize = (maxAvailable < 320 ? maxAvailable - 16 : 280.0).clamp(220.0, 280.0);
        final double numberFontSize = discSize * 0.28;

        Widget disc = Container(
          width: discSize,
          height: discSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SoftUiTheme.cardBg,
            border: Border.all(color: accentColor, width: 6),
            boxShadow: [
              const BoxShadow(
                color: Color(0x141B2B40),
                blurRadius: 28,
                offset: Offset(0, 14),
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Color(0xFFFFFFFF),
                blurRadius: 12,
                offset: Offset(-4, -4),
              ),
              if (shouldAnimate)
                BoxShadow(
                  color: glowColor,
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusTitle,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: discSize < 250 ? 9.5 : 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '#${widget.ticket.ticketNumber}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: numberFontSize,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.ticket.customerName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: SoftUiTheme.textPrimary,
                    fontSize: discSize < 250 ? 14 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.ticket.serviceName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: SoftUiTheme.textSecondary,
                    fontSize: discSize < 250 ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldAnimate) {
          return ScaleTransition(
            scale: _pulseAnimation,
            child: disc,
          );
        }

        return disc;
      },
    );
  }
}

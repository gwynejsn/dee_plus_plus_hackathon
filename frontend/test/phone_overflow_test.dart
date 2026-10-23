import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextna_frontend/main.dart';
import 'package:nextna_frontend/screens/display_screen.dart';
import 'package:nextna_frontend/screens/services_screen.dart';
import 'package:nextna_frontend/widgets/ticket_card.dart';
import 'package:nextna_frontend/models/queue_ticket.dart';

void main() {
  final phoneSizes = [
    const Size(320, 568),
    const Size(360, 640),
    const Size(375, 667),
    const Size(390, 844),
    const Size(412, 915),
  ];

  for (final size in phoneSizes) {
    testWidgets('Test phone size ${size.width}x${size.height} on MainNavigationShell', (tester) async {
      tester.view.physicalSize = size * 2.0;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const NextNaApp());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Test phone size ${size.width}x${size.height} on DisplayScreen', (tester) async {
      tester.view.physicalSize = size * 2.0;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DisplayScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Test phone size ${size.width}x${size.height} on ServicesScreen', (tester) async {
      tester.view.physicalSize = size * 2.0;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ServicesScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Test phone size ${size.width}x${size.height} on TicketCard with long name and onMyWay', (tester) async {
      tester.view.physicalSize = size * 2.0;
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dummyTicket = QueueTicket(
        id: 'test-1',
        ticketNumber: 88,
        customerName: 'Juan Dela Cruz Extremely Long Name For Testing Overflows',
        serviceId: 'srv-1',
        serviceName: 'Executive Precision Haircut With Beard Grooming Extra Deluxe',
        servicePrice: 350.0,
        estimatedWaitMinutes: 25,
        state: TicketState.nowServing,
        onMyWayConfirmed: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TicketCard(
                ticket: dummyTicket,
                onCall: () {},
                onServe: () {},
                onComplete: () {},
                onCancel: () {},
                onOverrideWait: () {},
                onOpenBuzzer: () {},
                onShowQr: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}

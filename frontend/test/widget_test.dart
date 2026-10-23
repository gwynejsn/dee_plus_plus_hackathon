import 'package:flutter_test/flutter_test.dart';
import 'package:nextna_frontend/main.dart';

void main() {
  testWidgets('NextNaApp boots and renders main navigation shell', (WidgetTester tester) async {
    await tester.pumpWidget(const NextNaApp());
    expect(find.text('NextNa'), findsOneWidget);
  });
}

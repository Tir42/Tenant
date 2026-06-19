import 'package:flutter_test/flutter_test.dart';
import 'package:tenantsnap/main.dart';

void main() {
  testWidgets('Smoke test for TenantSnapApp loading screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TenantSnapApp());

    // Verify that our title is present.
    expect(find.text('TenantSnap'), findsOneWidget);

    // Pump to let the 200ms initialization timer in main.dart complete
    await tester.pump(const Duration(milliseconds: 250));
  });
}

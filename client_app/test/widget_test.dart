import 'package:flutter_test/flutter_test.dart';
import 'package:hs_event_app/main.dart';

void main() {
  testWidgets('App root bootstrapping smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HsMusicApp());

    // Verify that the discovery screen title is rendered.
    expect(find.text('Discover Providers'), findsOneWidget);
  });
}
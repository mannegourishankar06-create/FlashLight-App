import 'package:flashlight_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the flashlight screen in the OFF state', (tester) async {
    await tester.pumpWidget(const FlashlightApp());
    await tester.pump();

    expect(find.text('Flashlight'), findsOneWidget);
    expect(find.text('OFF'), findsOneWidget);
  });
}

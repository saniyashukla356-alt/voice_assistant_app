
import 'package:flutter_test/flutter_test.dart';
import 'package:vaani_ai/main.dart';

void main() {
  testWidgets('Vaani AI app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const VaaniApp());
    await tester.pump();

    expect(find.byType(VaaniApp), findsOneWidget);
  });
}

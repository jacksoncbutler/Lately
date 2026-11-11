import 'package:flutter_test/flutter_test.dart';
import 'package:lately/main.dart';

void main() {
  testWidgets('app opens to an empty screen', (tester) async {
    await tester.pumpWidget(const LatelyApp());
    expect(find.text('Lately'), findsOneWidget);
  });
}

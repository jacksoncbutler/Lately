import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/providers.dart';
import 'package:lately/main.dart';

void main() {
  testWidgets('app opens and shows the database is ready', (tester) async {
    final db = LatelyDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const LatelyApp(),
    ));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    expect(find.text('Lately'), findsOneWidget);
    expect(find.text('Database ready · 3 groups'), findsOneWidget);
  });
}

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/app_config.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/device_sources.dart';
import 'package:lately/data/providers.dart';
import 'package:lately/data/repository.dart';
import 'package:lately/domain/timezones.dart';
import 'package:lately/features/settings/settings_screen.dart';
import 'package:lately/main.dart';

import 'support/fakes.dart';

/// Edge cases from the technical plan that have no other home. The rest are
/// covered where they belong; docs/EDGE_CASES.md lists where.
class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

void main() {
  late LatelyDatabase db;
  late Repository repo;
  final now = DateTime.utc(2026, 11, 11, 14, 10);

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => now);
    await repo.completeSetup();
  });

  void testApp(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          snapshotDirProvider.overrideWithValue(Directory.systemTemp),
          deviceTimezoneProvider.overrideWithValue(_Tz()),
          phoneLauncherProvider.overrideWithValue(FakeLauncher()),
          nowProvider.overrideWithValue(() => now),
        ],
        child: const LatelyApp(),
      ));
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 40)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.runAsync(db.close);
    });
  }

  testApp('everyone overdue after a long time away: still exactly one person, and no totals or badges', (tester) async {
    final g = (await repo.listGroups()).firstWhere((g) => g.name == 'Friends').id;
    for (var i = 0; i < 40; i++) {
      await repo.createPerson(
        displayName: 'Person $i', groupId: g, timezone: 'Europe/Lisbon', timezoneConfirmed: true,
        contactMethodType: 'text', contactMethodValue: '+351912345678',
        lastTalkedEstimate: now.subtract(Duration(days: 400 + i)),
      );
    }
    await tester.pump(const Duration(minutes: 1));
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 40)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hero-card')), findsOneWidget);
    expect(find.byKey(const Key('hero-name')), findsOneWidget); // one name, not a list
    expect(find.byType(Badge), findsNothing);
    expect(find.textContaining(RegExp(r'\d+\s+(people|friends)\s+(are\s+)?overdue', caseSensitive: false)), findsNothing);
    expect(find.textContaining('streak', findRichText: true), findsNothing);
  });

  test('nothing about being overdue is stored: it is worked out each time', () async {
    final columns = <String>{};
    for (final t in ['people', 'chats', 'lines', 'settings', 'groups', 'relationships', 'important_dates', 'custom_blocks']) {
      final rows = await db.customSelect('PRAGMA table_info($t)').get();
      columns.addAll(rows.map((r) => r.read<String>('name')));
    }
    for (final derived in [
      'days_since_last_contact', 'overdue_ratio', 'ratio', 'expected_length', 'expected_minutes',
      'why_line', 'last_in_person', 'last_call_or_text', 'last_contact', 'score', 'rank', 'streak', 'overdue',
    ]) {
      expect(columns, isNot(contains(derived)), reason: derived);
    }
    await db.close();
  });

  testApp('Settings shows which build is installed', (tester) async {
    await repo.createPerson(displayName: 'Sam', groupId: (await repo.listGroups()).first.id, timezone: 'UTC', timezoneConfirmed: true, contactMethodType: 'text');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('app-version')), 400,
        scrollable: find.descendant(of: find.byType(SettingsScreen), matching: find.byType(Scrollable)).first);
    expect(find.text('Lately ${AppConfig.appVersion}'), findsOneWidget);
  });
}

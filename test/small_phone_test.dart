import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/device_sources.dart';
import 'package:lately/data/providers.dart';
import 'package:lately/data/repository.dart';
import 'package:lately/domain/timezones.dart';
import 'package:lately/main.dart';

import 'support/fakes.dart';

/// A small phone with big text. The test font draws every letter a full em
/// wide, wider than any real font, so passing here leaves plenty of room on a
/// real phone. Flutter reports any overflow as a failure.
class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

class _Contacts implements ContactsSource {
  @override
  Future<ContactsAccess> requestAccess() async => ContactsAccess.granted;
  @override
  Future<List<PhoneContact>> load() async =>
      const [PhoneContact(id: '1', name: 'Alexandria Montgomery-Fitzgerald', phone: '+1 415 555 2671')];
}

void main() {
  late LatelyDatabase db;
  late Repository repo;
  late String sam;
  final now = DateTime.utc(2026, 11, 11, 14, 10);

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => now);
    await repo.completeSetup();
    final g = (await repo.listGroups()).firstWhere((g) => g.name == 'Friends').id;
    sam = await repo.createPerson(
      displayName: 'Maria Fernanda de los Angeles Rodriguez', groupId: g, timezone: 'Europe/Lisbon',
      timezoneConfirmed: true, contactMethodType: 'whatsapp', contactMethodValue: '+351912345678',
      phone: '+351912345678', instagram: 'maria.fernanda.rodriguez', facebook: 'maria.fernanda.r',
      lastTalkedEstimate: now.subtract(const Duration(days: 80)),
    );
    for (var i = 0; i < 8; i++) {
      await repo.createLine(personId: sam, block: ['next_time', 'interests', 'about'][i % 3], text: 'A fairly long line of text number $i that keeps going');
    }
    await repo.createRelationship(personId: sam, name: 'Maria Fernanda de los Angeles', relation: 'grandmother of the bride');
    await repo.logChat(personId: sam, occurredAt: now.subtract(const Duration(days: 50)), type: 'call', depth: 'deep', durationMinutes: 45,
        feelings: ['Happy', 'Excited', 'Stressed'], note: 'A long note about what we talked about at length over the phone');
    await repo.updatePerson(sam, const PeopleCompanion(birthday: Value('1990-11-20')));
    await repo.createPeople([(displayName: 'Unfinished With A Rather Long Name', phone: null)],
        groupId: g, timezone: 'UTC', timezoneConfirmed: false);
  });

  void testApp(String name, double scale, Future<void> Function(WidgetTester tester) body) {
    testWidgets('$name (text x$scale)', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(() {
        tester.view.reset();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
      await tester.pumpWidget(ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          snapshotDirProvider.overrideWithValue(Directory.systemTemp),
          deviceTimezoneProvider.overrideWithValue(_Tz()),
          contactsSourceProvider.overrideWithValue(_Contacts()),
          phoneLauncherProvider.overrideWithValue(FakeLauncher()),
          nowProvider.overrideWithValue(() => now),
        ],
        child: const LatelyApp(),
      ));
      await settle(tester);
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.runAsync(db.close);
    });
  }

  for (final scale in [1.0, 1.5]) {
    testApp('Home', scale, (tester) async {
      expect(find.byKey(const Key('hero-card')), findsOneWidget);
    });
    testApp('People and Dates', scale, (tester) async {
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('tab-dates')));
      await settle(tester);
    });
    testApp('a profile with everything on it', scale, (tester) async {
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tapVisible(tester, find.textContaining('Maria Fernanda de los Angeles Rodriguez').first);
      await settle(tester);
      await tapVisible(tester, find.byKey(const Key('profile-more')));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -3000));
      await tester.pumpAndSettle();
    });
    testApp('Settings', scale, (tester) async {
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await settle(tester);
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -4000));
      await tester.pumpAndSettle();
    });
    testApp('the sheets and forms', scale, (tester) async {
      await tapVisible(tester, find.byKey(const Key('hero-log')));
      await settle(tester);
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -1500));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('add-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add someone'));
      await settle(tester);
      await tapVisible(tester, find.byKey(const Key('channel-facebook')));
      await tester.pumpAndSettle();
    });
    testApp('Add from contacts and Edit person', scale, (tester) async {
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('add-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add from contacts'));
      await settle(tester);
      await tester.tap(find.byType(BackButton));
      await settle(tester);
      await tapVisible(tester, find.textContaining('Maria Fernanda de los Angeles Rodriguez').first);
      await settle(tester);
      await tapVisible(tester, find.byKey(const Key('profile-edit')));
      await settle(tester);
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -3000));
      await tester.pumpAndSettle();
    });
  }
}

/// Scrolls to [f] first: on a small screen a lot of it starts below the fold.
Future<void> tapVisible(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).last);
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 40)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

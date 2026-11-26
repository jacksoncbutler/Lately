import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/backup/backup_codec.dart';
import 'package:lately/data/backup/backup_models.dart';
import 'package:lately/data/backup/backup_service.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/device_sources.dart';
import 'package:lately/data/providers.dart';
import 'package:lately/data/repository.dart';
import 'package:lately/domain/ranking.dart';
import 'package:lately/domain/timezones.dart';
import 'package:lately/main.dart';

import 'support/fakes.dart';

/// 200 people with a realistic history: the app has to stay quick.
class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

const _zones = [
  'Europe/Lisbon', 'America/Chicago', 'Asia/Tokyo', 'Australia/Sydney', 'America/New_York',
  'Europe/Berlin', 'Asia/Kolkata', 'America/Los_Angeles', 'Pacific/Auckland', 'Africa/Nairobi',
];

void main() {
  const people = 200;
  final now = DateTime.utc(2026, 11, 11, 14, 10);

  late LatelyDatabase db;
  late Repository repo;
  late Directory tmp;
  late List<String> ids;

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => now);
    tmp = Directory.systemTemp.createTempSync('lately_perf');
    await repo.completeSetup();
    final groups = await repo.listGroups();
    ids = [];
    await db.transaction(() async {
      for (var i = 0; i < people; i++) {
        final id = await repo.createPerson(
          displayName: 'Person ${i.toString().padLeft(3, '0')}',
          groupId: groups[i % groups.length].id,
          timezone: _zones[i % _zones.length],
          timezoneConfirmed: true,
          contactMethodType: 'text',
          contactMethodValue: '+1415555${(1000 + i).toString()}',
          phone: '+1415555${(1000 + i).toString()}',
          lastTalkedEstimate: now.subtract(Duration(days: 30 + i)),
        );
        ids.add(id);
        if (i % 3 == 0) await repo.updatePerson(id, PeopleCompanion(birthday: Value('--${(1 + i % 12).toString().padLeft(2, '0')}-${(1 + i % 28).toString().padLeft(2, '0')}')));
        for (var c = 0; c < 5; c++) {
          await repo.createChat(
            personId: id,
            occurredAt: now.subtract(Duration(days: 20 + i % 90 + c * 25)),
            type: ['call', 'text', 'person'][c % 3],
            depth: 'varied',
            length: 'catchup',
            durationMinutes: 10 + (i + c) % 50,
            note: c == 0 ? 'A note about what we talked about' : null,
          );
        }
        for (var l = 0; l < 4; l++) {
          await repo.createLine(personId: id, block: ['next_time', 'interests', 'about', 'next_time'][l], text: 'A line about something $l for person $i');
        }
        if (i % 4 == 0) await repo.createRelationship(personId: id, name: 'Rel $i', relation: 'sibling');
      }
    });
  });
  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  test('ranking 200 people with 1000 chats is instant', () async {
    final chats = await repo.db.select(repo.db.chats).get();
    final byPerson = <String, List<RankChat>>{};
    for (final c in chats) {
      byPerson.putIfAbsent(c.personId, () => []).add(RankChat(at: c.occurredAt, minutes: c.durationMinutes, length: c.length));
    }
    final list = [
      for (final p in await repo.listPeople())
        RankPerson(id: p.id, name: p.displayName, zone: p.timezone, intervalDays: 30, chats: byPerson[p.id] ?? const [])
    ];
    final sw = Stopwatch()..start();
    for (var i = 0; i < 20; i++) {
      final rows = rank(list, now, const RankSettings(userZone: 'America/Chicago'));
      pickHero(rows, TimeChip.m15);
    }
    sw.stop();
    final per = sw.elapsedMilliseconds / 20;
    debugPrint('PERF rank+pick for $people people: ${per.toStringAsFixed(1)} ms');
    expect(per, lessThan(60)); // generous: it is a few milliseconds
  });

  test('export and import of the whole thing is quick and exact', () async {
    final svc = BackupService(db, snapshotDir: Directory('${tmp.path}/snap'), clock: () => now);
    final sw = Stopwatch()..start();
    final text = await svc.exportToString();
    final exportMs = sw.elapsedMilliseconds;
    sw.reset();
    final parsed = parseBackup(text);
    final parseMs = sw.elapsedMilliseconds;
    final db2 = LatelyDatabase(NativeDatabase.memory());
    addTearDown(db2.close);
    final svc2 = BackupService(db2, snapshotDir: Directory('${tmp.path}/snap2'), clock: () => now);
    sw.reset();
    await svc2.importBackup(parsed, ImportMode.replace);
    final importMs = sw.elapsedMilliseconds;
    debugPrint('PERF export ${exportMs}ms (${(text.length / 1024).round()} KB), validate ${parseMs}ms, import ${importMs}ms');
    expect(exportMs, lessThan(4000));
    expect(parseMs, lessThan(4000));
    expect(importMs, lessThan(8000));
    final again = jsonDecode(await svc2.exportToString()) as Map;
    expect(canonicalJson(again['data']), canonicalJson((jsonDecode(text) as Map)['data']));
    expect((await Repository(db2).listPeople()).length, people);
  });

  group('screens', () {
    void testApp(String name, Future<void> Function(WidgetTester tester) body) {
      testWidgets(name, (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.reset);
        await body(tester);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 1));
      });
    }

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 30)));
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    Future<int> ms(WidgetTester tester, Future<void> Function() f) async {
      final sw = Stopwatch()..start();
      await f();
      return sw.elapsedMilliseconds;
    }

    Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            snapshotDirProvider.overrideWithValue(Directory.systemTemp),
            deviceTimezoneProvider.overrideWithValue(_Tz()),
            phoneLauncherProvider.overrideWithValue(FakeLauncher()),
            contactsSourceProvider.overrideWithValue(_NoContacts()),
            nowProvider.overrideWithValue(() => now),
          ],
          child: const LatelyApp(),
        ));

    testApp('Home, People, Dates, a profile and the log popup stay quick with 200 people', (tester) async {
      final home = await ms(tester, () async {
        await pumpApp(tester);
        await settle(tester);
      });
      expect(find.byKey(const Key('hero-card')), findsOneWidget);

      final people = await ms(tester, () async {
        await tester.tap(find.byKey(const Key('tab-people')));
        await settle(tester);
      });
      // Not every row is built at once: a lazy list only builds what is on screen.
      final built = find.byType(ListTile).evaluate().length;

      final scroll = await ms(tester, () async {
        for (var i = 0; i < 6; i++) {
          await tester.drag(find.byType(Scrollable).last, const Offset(0, -1500));
          await tester.pumpAndSettle();
        }
      });

      final dates = await ms(tester, () async {
        await tester.tap(find.byKey(const Key('tab-dates')));
        await settle(tester);
      });

      final search = await ms(tester, () async {
        await tester.tap(find.byKey(const Key('tab-people')));
        await settle(tester);
        for (var i = 0; i < 8; i++) {
          await tester.drag(find.byType(Scrollable).last, const Offset(0, 2500)); // back to the top
          await tester.pumpAndSettle();
        }
        await tester.enterText(find.byKey(const Key('people-search')), 'Person 15');
        await settle(tester);
      });

      final log = await ms(tester, () async {
        await tester.tap(find.byKey(const Key('log-fab')));
        await settle(tester);
        await tester.tap(find.byKey(const Key('log-change')));
        await settle(tester);
      });
      final pickerBuilt = find.byType(ListTile).evaluate().length;

      debugPrint('PERF Home ${home}ms, People ${people}ms ($built rows built), scroll ${scroll}ms, '
          'Dates ${dates}ms, search ${search}ms, log picker ${log}ms ($pickerBuilt rows built)');
      // Generous (debug mode on a test machine); the point is no multi-second stalls.
      expect(home, lessThan(6000));
      expect(people, lessThan(5000));
      expect(scroll, lessThan(8000));
      expect(dates, lessThan(5000));
      expect(search, lessThan(5000));
      expect(log, lessThan(6000));
      expect(built, lessThan(120), reason: 'the People list should be lazy');
      expect(pickerBuilt, lessThan(120), reason: 'the person picker should be lazy');
    });

    testApp('a profile with plenty on it opens quickly', (tester) async {
      await pumpApp(tester);
      await settle(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      final t = await ms(tester, () async {
        await tester.tap(find.byType(ListTile).first);
        await settle(tester);
      });
      debugPrint('PERF profile ${t}ms');
      expect(find.byKey(const Key('profile-contact')), findsOneWidget);
      expect(t, lessThan(4000));
    });
  });
}

class _NoContacts implements ContactsSource {
  @override
  Future<ContactsAccess> requestAccess() async => ContactsAccess.denied;
  @override
  Future<List<PhoneContact>> load() async => const [];
}

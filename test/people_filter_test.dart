import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/backup_platform.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/device_sources.dart';
import 'package:lately/data/providers.dart';
import 'package:lately/data/repository.dart';
import 'package:lately/domain/timezones.dart';
import 'package:lately/main.dart';

class FakeContacts implements ContactsSource {
  FakeContacts(this.access, [this.contacts = const []]);
  ContactsAccess access;
  final List<PhoneContact> contacts;
  int requested = 0;
  @override
  Future<ContactsAccess> requestAccess() async {
    requested++;
    return access;
  }

  @override
  Future<List<PhoneContact>> load() async => contacts;
}

class FakeTz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

class _NoPlatform implements BackupPlatform {
  @override
  Future<Directory> exportDirectory() async => Directory.systemTemp;
  @override
  Future<void> shareFile(File file) async {}
  @override
  Future<String?> pickBackupText() async => null;
}

void main() {
  late LatelyDatabase db;
  late Repository repo;
  late Directory tmp;
  late FakeContacts contacts;
  // 2026-11-11 14:10 UTC: Lisbon 2:10 pm, Chicago 8:10 am, Tokyo 11:10 pm
  final fixedNow = DateTime.utc(2026, 11, 11, 14, 10);

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => fixedNow);
    tmp = Directory.systemTemp.createTempSync('lately_flow_test');
    contacts = FakeContacts(ContactsAccess.granted);
    await repo.completeSetup();
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  /// Like testWidgets, then unmounts the app and closes the database in a way
  /// that does not leave drift's stream timers pending.
  void testApp(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
      await tester.runAsync(db.close);
    });
  }


  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 60)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        snapshotDirProvider.overrideWithValue(Directory('${tmp.path}/snap')),
        backupPlatformProvider.overrideWithValue(_NoPlatform()),
        contactsSourceProvider.overrideWithValue(contacts),
        deviceTimezoneProvider.overrideWithValue(FakeTz()),
        nowProvider.overrideWithValue(() => fixedNow),
      ],
      child: const LatelyApp(),
    ));
    await settle(tester);
  }

  Future<String> person(String name, String zone, int daysAgo, {String? group}) async {
    final g = group ?? (await repo.listGroups()).first.id;
    final id = await repo.createPerson(displayName: name, groupId: g, timezone: zone, contactMethodType: 'text', timezoneConfirmed: true);
    await repo.createChat(personId: id, occurredAt: fixedNow.subtract(Duration(days: daysAgo)), type: 'call', depth: 'varied', length: 'catchup');
    return id;
  }

  Future<void> openPeople(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('tab-people')));
    await settle(tester);
  }

  Future<void> openFilter(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('people-filter')));
    await settle(tester);
  }

  double top(WidgetTester tester, String text) => tester.getTopLeft(find.text(text)).dy;
  Finder inSheet(Finder f) => find.descendant(of: find.byType(BottomSheet), matching: f);

  testApp('no filter: people sit under their groups, as before', (tester) async {
    await person('Sam', 'Europe/Lisbon', 60);
    await openPeople(tester);
    expect(find.textContaining('EVERY'), findsOneWidget);
    expect(find.text('AWAKE NOW'), findsNothing);
    expect(find.byKey(const Key('chip-awake')), findsNothing);
  });

  testApp('Awake first: awake people on top, an Asleep section below, longest since contact first', (tester) async {
    await person('Jun', 'Asia/Tokyo', 90); // 23:10 there: asleep
    await person('Bo', 'Europe/Lisbon', 5); // awake, not due
    await person('Sam', 'Europe/Lisbon', 60); // awake
    await openPeople(tester);
    await openFilter(tester);
    await tester.tap(inSheet(find.byKey(const Key('filter-awake'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);

    expect(find.byKey(const Key('chip-awake')), findsOneWidget);
    expect(find.text('AWAKE NOW'), findsOneWidget);
    expect(find.text('ASLEEP'), findsOneWidget);
    expect(find.textContaining('EVERY'), findsNothing);
    expect(top(tester, 'AWAKE NOW'), lessThan(top(tester, 'Sam')));
    expect(top(tester, 'Sam'), lessThan(top(tester, 'Bo'))); // longer since contact first
    expect(top(tester, 'Bo'), lessThan(top(tester, 'ASLEEP')));
    expect(top(tester, 'ASLEEP'), lessThan(top(tester, 'Jun')));
    // the group name moves into the row
    expect(find.textContaining('Last talked'), findsNWidgets(3));
  });

  testApp('Due first: Due and Not due sections, whatever the time of day', (tester) async {
    await person('Jun', 'Asia/Tokyo', 90); // asleep but due
    await person('Bo', 'Europe/Lisbon', 2); // not due
    await openPeople(tester);
    await openFilter(tester);
    await tester.tap(inSheet(find.byKey(const Key('filter-due'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);

    expect(find.text('DUE'), findsOneWidget);
    expect(find.text('NOT DUE'), findsOneWidget);
    expect(top(tester, 'DUE'), lessThan(top(tester, 'Jun')));
    expect(top(tester, 'Jun'), lessThan(top(tester, 'NOT DUE')));
    expect(top(tester, 'NOT DUE'), lessThan(top(tester, 'Bo')));
  });

  testApp('both priorities: four sections, awake before due', (tester) async {
    await person('AwakeDue', 'Europe/Lisbon', 60);
    await person('AwakeCalm', 'Europe/Lisbon', 2);
    await person('AsleepDue', 'Asia/Tokyo', 60);
    await person('AsleepCalm', 'Asia/Tokyo', 2);
    await openPeople(tester);
    await openFilter(tester);
    await tester.tap(inSheet(find.byKey(const Key('filter-awake'))));
    await tester.tap(inSheet(find.byKey(const Key('filter-due'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);

    final order = ['AWAKE AND DUE', 'AwakeDue', 'AWAKE, NOT DUE', 'AwakeCalm', 'ASLEEP AND DUE', 'AsleepDue', 'ASLEEP, NOT DUE', 'AsleepCalm'];
    for (var i = 0; i < order.length - 1; i++) {
      expect(top(tester, order[i]), lessThan(top(tester, order[i + 1])), reason: '${order[i]} before ${order[i + 1]}');
    }
    expect(find.byKey(const Key('chip-awake')), findsOneWidget);
    expect(find.byKey(const Key('chip-due')), findsOneWidget);
  });

  testApp('unfinished people go in a last Finish setup section', (tester) async {
    await person('Sam', 'Europe/Lisbon', 60);
    final g = (await repo.listGroups()).first.id;
    await repo.createPerson(displayName: 'Newbie', groupId: g, timezone: 'Europe/Lisbon', contactMethodType: 'text', timezoneConfirmed: false);
    await openPeople(tester);
    await openFilter(tester);
    await tester.tap(inSheet(find.byKey(const Key('filter-awake'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('FINISH SETUP'), findsOneWidget);
    expect(top(tester, 'Sam'), lessThan(top(tester, 'FINISH SETUP')));
    expect(top(tester, 'FINISH SETUP'), lessThan(top(tester, 'Newbie')));
  });

  testApp('a group is a real filter: only that group shows, chip clears it', (tester) async {
    final groups = await repo.listGroups();
    await person('Mum', 'Europe/Lisbon', 60, group: groups[0].id);
    await person('Pal', 'Europe/Lisbon', 60, group: groups[1].id);
    await openPeople(tester);
    expect(find.text('Mum'), findsOneWidget);
    expect(find.text('Pal'), findsOneWidget);

    await openFilter(tester);
    await tester.tap(inSheet(find.byKey(Key('filter-group-${groups[1].id}'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('Mum'), findsNothing);
    expect(find.text('Pal'), findsOneWidget);
    expect(find.byKey(const Key('chip-group')), findsOneWidget);

    await tester.tap(find.descendant(of: find.byKey(const Key('chip-group')), matching: find.byType(Icon)));
    await settle(tester);
    expect(find.text('Mum'), findsOneWidget);
    expect(find.byKey(const Key('chip-group')), findsNothing);
  });

  testApp('a group together with a priority shows just that group, sorted into sections', (tester) async {
    final groups = await repo.listGroups();
    await person('Mum', 'Europe/Lisbon', 60, group: groups[0].id);
    await person('Pal', 'Europe/Lisbon', 60, group: groups[1].id);
    await person('Far', 'Asia/Tokyo', 60, group: groups[1].id);
    await openPeople(tester);
    await openFilter(tester);
    await tester.tap(inSheet(find.byKey(const Key('filter-awake'))));
    await tester.tap(inSheet(find.byKey(Key('filter-group-${groups[1].id}'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('Mum'), findsNothing);
    expect(top(tester, 'Pal'), lessThan(top(tester, 'ASLEEP')));
    expect(top(tester, 'ASLEEP'), lessThan(top(tester, 'Far')));
    expect(find.textContaining(groups[1].name), findsWidgets); // group name in the row subtitle
  });

  testApp('Clear removes every choice; search still works with a filter on', (tester) async {
    await person('Sam', 'Europe/Lisbon', 60);
    await person('Bo', 'Europe/Lisbon', 40);
    await openPeople(tester);
    await openFilter(tester);
    await tester.tap(inSheet(find.byKey(const Key('filter-due'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('people-search')), 'sa');
    await settle(tester);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Bo'), findsNothing);

    await openFilter(tester);
    await tester.tap(inSheet(find.byKey(const Key('filter-clear'))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.byKey(const Key('chip-due')), findsNothing);
    expect(find.text('DUE'), findsNothing);
  });
}

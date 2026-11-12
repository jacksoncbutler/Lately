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

  setUp(() {
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => fixedNow);
    tmp = Directory.systemTemp.createTempSync('lately_flow_test');
    contacts = FakeContacts(ContactsAccess.granted);
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

  testApp('first run shows setup; Continue saves group intervals and block order', (tester) async {
    await pumpApp(tester);
    expect(find.text('Welcome to Lately'), findsOneWidget);
    expect(find.text('every 14 days'), findsOneWidget); // Parents
    expect(find.text('every 21 days'), findsOneWidget);
    expect(find.text('every 30 days'), findsOneWidget);

    // Change Friends from 30 to 45 days.
    await tester.tap(find.text('every 30 days'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('every 45 days').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await settle(tester);

    final friends = (await repo.listGroups()).firstWhere((g) => g.name == 'Friends');
    expect(friends.defaultIntervalDays, 45);
    expect(await repo.isSetupComplete(), isTrue);
    expect(repo.blockOrderOf(await repo.getSettings()).first, 'next_time');
    // Lands on the empty-app welcome.
    expect(find.text('Who would you like to stay close to?'), findsOneWidget);
  });

  testApp('setup can add a custom group', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Add a group'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cousins');
    await tester.tap(find.text('Add').last);
    await settle(tester);
    expect(find.text('Cousins'), findsOneWidget);
    expect((await repo.listGroups()).map((g) => g.name), contains('Cousins'));
  });

  group('after setup', () {
    setUp(() async => repo.completeSetup());

    testApp('add a person: needs name and city; shows local time there; seeds last talked', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Add someone'));
      await tester.pumpAndSettle();

      final create = find.widgetWithText(FilledButton, 'Create');
      expect(tester.widget<FilledButton>(create).onPressed, isNull);

      await tester.enterText(find.widgetWithText(TextField, 'First name'), 'Sam');
      await tester.enterText(find.widgetWithText(TextField, 'Number or handle'), '+351 555 0142');
      await tester.enterText(find.widgetWithText(TextField, 'Search a city, such as Lisbon'), 'lisb');
      await tester.pumpAndSettle();
      expect(find.text('Lisbon, Portugal · 2:10 pm there'), findsOneWidget);
      await tester.tap(find.text('Lisbon, Portugal · 2:10 pm there'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2:10 pm there'), findsOneWidget); // confirmation card

      await tester.tap(find.text('A month'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(create);
      await tester.tap(create);
      await settle(tester);

      final sam = (await repo.listPeople()).single;
      expect(sam.displayName, 'Sam');
      expect(sam.timezone, 'Europe/Lisbon');
      expect(sam.timezoneConfirmed, isTrue);
      expect(sam.contactMethodType, 'text');
      expect(sam.contactMethodValue, '+351 555 0142');
      expect(sam.lastTalkedEstimate!.toUtc(), fixedNow.subtract(const Duration(days: 30)));
      expect((await repo.getGroup(sam.groupId))!.name, 'Friends'); // default group
    });

    testApp('unanswered last-talked defaults to about six months', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Add someone'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'First name'), 'Jun');
      await tester.enterText(find.widgetWithText(TextField, 'Search a city, such as Lisbon'), 'tokyo');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Tokyo'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create'));
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await settle(tester);
      final jun = (await repo.listPeople()).single;
      expect(jun.lastTalkedEstimate!.toUtc(), fixedNow.subtract(const Duration(days: 180)));
    });

    testApp('create and add more keeps the group and clears the form', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Add someone'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'First name'), 'Mom');
      await tester.tap(find.textContaining('Parents'));
      await tester.enterText(find.widgetWithText(TextField, 'Search a city, such as Lisbon'), 'madison');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Madison'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Create and add more'));
      await tester.tap(find.text('Create and add more'));
      await settle(tester);
      expect(find.text('Added Mom'), findsOneWidget);
      expect((await repo.listPeople()).single.timezone, 'America/Chicago');
      expect(tester.widget<TextField>(find.widgetWithText(TextField, 'First name')).controller!.text, '');
    });

    testApp('people list shows each person with the right local time', (tester) async {
      final g = (await repo.listGroups()).first.id;
      await repo.createPerson(displayName: 'Sam', groupId: g, timezone: 'Europe/Lisbon', contactMethodType: 'text', timezoneConfirmed: true);
      await repo.createPerson(displayName: 'Noor', groupId: g, timezone: 'Asia/Dubai', contactMethodType: 'text', timezoneConfirmed: true);
      await repo.createPerson(displayName: 'Ruth', groupId: g, timezone: 'Pacific/Auckland', contactMethodType: 'text', timezoneConfirmed: true);
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('browse-everyone')));
      await settle(tester);
      expect(find.textContaining('· 2:10 pm there'), findsOneWidget); // Lisbon
      expect(find.textContaining('· 6:10 pm there'), findsOneWidget); // Dubai
      expect(find.textContaining('· 3:10 am there'), findsOneWidget); // Auckland (next day)
    });

    testApp('bulk add: pick contacts, one group for all, then finish each person separately', (tester) async {
      contacts = FakeContacts(ContactsAccess.granted, const [
        PhoneContact(id: '1', name: 'Alex', phone: '+61 555 0103'),
        PhoneContact(id: '2', name: 'Priya', phone: '+91 555 0121'),
        PhoneContact(id: '3', name: 'Marcus', phone: null),
        PhoneContact(id: '4', name: 'Already Here', phone: '+1 (555) 0100'),
      ]);
      final g = (await repo.listGroups()).first.id;
      await repo.createPerson(displayName: 'Mom', groupId: g, timezone: 'America/Chicago', contactMethodType: 'call', contactMethodValue: '+1 555 0100', phone: '+1 555 0100', timezoneConfirmed: true);
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('browse-everyone')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('add-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add from contacts'));
      await settle(tester);
      expect(contacts.requested, 1);

      expect(find.text('Already added'), findsOneWidget); // same number as Mom
      await tester.tap(find.text('Alex'));
      await tester.tap(find.text('Priya'));
      await tester.tap(find.text('Marcus'));
      await tester.tap(find.textContaining('Siblings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add 3 people'));
      await settle(tester);

      final all = await repo.listPeople();
      final batch = all.where((p) => p.displayName != 'Mom').toList();
      expect(batch.map((p) => p.displayName), unorderedEquals(['Alex', 'Priya', 'Marcus']));
      for (final p in batch) {
        expect(p.timezone, 'America/Chicago'); // this phone's
        expect(p.timezoneConfirmed, isFalse);
        expect((await repo.getGroup(p.groupId))!.name, 'Siblings');
        expect(p.lastTalkedEstimate, isNull); // set per person, not for the batch
      }
      expect(batch.firstWhere((p) => p.displayName == 'Alex').phone, '+61 555 0103');
      expect(batch.firstWhere((p) => p.displayName == 'Marcus').phone, isNull);

      // The batch screen has no shared "last talked" question.
      // Each one shows Finish setup; finishing asks for city and last talked.
      expect(find.text('Finish setup'), findsNWidgets(3));
      await tester.tap(find.text('Alex'));
      await settle(tester);
      expect(find.text('Finish setup for Alex'), findsOneWidget);
      final finish = find.widgetWithText(FilledButton, 'Finish setup');
      expect(tester.widget<FilledButton>(finish).onPressed, isNull);
      await tester.enterText(find.widgetWithText(TextField, 'Search a city, such as Lisbon'), 'sydney');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Sydney'));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(finish).onPressed, isNull); // still needs last talked
      await tester.tap(find.text('A month'));
      await tester.pumpAndSettle();
      await tester.tap(finish);
      await settle(tester);

      final alex = (await repo.listPeople()).firstWhere((p) => p.displayName == 'Alex');
      expect(alex.timezone, 'Australia/Sydney');
      expect(alex.timezoneConfirmed, isTrue);
      expect(alex.lastTalkedEstimate!.toUtc(), fixedNow.subtract(const Duration(days: 30)));
      // Finishing opens the profile.
      expect(find.byKey(const Key('profile-contact')), findsOneWidget);
    });

    testApp('finish setup: "Not sure" uses the six-month default', (tester) async {
      final g = (await repo.listGroups()).first.id;
      await repo.createPeople([(displayName: 'Jo', phone: null)],
          groupId: g, timezone: 'America/Chicago', timezoneConfirmed: false);
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('browse-everyone')));
      await settle(tester);
      await tester.tap(find.text('Jo'));
      await settle(tester);
      await tester.tap(find.text('Same as mine (Chicago)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not sure'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Finish setup'));
      await settle(tester);
      final jo = (await repo.listPeople()).single;
      expect(jo.timezone, 'America/Chicago');
      expect(jo.timezoneConfirmed, isTrue);
      expect(jo.lastTalkedEstimate!.toUtc(), fixedNow.subtract(const Duration(days: 180)));
    });

    testApp('bulk add: permission is only asked when it starts, and denial is explained', (tester) async {
      contacts = FakeContacts(ContactsAccess.denied);
      await pumpApp(tester);
      expect(contacts.requested, 0); // nothing asked on launch or on Home
      await tester.tap(find.text('Add from contacts'));
      await settle(tester);
      expect(contacts.requested, 1);
      expect(find.textContaining('needs to read your contacts'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testApp('bulk add: permanently denied points to phone settings and adding one at a time', (tester) async {
      contacts = FakeContacts(ContactsAccess.permanentlyDenied);
      await pumpApp(tester);
      await tester.tap(find.text('Add from contacts'));
      await settle(tester);
      expect(find.textContaining('turned off'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });
  });
}

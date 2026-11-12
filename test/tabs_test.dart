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
import 'package:lately/features/profile/profile_screen.dart';
import 'package:lately/main.dart';

class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

class _Contacts implements ContactsSource {
  @override
  Future<ContactsAccess> requestAccess() async => ContactsAccess.denied;
  @override
  Future<List<PhoneContact>> load() async => const [];
}

void main() {
  late LatelyDatabase db;
  late Repository repo;
  late String friends, parents, siblings;
  // 2026-11-11 14:10 UTC = 08:10 Chicago (you), 14:10 Lisbon.
  var clock = DateTime.utc(2026, 11, 11, 14, 10);

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    clock = DateTime.utc(2026, 11, 11, 14, 10);
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => clock);
    await repo.completeSetup();
    final gs = {for (final g in await repo.listGroups()) g.name: g.id};
    friends = gs['Friends']!;
    parents = gs['Parents']!;
    siblings = gs['Siblings']!;
  });

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
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        snapshotDirProvider.overrideWithValue(Directory.systemTemp),
        deviceTimezoneProvider.overrideWithValue(_Tz()),
        contactsSourceProvider.overrideWithValue(_Contacts()),
        nowProvider.overrideWithValue(() => clock),
      ],
      child: const LatelyApp(),
    ));
    await settle(tester);
  }

  Future<void> tab(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await settle(tester);
  }

  Future<String> add(String name,
      {String zone = 'Europe/Lisbon', String? group, int? daysAgo, String? birthday, bool finished = true}) async {
    final id = await repo.createPerson(
      displayName: name,
      groupId: group ?? friends,
      timezone: zone,
      timezoneConfirmed: finished,
      contactMethodType: 'text',
      contactMethodValue: '+351 555 0100',
    );
    if (birthday != null) await repo.updatePerson(id, PeopleCompanion(birthday: Value(birthday)));
    if (daysAgo != null) {
      await repo.createChat(personId: id, occurredAt: clock.subtract(Duration(days: daysAgo)), type: 'call', depth: 'varied', length: 'catchup', durationMinutes: 30);
    }
    return id;
  }

  group('tabs', () {
    testApp('Home, People and Dates, with Home first', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      for (final k in ['tab-home', 'tab-people', 'tab-dates']) {
        expect(find.byKey(Key(k)), findsOneWidget);
      }
      expect(find.text('Up next'), findsOneWidget);
      await tab(tester, 'tab-people');
      expect(find.byKey(const Key('people-search')), findsOneWidget);
      await tab(tester, 'tab-dates');
      expect(find.text('Dates'), findsWidgets);
      await tab(tester, 'tab-home');
      expect(find.text('Up next'), findsOneWidget);
    });

    testApp('Browse everyone on Home goes to People', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('browse-everyone')));
      await settle(tester);
      expect(find.byKey(const Key('people-search')), findsOneWidget);
    });

    testApp('each tab keeps its place when you switch away and back', (tester) async {
      await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      await tester.enterText(find.byKey(const Key('people-search')), 'bo');
      await settle(tester);
      await tab(tester, 'tab-dates');
      await tab(tester, 'tab-people');
      expect(find.text('Bo'), findsOneWidget);
      expect(find.text('Sam'), findsNothing); // still filtered
    });

    testApp('the log button shows on Home and People but not on Dates', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      expect(find.byKey(const Key('log-fab')), findsOneWidget);
      await tab(tester, 'tab-people');
      expect(find.byKey(const Key('log-fab')), findsOneWidget);
      await tab(tester, 'tab-dates');
      expect(find.byKey(const Key('log-fab')), findsNothing);
    });

    testApp('opening a profile and coming back does not trip over the two floating buttons', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      await tester.tap(find.text('Sam'));
      await settle(tester);
      expect(find.byKey(const Key('profile-contact')), findsOneWidget);
      await tester.tap(find.text('People').last);
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('add people: one plus, top right', () {
    testApp('the People tab has a plus, not two big buttons', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      expect(find.byKey(const Key('add-menu')), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add someone'), findsNothing);
      expect(find.text('Add from contacts'), findsNothing);
      // It sits in the top right of the app bar.
      final p = tester.getCenter(find.byKey(const Key('add-menu')));
      expect(p.dx, greaterThan(700));
      expect(p.dy, lessThan(120));
    });

    testApp('tapping it expands to Add someone and Add from contacts', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      await tester.tap(find.byKey(const Key('add-menu')));
      await tester.pumpAndSettle();
      expect(find.text('Add someone'), findsOneWidget);
      expect(find.text('Add from contacts'), findsOneWidget);
    });

    testApp('Add someone opens the add form', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      await tester.tap(find.byKey(const Key('add-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add someone'));
      await settle(tester);
      expect(find.text('Add a person'), findsOneWidget);
    });

    testApp('Add from contacts opens the contacts flow', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      await tester.tap(find.byKey(const Key('add-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add from contacts'));
      await settle(tester);
      expect(find.text('Add from contacts'), findsWidgets);
      expect(find.textContaining('needs to read your contacts'), findsOneWidget);
    });

    testApp('with nobody yet, People points at the plus', (tester) async {
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      expect(find.text('No one yet. Tap + to add people.'), findsOneWidget);
      expect(find.byKey(const Key('add-menu')), findsOneWidget);
    });
  });

  group('People tab', () {
    testApp('grouped by group, longest since you talked first, with last talked and local time', (tester) async {
      await add('Newer', daysAgo: 20);
      await add('Older', daysAgo: 90);
      await add('Mom', group: parents, zone: 'America/Chicago', daysAgo: 9);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      expect(find.text('PARENTS · EVERY 14 DAYS'), findsOneWidget);
      expect(find.text('FRIENDS · EVERY 30 DAYS'), findsOneWidget);
      expect(find.text('SIBLINGS · EVERY 21 DAYS'), findsNothing); // empty groups are hidden
      final older = tester.getTopLeft(find.text('Older')).dy;
      final newer = tester.getTopLeft(find.text('Newer')).dy;
      expect(older, lessThan(newer));
      expect(find.text('Last talked 3 months ago · 2:10 pm there'), findsOneWidget); // Older, Lisbon
      expect(find.text('Last talked 9 days ago · 8:10 am there'), findsOneWidget); // Mom, Chicago
    });

    testApp('says why someone is not being suggested', (tester) async {
      await add('Awake', daysAgo: 60);
      await add('Sleepy', zone: 'Asia/Tokyo', daysAgo: 60);
      await add('Finn', daysAgo: 0);
      await add('Early', daysAgo: 5);
      final snoozed = await add('Nap', daysAgo: 60);
      await repo.snoozeUntil(snoozed, clock.add(const Duration(days: 3)));
      final skipped = await add('Kip', daysAgo: 60);
      await repo.skipUntil(skipped, clock.add(const Duration(hours: 5)));
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      expect(find.text('Asleep'), findsOneWidget);
      expect(find.text('Talked today'), findsOneWidget);
      expect(find.text('Not due'), findsOneWidget);
      expect(find.text('Snoozed'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
    });

    testApp('search narrows by name and hides empty groups', (tester) async {
      await add('Sam', daysAgo: 60);
      await add('Mom', group: parents, daysAgo: 9);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      await tester.enterText(find.byKey(const Key('people-search')), 'mo');
      await settle(tester);
      expect(find.text('Mom'), findsOneWidget);
      expect(find.text('Sam'), findsNothing);
      expect(find.text('FRIENDS · EVERY 30 DAYS'), findsNothing);
      await tester.enterText(find.byKey(const Key('people-search')), 'zzz');
      await settle(tester);
      expect(find.text('No one matches that search.'), findsOneWidget);
    });

    testApp('Archived sits collapsed at the bottom, and opens to a profile', (tester) async {
      await add('Sam', daysAgo: 60);
      final old = await add('Old Friend', daysAgo: 200);
      await repo.archivePerson(old);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      expect(find.text('Archived (1)'), findsOneWidget);
      expect(find.text('Old Friend'), findsNothing); // collapsed
      await tester.tap(find.text('Archived (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Old Friend'), findsOneWidget);
      await tester.tap(find.text('Old Friend'));
      await settle(tester);
      expect(find.text('Archived. Not suggested on Home.'), findsOneWidget);
    });

    testApp('people still to finish are marked and finish before their profile opens', (tester) async {
      await add('Jo', finished: false);
      await pumpApp(tester);
      await tab(tester, 'tab-people');
      expect(find.text('Finish setup'), findsOneWidget);
      await tester.tap(find.text('Jo'));
      await settle(tester);
      expect(find.text('Finish setup for Jo'), findsOneWidget);
    });
  });

  group('Dates tab', () {
    testApp('the next twelve months of birthdays, soonest first, including their people', (tester) async {
      final sam = await add('Sam', daysAgo: 3, birthday: '--11-14');
      await add('Far', daysAgo: 3, birthday: '--09-01');
      await repo.createRelationship(personId: sam, name: 'Maria', relation: 'mother', birthday: '--12-02');
      await pumpApp(tester);
      await tab(tester, 'tab-dates');
      final labels = ["Sam's birthday", "Maria's birthday", "Far's birthday"];
      for (final l in labels) {
        expect(find.text(l), findsOneWidget, reason: l);
      }
      expect(tester.getTopLeft(find.text("Sam's birthday")).dy, lessThan(tester.getTopLeft(find.text("Maria's birthday")).dy));
      expect(tester.getTopLeft(find.text("Maria's birthday")).dy, lessThan(tester.getTopLeft(find.text("Far's birthday")).dy));
      expect(find.text("Sam's mother"), findsOneWidget);
      expect(find.text('Sat, Nov 14'), findsOneWidget);
      expect(find.text('Wed, Sep 1'), findsOneWidget);
    });

    testApp('a known birth year says how old they turn; an unknown year shows no age', (tester) async {
      await add('Known', daysAgo: 3, birthday: '1990-11-20');
      await add('Unknown', daysAgo: 3, birthday: '--11-25');
      await pumpApp(tester);
      await tab(tester, 'tab-dates');
      expect(find.text('Turns 36'), findsOneWidget);
      expect(find.textContaining('Turns'), findsOneWidget); // only the known one
    });

    testApp('today shows as Today; archived people are left out', (tester) async {
      await add('Alex', daysAgo: 3, birthday: '--11-11');
      final gone = await add('Gone', daysAgo: 3, birthday: '--11-12');
      await repo.archivePerson(gone);
      await pumpApp(tester);
      await tab(tester, 'tab-dates');
      expect(find.text('Today'), findsOneWidget);
      expect(find.text("Gone's birthday"), findsNothing);
    });

    testApp('tapping a date opens that person, labelled Dates', (tester) async {
      await add('Sam', daysAgo: 3, birthday: '--11-14');
      await pumpApp(tester);
      await tab(tester, 'tab-dates');
      await tester.tap(find.text("Sam's birthday"));
      await settle(tester);
      expect(find.byKey(const Key('profile-contact')), findsOneWidget);
      expect(find.descendant(of: find.byType(ProfileScreen), matching: find.text('Dates')), findsOneWidget);
    });

    testApp('with no birthdays it says how to add them', (tester) async {
      await add('Sam', daysAgo: 3);
      await pumpApp(tester);
      await tab(tester, 'tab-dates');
      expect(find.text('No birthdays saved yet. Add them on a profile.'), findsOneWidget);
    });
  });

  group('Settings', () {
    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await settle(tester);
    }

    Future<void> reveal(WidgetTester tester, Finder f) =>
        tester.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).last);

    testApp('Backup is first, then groups, profile blocks and awake hours', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await openSettings(tester);
      expect(find.text('Export backup'), findsOneWidget);
      expect(find.text('Import backup'), findsOneWidget);
      await reveal(tester, find.byKey(const Key('awake-end')));
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Profile blocks'), findsOneWidget);
      expect(find.text('Awake hours'), findsOneWidget);
    });

    testApp('changing a group interval changes the ranking on Home', (tester) async {
      await add('Friend', daysAgo: 40); // 40/30 = 1.33
      await add('Sib', group: siblings, daysAgo: 25); // 25/21 = 1.19
      await pumpApp(tester);
      expect(find.descendant(of: find.byKey(const Key('hero-name')), matching: find.text('Friend')), findsOneWidget);

      await openSettings(tester);
      await reveal(tester, find.byKey(Key('group-$friends')));
      await tester.tap(find.byKey(Key('group-$friends')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('group-days')), '90'); // 40/90 = .44: not due
      await tester.tap(find.byKey(const Key('group-save')));
      await settle(tester);
      expect((await repo.getGroup(friends))!.defaultIntervalDays, 90);
      expect(find.text('every 90 days'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await settle(tester);
      expect(find.descendant(of: find.byKey(const Key('hero-name')), matching: find.text('Sib')), findsOneWidget);
      // People shows the new interval too.
      await tab(tester, 'tab-people');
      expect(find.text('FRIENDS · EVERY 90 DAYS'), findsOneWidget);
    });

    testApp('a group can be renamed', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await openSettings(tester);
      await reveal(tester, find.byKey(Key('group-$parents')));
      await tester.tap(find.byKey(Key('group-$parents')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('group-name')), 'Family');
      await tester.tap(find.byKey(const Key('group-save')));
      await settle(tester);
      expect((await repo.getGroup(parents))!.name, 'Family');
    });

    testApp('intervals must be 1 to 365 days', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await openSettings(tester);
      await reveal(tester, find.byKey(Key('group-$friends')));
      await tester.tap(find.byKey(Key('group-$friends')));
      await tester.pumpAndSettle();
      Future<bool> canSave() async => tester.widget<FilledButton>(find.byKey(const Key('group-save'))).onPressed != null;
      await tester.enterText(find.byKey(const Key('group-days')), '0');
      await tester.pumpAndSettle();
      expect(await canSave(), isFalse);
      expect(find.text('Use 1 to 365 days'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('group-days')), '400');
      await tester.pumpAndSettle();
      expect(await canSave(), isFalse);
      await tester.enterText(find.byKey(const Key('group-days')), '');
      await tester.pumpAndSettle();
      expect(await canSave(), isFalse);
      await tester.enterText(find.byKey(const Key('group-days')), '365');
      await tester.pumpAndSettle();
      expect(await canSave(), isTrue);
      await tester.enterText(find.byKey(const Key('group-days')), '12ab'); // digits only
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('group-days'))).controller!.text, '12');
    });

    testApp('add a group, then it is there for new people', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await openSettings(tester);
      await reveal(tester, find.byKey(const Key('add-group')));
      await tester.tap(find.byKey(const Key('add-group')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('group-name')), 'Cousins');
      await tester.enterText(find.byKey(const Key('group-days')), '45');
      await tester.tap(find.byKey(const Key('group-save')));
      await settle(tester);
      final g = (await repo.listGroups()).firstWhere((g) => g.name == 'Cousins');
      expect(g.defaultIntervalDays, 45);
    });

    testApp('a group with people cannot be removed; an empty one can', (tester) async {
      await add('Sam', daysAgo: 60); // Friends
      await pumpApp(tester);
      await openSettings(tester);
      await reveal(tester, find.byKey(Key('group-$friends')));
      await tester.tap(find.byKey(Key('group-$friends')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('group-delete')), findsNothing);
      expect(find.textContaining('has 1 person, so it cannot be removed'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('group-$siblings'))); // nobody in Siblings
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('group-delete')), findsOneWidget);
      await tester.tap(find.byKey(const Key('group-delete')));
      await settle(tester);
      expect((await repo.listGroups()).map((g) => g.name), isNot(contains('Siblings')));
    });

    testApp('archived people still count, so their group stays', (tester) async {
      final p = await add('Old', group: siblings, daysAgo: 60);
      await repo.archivePerson(p);
      await pumpApp(tester);
      await openSettings(tester);
      await reveal(tester, find.byKey(Key('group-$siblings')));
      await tester.tap(find.byKey(Key('group-$siblings')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('group-delete')), findsNothing);
    });

    testApp('the order of profile blocks can be changed and shows on profiles', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await openSettings(tester);
      await reveal(tester, find.byKey(const Key('block-order-about')));
      final list = tester.widget<ReorderableListView>(find.byType(ReorderableListView));
      list.onReorderItem!(2, 0); // About to the top of the three
      await settle(tester);
      expect(repo.blockOrderOf(await repo.getSettings()), ['next_time', 'about', 'family', 'interests']);

      await tester.tap(find.byType(BackButton));
      await settle(tester);
      await tab(tester, 'tab-people');
      await tester.tap(find.text('Sam'));
      await settle(tester);
      final about = tester.getTopLeft(find.byKey(const Key('block-About')));
      final family = tester.getTopLeft(find.byKey(const Key('block-Their people')));
      expect(about.dx, lessThan(family.dx));
      expect(about.dy, family.dy);
      expect((await repo.getPerson(sam)), isNotNull);
    });

    testApp('awake hours show as times, and the window changes who Home suggests', (tester) async {
      await add('Lisbon', zone: 'Europe/Lisbon', daysAgo: 60); // 14:10 there
      await pumpApp(tester);
      expect(find.byKey(const Key('hero-card')), findsOneWidget);
      await openSettings(tester);
      await reveal(tester, find.byKey(const Key('awake-start')));
      expect(find.text('8:00 am'), findsOneWidget);
      expect(find.text('10:00 pm'), findsOneWidget);

      await repo.setAwakeWindow('15:00', '22:00'); // Lisbon is not yet awake at 14:10
      await settle(tester);
      expect(find.text('3:00 pm'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await settle(tester);
      expect(find.byKey(const Key('hero-card')), findsNothing);
      expect(find.text('Nobody is free right now'), findsOneWidget);
    });

    testApp('cancelling the time picker changes nothing', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpApp(tester);
      await openSettings(tester);
      await reveal(tester, find.byKey(const Key('awake-start')));
      await tester.tap(find.byKey(const Key('awake-start')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect((await repo.getSettings()).awakeStart, '08:00');
    });
  });
}

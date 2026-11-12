import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/device_sources.dart';
import 'package:lately/data/phone_launcher.dart';
import 'package:lately/data/providers.dart';
import 'package:lately/data/repository.dart';
import 'package:lately/domain/timezones.dart';
import 'package:lately/features/log/log_sheet.dart';
import 'package:lately/main.dart';

class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

class _Launcher implements PhoneLauncher {
  @override
  Future<bool> call(String number) async => true;
  @override
  Future<bool> message(String number) async => true;
}

void main() {
  late LatelyDatabase db;
  late Repository repo;
  late String friends, parents;
  // 2026-11-11 14:10 UTC = 08:10 in Chicago (you), 14:10 Lisbon, 15:10 Berlin.
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

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        snapshotDirProvider.overrideWithValue(Directory.systemTemp),
        deviceTimezoneProvider.overrideWithValue(_Tz()),
        phoneLauncherProvider.overrideWithValue(_Launcher()),
        nowProvider.overrideWithValue(() => clock),
      ],
      child: const LatelyApp(),
    ));
    await settle(tester);
  }

  /// Moves the clock and lets the one-minute check run.
  Future<void> advance(WidgetTester tester, Duration d) async {
    clock = clock.add(d);
    await tester.pump(const Duration(minutes: 1));
    await settle(tester);
  }

  /// A finished person whose last chat was [daysAgo] days ago (null: no chats,
  /// last-talked estimate instead).
  Future<String> add(String name, {String zone = 'Europe/Lisbon', String? group, int? daysAgo, int? estimate, int? minutes, String length = 'catchup', String? birthday}) async {
    final id = await repo.createPerson(
      displayName: name,
      groupId: group ?? friends,
      timezone: zone,
      timezoneConfirmed: true,
      contactMethodType: 'text',
      contactMethodValue: '+351 555 0100',
      lastTalkedEstimate: estimate == null ? null : clock.subtract(Duration(days: estimate)),
    );
    if (birthday != null) await repo.updatePerson(id, PeopleCompanion(birthday: Value(birthday)));
    if (daysAgo != null) {
      await repo.createChat(
          personId: id, occurredAt: clock.subtract(Duration(days: daysAgo)),
          type: 'call', depth: 'varied', length: length, durationMinutes: minutes);
    }
    return id;
  }

  String text(WidgetTester tester, String key) => tester.widget<Text>(find.byKey(Key(key))).data!;
  Finder heroName(String n) => find.descendant(of: find.byKey(const Key('hero-name')), matching: find.text(n));

  group('the hero card', () {
    testApp('shows the most overdue awake person, with group, local time, why line and actions', (tester) async {
      await add('Sam', daysAgo: 51);
      await add('Bo', daysAgo: 35);
      await pumpHome(tester);
      expect(heroName('Sam'), findsOneWidget);
      expect(find.descendant(of: find.byKey(const Key('hero-card')), matching: find.text('Friends')), findsOneWidget);
      expect(text(tester, 'hero-clock'), '2:10 pm there, likely free');
      expect(text(tester, 'hero-why'), 'Overdue by 3 weeks · probably a 35 minute catch-up');
      expect(find.text('Up next'), findsOneWidget);
      for (final k in ['hero-contact', 'hero-log', 'hero-skip', 'hero-snooze']) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
      expect(find.text('Snooze 7 days'), findsOneWidget);
      expect(find.text('Not today'), findsOneWidget);
    });

    testApp('a higher overdue ratio beats group importance', (tester) async {
      await add('Parent', group: parents, daysAgo: 20, zone: 'America/Chicago'); // 1.43
      await add('Friend', daysAgo: 90); // 3.0
      await pumpHome(tester);
      expect(heroName('Friend'), findsOneWidget);
    });

    testApp('someone asleep right now is not suggested, even if very overdue', (tester) async {
      await add('Asleep', zone: 'Asia/Tokyo', daysAgo: 300); // 23:10 there
      await add('Awake', daysAgo: 40);
      await pumpHome(tester);
      expect(heroName('Awake'), findsOneWidget);
    });

    testApp('Next time shows up to three open lines, and how many more are on the profile', (tester) async {
      final id = await add('Sam', daysAgo: 51);
      for (final t in ['one', 'two', 'three', 'four', 'five']) {
        await repo.createLine(personId: id, block: 'next_time', text: t);
      }
      await pumpHome(tester);
      expect(find.text('one'), findsOneWidget);
      expect(find.text('three'), findsOneWidget);
      expect(find.text('four'), findsNothing);
      expect(find.text('+ 2 more on their profile'), findsOneWidget);
    });

    testApp('with nothing saved, it says how to add things', (tester) async {
      await add('Sam', daysAgo: 51);
      await pumpHome(tester);
      expect(find.text('Nothing saved yet. Add things to ask or mention on their profile.'), findsOneWidget);
    });

    testApp('ticking a Next time line works from Home and keeps the line', (tester) async {
      final id = await add('Sam', daysAgo: 51);
      final l = await repo.createLine(personId: id, block: 'next_time', text: 'Ask about the job');
      await pumpHome(tester);
      await tester.tap(find.byKey(Key('hero-line-$l')));
      await settle(tester);
      expect((await repo.linesFor(id)).single.done, isTrue);
      expect(find.text('Ask about the job'), findsOneWidget);
    });

    testApp('lines already covered in a chat are not shown again', (tester) async {
      final id = await add('Sam', daysAgo: 51);
      final l = await repo.createLine(personId: id, block: 'next_time', text: 'Done and logged');
      await repo.setLineDone(l, true);
      await repo.logChat(personId: id, occurredAt: clock.subtract(const Duration(days: 45)), type: 'call', depth: 'deep', durationMinutes: 20, coveredLineIds: [l]);
      await pumpHome(tester);
      expect(find.text('Done and logged'), findsNothing);
    });

    testApp('the name opens their profile, labelled Home', (tester) async {
      await add('Sam', daysAgo: 51);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-name')));
      await settle(tester);
      expect(find.text('Home'), findsOneWidget); // back label
      expect(find.byKey(const Key('profile-contact')), findsOneWidget);
    });

    testApp('Contact opens the reach sheet and Log opens the popup on the same person', (tester) async {
      await add('Sam', daysAgo: 51);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-contact')));
      await settle(tester);
      expect(find.text('Reach Sam'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10)); // dismiss
      await settle(tester);
      await tester.tap(find.byKey(const Key('hero-log')));
      await settle(tester);
      expect(find.byType(LogSheet), findsOneWidget);
      expect(find.descendant(of: find.byType(LogSheet), matching: find.text('Sam')), findsOneWidget);
    });

    testApp('the floating log button starts on the person Home is showing', (tester) async {
      await add('Sam', daysAgo: 51);
      await add('Bo', daysAgo: 70); // more overdue by days, but a later birthday... same interval, so Bo is hero
      await pumpHome(tester);
      expect(heroName('Bo'), findsOneWidget);
      await tester.tap(find.byKey(const Key('log-fab')));
      await settle(tester);
      expect(find.descendant(of: find.byType(LogSheet), matching: find.text('Bo')), findsOneWidget);
    });

    testApp('people who have not finished setup are left out, and Home says so quietly', (tester) async {
      await repo.createPeople([(displayName: 'Jo', phone: null), (displayName: 'Al', phone: null)],
          groupId: friends, timezone: 'America/Chicago', timezoneConfirmed: false);
      await add('Sam', daysAgo: 51);
      await pumpHome(tester);
      expect(heroName('Sam'), findsOneWidget);
      expect(find.text('2 people still need their setup finished'), findsOneWidget);
    });

    testApp('no overdue counters, badges or totals anywhere', (tester) async {
      await add('Sam', daysAgo: 200);
      await add('Bo', daysAgo: 150);
      await add('Cy', daysAgo: 120);
      await pumpHome(tester);
      expect(find.byType(Badge), findsNothing);
      expect(find.textContaining(RegExp(r'\d+ overdue|\d+ people overdue', caseSensitive: false)), findsNothing);
    });
  });

  group('caught up and other empty cards', () {
    testApp("nobody due: You're caught up", (tester) async {
      await add('Sam', daysAgo: 3);
      await pumpHome(tester);
      expect(find.byKey(const Key('hero-card')), findsNothing);
      expect(text(tester, 'caught-up-title'), "You're caught up");
      expect(text(tester, 'caught-up-body'), 'Nobody is due right now. Enjoy the quiet, or browse everyone.');
    });

    testApp('everyone you could talk to is asleep: who wakes first, and in how long', (tester) async {
      await add('Jun', zone: 'Asia/Tokyo', daysAgo: 80); // 23:10 there: wakes in 8h50
      await add('Alex', zone: 'Australia/Sydney', daysAgo: 80); // 01:10: wakes in 6h50
      await pumpHome(tester);
      expect(text(tester, 'caught-up-title'), 'Nobody is free right now');
      expect(text(tester, 'caught-up-body'), 'Alex wakes in about 7 hours.');
    });

    testApp('everyone snoozed or skipped', (tester) async {
      final a = await add('Sam', daysAgo: 80);
      await repo.snoozeUntil(a, clock.add(const Duration(days: 5)));
      await pumpHome(tester);
      expect(text(tester, 'caught-up-title'), 'Nobody to suggest');
      expect(text(tester, 'caught-up-body'), 'Everyone is snoozed or skipped for today.');
    });

    testApp('Browse everyone opens the people list from the card', (tester) async {
      await add('Sam', daysAgo: 3);
      await pumpHome(tester);
      await tester.tap(find.descendant(of: find.byKey(const Key('caught-up-card')), matching: find.text('Browse everyone')));
      await settle(tester);
      expect(find.text('People'), findsWidgets);
    });
  });

  group('Not today and Snooze', () {
    testApp('Not today hides them until local midnight, with Undo, and shows the next person', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-skip')));
      await settle(tester);
      expect(heroName('Bo'), findsOneWidget);
      expect(find.text('Skipped until tomorrow'), findsOneWidget);
      // Midnight in YOUR timezone (Chicago): 2026-11-12 00:00 CST = 06:00 UTC.
      expect((await repo.getPerson(sam))!.skippedUntil!.toUtc(), DateTime.utc(2026, 11, 12, 6));
      // No "Home moved on" message for your own action.
      expect(find.textContaining('Home moved on'), findsNothing);

      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect((await repo.getPerson(sam))!.skippedUntil, isNull);
      expect(heroName('Sam'), findsOneWidget);
    });

    testApp('skipped people come back after midnight at the same rank', (tester) async {
      await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-skip')));
      await settle(tester);
      expect(heroName('Bo'), findsOneWidget);
      // 2026-11-12 14:00 UTC: after your midnight and daytime in Lisbon.
      await advance(tester, const Duration(hours: 24));
      expect(heroName('Sam'), findsOneWidget);
    });

    testApp('with nobody else, Not today ends the day for them: caught up, not the same card again', (tester) async {
      await add('Only', daysAgo: 60);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-skip')));
      await settle(tester);
      expect(find.byKey(const Key('hero-card')), findsNothing);
      expect(text(tester, 'caught-up-title'), 'Nobody to suggest');
    });

    testApp('a skipped person comes back sooner once everyone else has been talked to today', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      final bo = await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-skip'))); // skip Sam, Bo shows
      await settle(tester);
      expect(heroName('Bo'), findsOneWidget);
      // You talk to Bo today. Nobody else is left, so Sam returns.
      await repo.logChat(personId: bo, occurredAt: clock, type: 'call', depth: 'deep', durationMinutes: 20);
      await settle(tester);
      expect(heroName('Sam'), findsOneWidget);
      expect((await repo.getPerson(sam))!.skippedUntil, isNotNull); // still marked skipped
    });

    testApp('Snooze hides for seven days, with Undo, and they return after that', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-snooze')));
      await settle(tester);
      expect(heroName('Bo'), findsOneWidget);
      expect(find.text('Sam snoozed for 7 days'), findsOneWidget);
      expect((await repo.getPerson(sam))!.snoozedUntil!.toUtc(), clock.add(const Duration(days: 7)));

      await advance(tester, const Duration(days: 7, hours: 1));
      expect(heroName('Sam'), findsOneWidget);
    });

    testApp('Snooze can be undone', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-snooze')));
      await settle(tester);
      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect((await repo.getPerson(sam))!.snoozedUntil, isNull);
      expect(heroName('Sam'), findsOneWidget);
    });
  });

  group('time you have (a soft preference)', () {
    testApp('Any is the default and adds no note', (tester) async {
      await add('Long', daysAgo: 45, minutes: 90, length: 'long');
      await pumpHome(tester);
      expect(find.byKey(const Key('hero-note')), findsNothing);
      expect(tester.widget<Slider>(find.byKey(const Key('time-slider'))).value, 0);
    });

    testApp('15 prefers someone who has short chats; 60+ prefers long ones', (tester) async {
      await add('Short', daysAgo: 42, minutes: 10, length: 'quick'); // ratio 1.4
      await add('Long', daysAgo: 45, minutes: 90, length: 'long'); // ratio 1.5
      await pumpHome(tester);
      expect(heroName('Long'), findsOneWidget); // most overdue with no preference
      await tester.tap(find.byKey(const Key('chip-15')));
      await settle(tester);
      expect(heroName('Short'), findsOneWidget); // fits and is nearly as due
      await tester.tap(find.byKey(const Key('chip-60+')));
      await settle(tester);
      expect(heroName('Long'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chip-Any')));
      await settle(tester);
      expect(heroName('Long'), findsOneWidget);
    });

    testApp('a very overdue person still appears under 15, with a note that a quick hello counts', (tester) async {
      await add('Short', daysAgo: 40, minutes: 10, length: 'quick'); // 1.33
      await add('Far', daysAgo: 150, minutes: 60, length: 'long'); // 5.0
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('chip-15')));
      await settle(tester);
      expect(heroName('Far'), findsOneWidget);
      expect(text(tester, 'hero-note'), 'A quick hello still counts.');
    });

    testApp('the slider moves between the four stops', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpHome(tester);
      tester.widget<Slider>(find.byKey(const Key('time-slider'))).onChanged!(2);
      await settle(tester);
      expect(tester.widget<Slider>(find.byKey(const Key('time-slider'))).value, 2);
      expect(find.text('30'), findsOneWidget);
    });
  });

  group('live refresh', () {
    testApp('when the person shown goes outside their awake hours, Home moves on and says why', (tester) async {
      await add('Lisbon', zone: 'Europe/Lisbon', daysAgo: 90); // awake until 22:00 Lisbon = 22:00 UTC
      await add('Chicago', zone: 'America/Chicago', daysAgo: 60);
      await pumpHome(tester);
      expect(heroName('Lisbon'), findsOneWidget);
      // 21:30 UTC: still awake in Lisbon, and still shown.
      await advance(tester, const Duration(hours: 7, minutes: 20));
      expect(heroName('Lisbon'), findsOneWidget);
      // 22:30 UTC: Lisbon is asleep.
      await advance(tester, const Duration(hours: 1));
      expect(heroName('Chicago'), findsOneWidget);
      expect(find.text('Lisbon is outside their awake hours, so Home moved on to Chicago.'), findsOneWidget);
    });

    testApp('when a more overdue person wakes up, Home moves on to them', (tester) async {
      // Tokyo is asleep at 14:10 UTC (23:10 there) and wakes at 23:00 UTC (08:00).
      await add('Tokyo', zone: 'Asia/Tokyo', daysAgo: 400);
      await add('Sam', zone: 'Europe/Lisbon', daysAgo: 40);
      await pumpHome(tester);
      expect(heroName('Sam'), findsOneWidget);
      await advance(tester, const Duration(hours: 9)); // 23:10 UTC: Tokyo is up, Lisbon is asleep
      expect(heroName('Tokyo'), findsOneWidget);
      expect(find.text('Sam is outside their awake hours, so Home moved on to Tokyo.'), findsOneWidget);
    });

    testApp('the card stays put when nothing about eligibility changes', (tester) async {
      await add('Sam', zone: 'Europe/Lisbon', daysAgo: 40);
      await add('Chi', zone: 'America/Chicago', daysAgo: 38);
      await pumpHome(tester);
      expect(heroName('Sam'), findsOneWidget);
      // An hour later nothing about eligibility changed.
      await advance(tester, const Duration(hours: 1));
      expect(heroName('Sam'), findsOneWidget);
      expect(find.textContaining('Home moved on'), findsNothing);
    });

    testApp('returning to the app re-checks too', (tester) async {
      await add('Lisbon', zone: 'Europe/Lisbon', daysAgo: 90);
      await add('Chicago', zone: 'America/Chicago', daysAgo: 60);
      await pumpHome(tester);
      expect(heroName('Lisbon'), findsOneWidget);
      clock = clock.add(const Duration(hours: 9)); // 23:10 UTC, Lisbon asleep, no timer tick yet
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      expect(heroName('Chicago'), findsOneWidget);
    });

    testApp('logging a chat moves Home on without the "moved on" message', (tester) async {
      await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-log')));
      await settle(tester);
      await tester.tap(find.descendant(of: find.byType(LogSheet), matching: find.text('Call')));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(LogSheet), matching: find.text('Varied')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('log-save')));
      await settle(tester);
      expect(heroName('Bo'), findsOneWidget);
      expect(find.textContaining('Home moved on'), findsNothing);
    });

    testApp('adding the first person makes them the suggestion', (tester) async {
      await pumpHome(tester);
      expect(find.text('Who would you like to stay close to?'), findsOneWidget);
      await add('Sam', daysAgo: 60);
      await settle(tester);
      expect(heroName('Sam'), findsOneWidget);
    });
  });

  group('coming up', () {
    testApp('birthdays within two weeks, including their people, soonest first, three at most', (tester) async {
      final sam = await add('Sam', daysAgo: 3, birthday: '--11-14');
      await add('Alex', daysAgo: 3, birthday: '--11-11'); // today
      await add('Kate', daysAgo: 3, birthday: '--11-20');
      await add('Far', daysAgo: 3, birthday: '--12-30');
      await repo.createRelationship(personId: sam, name: 'Maria', relation: 'mother', birthday: '--11-18');
      await pumpHome(tester);
      expect(find.text("Alex's birthday"), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text("Sam's birthday"), findsOneWidget);
      expect(find.text('Sat, Nov 14'), findsOneWidget);
      expect(find.text("Maria's birthday"), findsOneWidget);
      expect(find.text("Kate's birthday"), findsNothing); // fourth, over the limit of three
      expect(find.text("Far's birthday"), findsNothing);
    });

    testApp('nothing coming up says so', (tester) async {
      await add('Sam', daysAgo: 3);
      await pumpHome(tester);
      expect(find.text('Nothing in the next two weeks.'), findsOneWidget);
    });

    testApp('archived people do not appear', (tester) async {
      final a = await add('Old', daysAgo: 3, birthday: '--11-12');
      await add('Sam', daysAgo: 3);
      await repo.archivePerson(a);
      await pumpHome(tester);
      expect(find.text("Old's birthday"), findsNothing);
    });
  });
}

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
import 'package:lately/features/log/log_sheet.dart';
import 'package:lately/main.dart';

import 'support/fakes.dart';

class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

void main() {
  late LatelyDatabase db;
  late Repository repo;
  late FakeLauncher launcher;
  late String friends, parents;
  // 2026-11-11 14:10 UTC = 08:10 in Chicago (you), 14:10 Lisbon, 15:10 Berlin.
  var clock = DateTime.utc(2026, 11, 11, 14, 10);

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    clock = DateTime.utc(2026, 11, 11, 14, 10);
    launcher = FakeLauncher();
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
        phoneLauncherProvider.overrideWithValue(launcher),
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
      for (final k in ['hero-contact', 'hero-log', 'hero-skip', 'hero-no-answer']) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
      expect(find.text("Didn't answer"), findsOneWidget);
      expect(find.textContaining('Snooze'), findsNothing);
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

    testApp('Next time shows three open lines, and See all expands it on the card', (tester) async {
      final id = await add('Sam', daysAgo: 51);
      for (final t in ['one', 'two', 'three', 'four', 'five']) {
        await repo.createLine(personId: id, block: 'next_time', text: t);
      }
      await pumpHome(tester);
      expect(find.text('one'), findsOneWidget);
      expect(find.text('three'), findsOneWidget);
      expect(find.text('four'), findsNothing);
      expect(find.text('See all (5)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('hero-next-toggle')));
      await tester.pumpAndSettle();
      for (final t in ['one', 'two', 'three', 'four', 'five']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.text('Show less'), findsOneWidget);
      await tester.tap(find.byKey(const Key('hero-next-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('four'), findsNothing);
      expect(find.text('See all (5)'), findsOneWidget);
    });

    testApp('with three or fewer lines there is nothing to expand', (tester) async {
      final id = await add('Sam', daysAgo: 51);
      for (final t in ['one', 'two', 'three']) {
        await repo.createLine(personId: id, block: 'next_time', text: t);
      }
      await pumpHome(tester);
      expect(find.byKey(const Key('hero-next-toggle')), findsNothing);
    });

    testApp('a line in the expanded list can be ticked like any other', (tester) async {
      final id = await add('Sam', daysAgo: 51);
      final ids = <String>[];
      for (final t in ['one', 'two', 'three', 'four']) {
        ids.add(await repo.createLine(personId: id, block: 'next_time', text: t));
      }
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-next-toggle')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('hero-line-${ids[3]}')));
      await settle(tester);
      expect((await repo.linesFor(id)).firstWhere((l) => l.id == ids[3]).done, isTrue);
      expect(find.text('four'), findsOneWidget); // still listed, ticked
    });

    testApp('the next person starts collapsed again', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      final bo = await add('Bo', daysAgo: 40);
      for (final t in ['a1', 'a2', 'a3', 'a4']) {
        await repo.createLine(personId: sam, block: 'next_time', text: t);
        await repo.createLine(personId: bo, block: 'next_time', text: t.replaceFirst('a', 'b'));
      }
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-next-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('a4'), findsOneWidget);
      await tester.tap(find.byKey(const Key('hero-skip')));
      await settle(tester);
      expect(heroName('Bo'), findsOneWidget);
      expect(find.text('b4'), findsNothing); // collapsed for the new person
      expect(find.text('See all (4)'), findsOneWidget);
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

    testApp('Contact opens straight to their preferred app and Log opens the popup on the same person', (tester) async {
      await add('Sam', daysAgo: 51);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-contact')));
      await settle(tester);
      expect(launcher.calls, ['sms:+3515550100']);
      expect(find.textContaining('Reach'), findsNothing); // no chooser
      // You tried: the follow-up prompt is there.
      expect(find.text('Did you get to talk to Sam?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('hero-log')));
      await settle(tester);
      expect(find.byType(LogSheet), findsOneWidget);
      expect(find.descendant(of: find.byType(LogSheet), matching: find.text('Sam')), findsOneWidget);
    });

    testApp('with nothing to reach them by, Contact is disabled', (tester) async {
      final id = await repo.createPerson(displayName: 'Nobody', groupId: friends, timezone: 'Europe/Lisbon', timezoneConfirmed: true, contactMethodType: 'text', lastTalkedEstimate: clock.subtract(const Duration(days: 60)));
      expect(id, isNotEmpty);
      await pumpHome(tester);
      expect(tester.widget<FilledButton>(find.byKey(const Key('hero-contact'))).onPressed, isNull);
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

    testApp('everyone paused', (tester) async {
      final a = await add('Sam', daysAgo: 80);
      await repo.snoozeUntil(a, clock.add(const Duration(days: 5)));
      await pumpHome(tester);
      expect(text(tester, 'caught-up-title'), 'Nobody to suggest');
      expect(text(tester, 'caught-up-body'), 'Everyone is paused or skipped for today.');
    });

    testApp('Browse everyone opens the people list from the card', (tester) async {
      await add('Sam', daysAgo: 3);
      await pumpHome(tester);
      await tester.tap(find.descendant(of: find.byKey(const Key('caught-up-card')), matching: find.text('Browse everyone')));
      await settle(tester);
      expect(find.text('People'), findsWidgets);
    });
  });

  group('Not today', () {
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

    testApp('with nobody else, Not today ends the day for them: finished, not the same card again', (tester) async {
      await add('Only', daysAgo: 60);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-skip')));
      await settle(tester);
      expect(find.byKey(const Key('hero-card')), findsNothing);
      expect(text(tester, 'caught-up-title'), "That's everyone for today");
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

    testApp('skipping everyone ends in a finished card, even if you talked to someone today', (tester) async {
      await add('Ann', daysAgo: 60);
      await add('Bea', daysAgo: 50);
      await add('Cy', daysAgo: 40);
      final done = await add('Dee', daysAgo: 45);
      await repo.logChat(personId: done, occurredAt: clock, type: 'call', depth: 'deep', durationMinutes: 20);
      await pumpHome(tester);
      for (final n in ['Ann', 'Bea', 'Cy']) {
        expect(heroName(n), findsOneWidget, reason: 'expected $n next');
        await tester.tap(find.byKey(const Key('hero-skip')));
        await settle(tester);
      }
      // Everyone left was skipped and nobody else is left to talk to.
      expect(find.byKey(const Key('hero-card')), findsNothing);
      expect(find.byKey(const Key('caught-up-card')), findsOneWidget);
      expect(text(tester, 'caught-up-title'), "That's everyone for today");
    });

    testApp('Not today always changes the card: it never shows the same person again', (tester) async {
      final a = await add('Ann', daysAgo: 60);
      await add('Bea', daysAgo: 50);
      final done = await add('Dee', daysAgo: 45);
      await repo.logChat(personId: done, occurredAt: clock, type: 'call', depth: 'deep', durationMinutes: 20);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-skip'))); // Ann
      await settle(tester);
      expect(heroName('Bea'), findsOneWidget);
      await tester.tap(find.byKey(const Key('hero-skip'))); // Bea
      await settle(tester);
      expect(find.byKey(const Key('hero-card')), findsNothing);
      expect((await repo.getPerson(a))!.skippedUntil, isNotNull);
    });

    testApp('a person who comes back early can be sent away again, with Undo', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      final bo = await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-skip'))); // skip Sam
      await settle(tester);
      await repo.logChat(personId: bo, occurredAt: clock, type: 'call', depth: 'deep', durationMinutes: 20);
      await settle(tester);
      expect(heroName('Sam'), findsOneWidget); // everyone else has been talked to: back early
      await tester.tap(find.byKey(const Key('hero-skip'))); // "Not today" again
      await settle(tester);
      expect(find.byKey(const Key('hero-card')), findsNothing); // does not show Sam again
      expect(text(tester, 'caught-up-title'), "You're caught up"); // Bo talked to, Sam sent away
      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect(heroName('Sam'), findsOneWidget);
      expect((await repo.getPerson(sam))!.snoozedUntil, isNull);
    });

  });

  group("Didn't answer", () {
    testApp('they leave Home for three hours, with Undo, and it is not a chat', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-no-answer')));
      await settle(tester);
      expect(heroName('Bo'), findsOneWidget);
      expect(find.text('Noted. Sam will be back in about 3 hours.'), findsOneWidget);
      final p = (await repo.getPerson(sam))!;
      expect(p.unansweredAt!.toUtc(), clock);
      expect(await repo.chatsFor(sam), hasLength(1)); // still just the old chat: nothing logged
      expect((await repo.lastContactOf(p))!.toUtc(), clock.subtract(const Duration(days: 60)));
      // Not shown as skipped or paused, and no "Home moved on" message for your own action.
      expect(find.textContaining('Home moved on'), findsNothing);

      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect((await repo.getPerson(sam))!.unansweredAt, isNull);
      expect(heroName('Sam'), findsOneWidget);
    });

    testApp("the Undo bar for Didn't answer and Not today also goes after three seconds", (tester) async {
      await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-no-answer')));
      await settle(tester);
      expect(find.text('Undo'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsNothing);
      await tester.tap(find.byKey(const Key('hero-skip')));
      await settle(tester);
      expect(find.text('Undo'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsNothing);
    });

    testApp('they come back after three hours, not before', (tester) async {
      await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-no-answer')));
      await settle(tester);
      await advance(tester, const Duration(hours: 2, minutes: 58));
      expect(heroName('Bo'), findsOneWidget);
      await advance(tester, const Duration(minutes: 3));
      expect(heroName('Sam'), findsOneWidget);
    });

    testApp('once back, they go to the front even if someone else is more overdue', (tester) async {
      final sam = await add('Sam', daysAgo: 40); // ratio 1.3
      await add('Bo', daysAgo: 150); // ratio 5
      await repo.updatePerson(sam, PeopleCompanion(unansweredAt: Value(clock.subtract(const Duration(hours: 4)))));
      await pumpHome(tester);
      expect(heroName('Sam'), findsOneWidget);
      expect(text(tester, 'hero-why').startsWith('You tried earlier · Overdue by'), isTrue);
    });

    testApp('someone who was not due yet is still brought back after you tried', (tester) async {
      final sam = await add('Sam', daysAgo: 5); // ratio .17: normally not due
      await add('Bo', daysAgo: 40);
      await repo.updatePerson(sam, PeopleCompanion(unansweredAt: Value(clock.subtract(const Duration(hours: 4)))));
      await pumpHome(tester);
      expect(heroName('Sam'), findsOneWidget);
      expect(text(tester, 'hero-why').startsWith('You tried earlier'), isTrue);
    });

    testApp('the time preference does not push them down', (tester) async {
      final sam = await add('Sam', daysAgo: 40, minutes: 90, length: 'long');
      await add('Short', daysAgo: 45, minutes: 10, length: 'quick');
      await repo.updatePerson(sam, PeopleCompanion(unansweredAt: Value(clock.subtract(const Duration(hours: 4)))));
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('chip-15')));
      await settle(tester);
      expect(heroName('Sam'), findsOneWidget);
    });

    testApp('the boost fades after a week', (tester) async {
      final sam = await add('Sam', daysAgo: 40);
      await add('Bo', daysAgo: 150);
      await repo.updatePerson(sam, PeopleCompanion(unansweredAt: Value(clock.subtract(const Duration(days: 8)))));
      await pumpHome(tester);
      expect(heroName('Bo'), findsOneWidget); // back to normal order
    });

    testApp('logging a chat clears it', (tester) async {
      final sam = await add('Sam', daysAgo: 40);
      await repo.updatePerson(sam, PeopleCompanion(unansweredAt: Value(clock.subtract(const Duration(hours: 4)))));
      await repo.logChat(personId: sam, occurredAt: clock, type: 'call', depth: 'varied', durationMinutes: 20);
      expect((await repo.getPerson(sam))!.unansweredAt, isNull);
    });

    testApp('a person who is asleep stays out, even boosted', (tester) async {
      final jun = await add('Jun', zone: 'Asia/Tokyo', daysAgo: 60); // 23:10 there
      await repo.updatePerson(jun, PeopleCompanion(unansweredAt: Value(clock.subtract(const Duration(hours: 4)))));
      await pumpHome(tester);
      expect(find.byKey(const Key('hero-card')), findsNothing);
      expect(text(tester, 'caught-up-title'), 'Nobody is free right now');
    });

    testApp('the card says when they will be back', (tester) async {
      await add('Sam', daysAgo: 60);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-no-answer')));
      await settle(tester);
      expect(find.byKey(const Key('hero-card')), findsNothing);
      expect(text(tester, 'caught-up-title'), 'Nobody is free right now');
      expect(text(tester, 'caught-up-body'), 'Sam is back in about 3 hours.');
    });

    testApp('trying again later restarts the three hours', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await repo.updatePerson(sam, PeopleCompanion(unansweredAt: Value(clock.subtract(const Duration(hours: 5)))));
      await pumpHome(tester);
      expect(heroName('Sam'), findsOneWidget); // back, and boosted
      await tester.tap(find.byKey(const Key('hero-no-answer')));
      await settle(tester);
      expect(heroName('Bo'), findsOneWidget);
      expect((await repo.getPerson(sam))!.unansweredAt!.toUtc(), clock);
    });

    testApp('the People tab says Try again later while they are out', (tester) async {
      await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('hero-no-answer')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      expect(find.text('Try again later'), findsOneWidget);
    });

    testApp('right after Contact, the prompt offers Didn\'t answer', (tester) async {
      final sam = await add('Sam', daysAgo: 60);
      await add('Bo', daysAgo: 40);
      await repo.setRecentContact(sam);
      await pumpHome(tester);
      expect(find.text('Did you get to talk to Sam?'), findsOneWidget);
      expect(find.text('Log it'), findsOneWidget);
      expect(find.text('Not yet'), findsOneWidget);
      await tester.tap(find.byKey(const Key('prompt-no-answer')));
      await settle(tester);
      expect(find.text('Did you get to talk to Sam?'), findsNothing);
      expect((await repo.getSettings()).recentContactPersonId, isNull);
      expect((await repo.getPerson(sam))!.unansweredAt, isNotNull);
      expect(heroName('Bo'), findsOneWidget);
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

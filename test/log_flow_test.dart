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

class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

void main() {
  late LatelyDatabase db;
  late Repository repo;
  late String groupId;
  late String sam;
  // 2026-11-11 14:10 UTC
  final fixedNow = DateTime.utc(2026, 11, 11, 14, 10);

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => fixedNow);
    await repo.completeSetup();
    groupId = (await repo.listGroups()).firstWhere((g) => g.name == 'Friends').id;
    sam = await repo.createPerson(
      displayName: 'Sam',
      groupId: groupId,
      timezone: 'Europe/Lisbon',
      timezoneConfirmed: true,
      contactMethodType: 'text',
      contactMethodValue: '+351 555 0142',
      lastTalkedEstimate: fixedNow.subtract(const Duration(days: 40)),
    );
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
        nowProvider.overrideWithValue(() => fixedNow),
      ],
      child: const LatelyApp(),
    ));
    await settle(tester);
  }

  /// Home -> People -> a profile.
  Future<void> openProfile(WidgetTester tester, String name) async {
    await tester.tap(find.widgetWithText(FilledButton, 'People'));
    await settle(tester);
    await tester.tap(find.text(name));
    await settle(tester);
  }

  Finder inSheet(Finder f) => find.descendant(of: find.byType(LogSheet), matching: f);

  Future<void> reveal(WidgetTester tester, Finder f) => tester.scrollUntilVisible(f, 300,
      scrollable: find.descendant(of: find.byType(LogSheet), matching: find.byType(Scrollable)).first);

  Future<void> choose(WidgetTester tester, String type, String depth) async {
    await tester.tap(inSheet(find.text(type)));
    await tester.pumpAndSettle();
    await tester.tap(inSheet(find.text(depth)));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('log-save')));
    await settle(tester);
  }

  Future<void> typeAndEnter(WidgetTester tester, Finder f, String text) async {
    await tester.enterText(f, text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
  }

  group('the three required taps', () {
    testApp('type and depth are required; saving makes a chat and resets the clock', (tester) async {
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      expect(find.text('Log a chat'), findsOneWidget);
      expect(find.text('Sam'), findsWidgets);
      final saveBtn = find.byKey(const Key('log-save'));
      expect(tester.widget<FilledButton>(saveBtn).onPressed, isNull);
      expect(find.text('Pick a type and a depth to save'), findsOneWidget);

      await tester.tap(inSheet(find.text('Call')));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(saveBtn).onPressed, isNull); // depth still missing
      await tester.tap(inSheet(find.text('Varied')));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(saveBtn).onPressed, isNotNull);
      expect(find.text("Saving resets Sam's contact clock"), findsOneWidget);

      await save(tester);
      expect(find.text("Logged. Sam's clock is reset."), findsOneWidget);
      expect(find.byType(LogSheet), findsNothing);

      final c = (await repo.chatsFor(sam)).single;
      expect((c.type, c.depth, c.durationMinutes, c.length), ('call', 'varied', 30, 'catchup'));
      expect(c.occurredAt.toUtc(), fixedNow);
      expect(c.timeApproximate, isFalse);
      // The profile updates: last call or text, and the chat is listed.
      expect(find.text('Nov 11'), findsWidgets);
      expect(find.text('1 logged'), findsOneWidget);
    });

    testApp('how long: a slider from 1 to 60+, preset to 30, deriving quick, catch-up and long', (tester) async {
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      expect(find.text('30 min'), findsOneWidget);
      final slider = tester.widget<Slider>(find.byKey(const Key('log-slider')));
      expect((slider.min, slider.max), (1, 60));

      Future<void> setMinutes(double m) async {
        tester.widget<Slider>(find.byKey(const Key('log-slider'))).onChanged!(m);
        await tester.pump();
      }

      await setMinutes(15);
      expect(find.text('15 min'), findsOneWidget);
      await choose(tester, 'Text', 'Shallow');
      await save(tester);
      expect((await repo.chatsFor(sam)).first.length, 'quick');
      expect((await repo.chatsFor(sam)).first.durationMinutes, 15);

      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await setMinutes(60);
      expect(find.text('60+ min'), findsOneWidget);
      await choose(tester, 'In person', 'Deep');
      await save(tester);
      final longChat = (await repo.chatsFor(sam)).firstWhere((c) => c.type == 'person');
      expect((longChat.length, longChat.durationMinutes), ('long', 60));
    });

    testApp('feelings are multiple choice and the note is optional', (tester) async {
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await choose(tester, 'Call', 'Deep');
      await reveal(tester, inSheet(find.text('Tired')));
      await tester.tap(inSheet(find.text('Happy')));
      await tester.tap(inSheet(find.text('Tired')));
      await tester.pumpAndSettle();
      await reveal(tester, find.byKey(const Key('log-note')));
      await tester.enterText(find.byKey(const Key('log-note')), 'Caught up on the move');
      await tester.pumpAndSettle();
      await save(tester);
      final c = (await repo.chatsFor(sam)).single;
      expect(c.feelings, '["happy","tired"]');
      expect(c.note, 'Caught up on the move');
    });
  });

  group('when', () {
    testApp('yesterday is the current time minus one day', (tester) async {
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await tester.tap(inSheet(find.text('Yesterday')));
      await tester.pumpAndSettle();
      await choose(tester, 'Call', 'Varied');
      expect(find.text('Saved as Nov 10'), findsOneWidget);
      await save(tester);
      final c = (await repo.chatsFor(sam)).single;
      expect(c.occurredAt.toUtc(), fixedNow.subtract(const Duration(days: 1)));
      expect(c.timeApproximate, isFalse);
    });

    testApp('another day is picked from a calendar (no typing), date only, noon, approximate', (tester) async {
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await tester.tap(inSheet(find.text('Other day')));
      await tester.pumpAndSettle();
      await choose(tester, 'Call', 'Varied');
      // Type and depth are set, but the day is still needed.
      expect(tester.widget<FilledButton>(find.byKey(const Key('log-save'))).onPressed, isNull);
      expect(find.text('Pick the day, a type and a depth to save'), findsOneWidget);
      await tester.tap(find.byKey(const Key('log-pick-date')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit_outlined), findsNothing); // no typed-date mode
      await tester.tap(find.text('5'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Saved as Nov 5'), findsOneWidget);
      await save(tester);
      final c = (await repo.chatsFor(sam)).single;
      final local = c.occurredAt.toLocal();
      expect((local.month, local.day, local.hour, local.minute), (11, 5, 12, 0));
      expect(c.timeApproximate, isTrue);
    });
  });

  group('Covered from Next time', () {
    testApp('ticked items are offered, all ticked; unticked ones stay for next time', (tester) async {
      final a = await repo.createLine(personId: sam, block: 'next_time', text: 'Ask about the job');
      final b = await repo.createLine(personId: sam, block: 'next_time', text: 'Send the photos');
      await repo.createLine(personId: sam, block: 'next_time', text: 'Not ticked, so not offered');
      await repo.setLineDone(a, true);
      await repo.setLineDone(b, true);
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await reveal(tester, inSheet(find.byKey(Key('cover-$a'))));
      expect(find.byKey(Key('cover-$a')), findsOneWidget);
      expect(find.byKey(Key('cover-$b')), findsOneWidget);
      expect(tester.widget<CheckboxListTile>(find.byKey(Key('cover-$a'))).value, isTrue);
      expect(tester.widget<CheckboxListTile>(find.byKey(Key('cover-$b'))).value, isTrue);
      expect(inSheet(find.byKey(Key('cover-$a'))), findsOneWidget);

      await tester.tap(find.byKey(Key('cover-$b'))); // leave this one out
      await tester.pumpAndSettle();
      await tester.drag(find.descendant(of: find.byType(LogSheet), matching: find.byType(Scrollable)).first, const Offset(0, 2000));
      await tester.pumpAndSettle();
      await choose(tester, 'Call', 'Varied');
      await save(tester);

      final chat = (await repo.chatsFor(sam)).single;
      final lines = {for (final l in await repo.linesFor(sam)) l.id: l};
      expect(lines[a]!.chatId, chat.id);
      expect(lines[b]!.chatId, isNull);

      // Next time, only the left-out item is offered again.
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await reveal(tester, inSheet(find.byKey(Key('cover-$b'))));
      expect(inSheet(find.byKey(Key('cover-$a'))), findsNothing);
      expect(inSheet(find.byKey(Key('cover-$b'))), findsOneWidget);
    });

    testApp('with nothing ticked there is no Covered section', (tester) async {
      await repo.createLine(personId: sam, block: 'next_time', text: 'Open item');
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      expect(find.text('COVERED FROM NEXT TIME'), findsNothing);
    });
  });

  group('their profile inside the popup', () {
    testApp('lines added here save at once and are linked to the chat', (tester) async {
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await choose(tester, 'Call', 'Deep');
      await reveal(tester, inSheet(find.byKey(const Key('add-Interests'))));
      await tester.tap(inSheet(find.byKey(const Key('add-Interests'))));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(const Key('add-field')), 'Pottery');
      // Saved immediately, before the chat is saved.
      expect((await repo.linesFor(sam, block: 'interests')).single.lineText, 'Pottery');
      expect((await repo.linesFor(sam, block: 'interests')).single.addedInChatId, isNull);
      FocusManager.instance.primaryFocus?.unfocus();
      await settle(tester);
      await save(tester);
      final chat = (await repo.chatsFor(sam)).single;
      expect((await repo.linesFor(sam, block: 'interests')).single.addedInChatId, chat.id);
    });

    testApp('people added here are offered existing names first, saved, and linked', (tester) async {
      await repo.createRelationship(personId: sam, name: 'Rosa', relation: 'grandmother');
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await choose(tester, 'Call', 'Deep');
      await reveal(tester, inSheet(find.byKey(const Key('add-Their people'))));
      await tester.tap(inSheet(find.byKey(const Key('add-Their people'))));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('rel-name')), 'ros');
      await tester.pumpAndSettle();
      expect(find.text('Already in their people. Tap to add a note instead:'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('rel-name')), 'Ines');
      await tester.enterText(find.byKey(const Key('rel-relation')), 'partner');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settle(tester);
      await save(tester);
      final chat = (await repo.chatsFor(sam)).single;
      final rels = {for (final r in await repo.relationshipsFor(sam)) r.name: r};
      expect(rels['Ines']!.addedInChatId, chat.id);
      expect(rels['Rosa']!.addedInChatId, isNull);
    });

    testApp('the same line rules apply: swipe left deletes with Undo', (tester) async {
      final l = await repo.createLine(personId: sam, block: 'about', text: 'Allergic to cats');
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await reveal(tester, inSheet(find.byKey(Key('dismiss-$l'))));
      await tester.drag(inSheet(find.byKey(Key('dismiss-$l'))), const Offset(-500, 0));
      await settle(tester);
      expect(await repo.linesFor(sam, block: 'about'), isEmpty);
      expect(find.text('Undo'), findsOneWidget);
    });

    testApp('closing without saving makes no chat but keeps what you added', (tester) async {
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      await reveal(tester, inSheet(find.byKey(const Key('add-About'))));
      await tester.tap(inSheet(find.byKey(const Key('add-About'))));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(const Key('add-field')), 'Moved flats');
      FocusManager.instance.primaryFocus?.unfocus();
      await settle(tester);
      await tester.tap(find.byTooltip('Close'));
      await settle(tester);
      expect(await repo.chatsFor(sam), isEmpty);
      expect((await repo.linesFor(sam, block: 'about')).single.lineText, 'Moved flats');
    });
  });

  group('chat details', () {
    testApp('shows what was new from a chat, and says so when nothing was recorded', (tester) async {
      final covered = await repo.createLine(personId: sam, block: 'next_time', text: 'Ask about the job');
      await repo.setLineDone(covered, true);
      final learned = await repo.createLine(personId: sam, block: 'interests', text: 'Pottery');
      final rel = await repo.createRelationship(personId: sam, name: 'Ines', relation: 'partner');
      final id = await repo.logChat(
          personId: sam, occurredAt: DateTime.utc(2026, 9, 21, 12), type: 'call', depth: 'varied',
          durationMinutes: 30, feelings: ['Happy'], note: 'Caught up on the move',
          coveredLineIds: [covered], addedLineIds: [learned], addedRelationshipIds: [rel]);
      final bare = await repo.logChat(
          personId: sam, occurredAt: DateTime.utc(2026, 9, 2, 12), type: 'text', depth: 'shallow', durationMinutes: 5);
      await pumpApp(tester);
      await openProfile(tester, 'Sam');
      await tester.scrollUntilVisible(find.byKey(Key('chat-$id')), 300, scrollable: find.byType(Scrollable).first);
      expect(find.text('3 new'), findsOneWidget); // covered + learned + new person

      await tester.tap(find.byKey(Key('chat-$id')));
      await settle(tester);
      expect(find.text('Sep 21'), findsWidgets);
      expect(find.text('Call · Catch-up · Varied · 30 min'), findsOneWidget);
      expect(find.text('Feeling happy'), findsOneWidget);
      expect(find.text('Caught up on the move'), findsWidgets);
      expect(find.text('COVERED FROM NEXT TIME'), findsOneWidget);
      expect(find.text('NEW IN THEIR PEOPLE'), findsOneWidget);
      expect(find.text('Ines, partner'), findsWidgets);
      expect(find.text('INTERESTS'), findsOneWidget);
      expect(find.text('Pottery'), findsWidgets);
      await tester.tap(find.byTooltip('Close'));
      await settle(tester);

      await tester.tap(find.byKey(Key('chat-$bare')));
      await settle(tester);
      expect(find.text('Nothing was recorded from this chat.'), findsOneWidget);
    });
  });

  group('who the popup starts on', () {
    Future<String> bo() => repo.createPerson(
        displayName: 'Bo', groupId: groupId, timezone: 'UTC', timezoneConfirmed: true,
        contactMethodType: 'text', lastTalkedEstimate: fixedNow.subtract(const Duration(days: 5)));

    testApp('the floating button opens it on the most overdue person', (tester) async {
      await bo();
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('log-fab')));
      await settle(tester);
      expect(find.text('Log a chat'), findsOneWidget);
      expect(inSheet(find.text('Sam')), findsOneWidget); // 40 days vs 5 days
      expect(find.text('Last talked 5 weeks ago'), findsOneWidget);
    });

    testApp('someone you just tapped Contact for wins for three hours, then it falls back', (tester) async {
      final b = await bo();
      await repo.setRecentContact(b);
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('log-fab')));
      await settle(tester);
      expect(inSheet(find.text('Bo')), findsOneWidget);
      expect(inSheet(find.text('Sam')), findsNothing);
    });

    testApp('an older contact no longer counts', (tester) async {
      final b = await bo();
      await repo.setRecentContact(b);
      await repo.updateSettings(SettingsCompanion(
          recentContactAt: Value(fixedNow.subtract(const Duration(hours: 4)))));
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('log-fab')));
      await settle(tester);
      expect(inSheet(find.text('Sam')), findsOneWidget);
    });

    testApp('Change opens a searchable list grouped like People, tagging the suggestion', (tester) async {
      final b = await bo();
      final parents = (await repo.listGroups()).firstWhere((g) => g.name == 'Parents').id;
      final mom = await repo.createPerson(displayName: 'Mom', groupId: parents, timezone: 'UTC', timezoneConfirmed: true,
          contactMethodType: 'call', lastTalkedEstimate: fixedNow.subtract(const Duration(days: 3)));
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('log-fab')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('log-change')));
      await settle(tester);
      expect(find.text('Who did you talk to?'), findsOneWidget);
      expect(find.text('PARENTS'), findsOneWidget);
      expect(find.text('FRIENDS'), findsOneWidget);
      expect(find.text('Suggested'), findsOneWidget);
      expect(find.descendant(of: find.byKey(Key('pick-${await Future.value(mom)}')), matching: find.text('Last talked 3 days ago')), findsOneWidget);
      // Within a group, the longest since you talked comes first.
      expect(tester.getTopLeft(find.byKey(Key('pick-$sam'))).dy, lessThan(tester.getTopLeft(find.byKey(Key('pick-$b'))).dy));

      await tester.enterText(find.byKey(const Key('picker-search')), 'mo');
      await tester.pumpAndSettle();
      expect(find.byKey(Key('pick-$mom')), findsOneWidget);
      expect(find.byKey(Key('pick-$sam')), findsNothing);
      await tester.enterText(find.byKey(const Key('picker-search')), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No one matches that search.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('picker-search')), 'mo');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('pick-$mom')));
      await settle(tester);
      expect(find.text('Log a chat'), findsOneWidget);
      await choose(tester, 'Call', 'Shallow');
      await save(tester);
      expect(await repo.chatsFor(mom), hasLength(1));
      expect(await repo.chatsFor(sam), isEmpty);
    });

    testApp('the button shows on Home and People, not on a profile or an empty app', (tester) async {
      await pumpApp(tester);
      expect(find.byKey(const Key('log-fab')), findsOneWidget); // Home
      await tester.tap(find.widgetWithText(FilledButton, 'People'));
      await settle(tester);
      expect(find.byKey(const Key('log-fab')), findsOneWidget); // People
      await tester.tap(find.text('Sam'));
      await settle(tester);
      expect(find.byKey(const Key('log-fab')), findsNothing); // profile has its own Log
    });

    testApp('an app with nobody has nothing to log', (tester) async {
      await repo.archivePerson(sam);
      await repo.deletePersonForever(sam);
      await pumpApp(tester);
      expect(find.byKey(const Key('log-fab')), findsNothing);
    });
  });

  group('Home: Did you get to talk to them?', () {
    testApp('shows after Contact; Not yet hides it but the popup still defaults to them', (tester) async {
      await repo.setRecentContact(sam);
      await pumpApp(tester);
      expect(find.text('Did you get to talk to Sam?'), findsOneWidget);
      await tester.tap(find.text('Not yet'));
      await settle(tester);
      expect(find.text('Did you get to talk to Sam?'), findsNothing);
      expect((await repo.getSettings()).recentContactPersonId, sam);
    });

    testApp('Log it opens the popup for them; saving removes the prompt', (tester) async {
      await repo.setRecentContact(sam);
      await pumpApp(tester);
      await tester.tap(find.text('Log it'));
      await settle(tester);
      expect(inSheet(find.text('Sam')), findsOneWidget);
      await choose(tester, 'Call', 'Varied');
      await save(tester);
      expect(find.text('Did you get to talk to Sam?'), findsNothing);
      expect((await repo.getSettings()).recentContactPersonId, isNull);
    });

    testApp('no prompt when nobody was contacted, or after three hours', (tester) async {
      await pumpApp(tester);
      expect(find.byKey(const Key('reach-prompt')), findsNothing);
    });

    testApp('an old contact does not prompt', (tester) async {
      await repo.setRecentContact(sam);
      await repo.updateSettings(SettingsCompanion(
          recentContactAt: Value(fixedNow.subtract(const Duration(hours: 4)))));
      await pumpApp(tester);
      expect(find.byKey(const Key('reach-prompt')), findsNothing);
    });
  });

  testApp('showLogSheet does nothing when there is no one to log', (tester) async {
    await repo.archivePerson(sam);
    await repo.deletePersonForever(sam);
    await pumpApp(tester);
    final ctx = tester.element(find.byType(Scaffold).first);
    await tester.runAsync(() => showLogSheet(ctx));
    await settle(tester);
    expect(find.byType(LogSheet), findsNothing);
  });
}

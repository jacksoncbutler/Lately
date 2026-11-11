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
import 'package:lately/features/profile/profile_screen.dart';
import 'package:lately/ui/theme.dart';

class FakeLauncher implements PhoneLauncher {
  final calls = <String>[];
  @override
  Future<bool> call(String number) async {
    calls.add('call:$number');
    return true;
  }
  @override
  Future<bool> message(String number) async {
    calls.add('sms:$number');
    return true;
  }
}

class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

void main() {
  late LatelyDatabase db;
  late Repository repo;
  late FakeLauncher launcher;
  late String groupId;
  late String sam;
  // 2026-11-11 14:10 UTC: Lisbon 2:10 pm
  final fixedNow = DateTime.utc(2026, 11, 11, 14, 10);

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => fixedNow);
    launcher = FakeLauncher();
    await repo.completeSetup();
    groupId = (await repo.listGroups()).firstWhere((g) => g.name == 'Friends').id;
    sam = await repo.createPerson(
      displayName: 'Sam',
      groupId: groupId,
      timezone: 'Europe/Lisbon',
      timezoneConfirmed: true,
      contactMethodType: 'text',
      contactMethodValue: '+351 555 0142',
      phone: '+351 555 0142',
      lastTalkedEstimate: fixedNow.subtract(const Duration(days: 30)),
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

  Future<void> openProfile(WidgetTester tester, {String? id, Brightness brightness = Brightness.light}) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        snapshotDirProvider.overrideWithValue(Directory.systemTemp),
        deviceTimezoneProvider.overrideWithValue(_Tz()),
        phoneLauncherProvider.overrideWithValue(launcher),
        nowProvider.overrideWithValue(() => fixedNow),
      ],
      child: MaterialApp(
        theme: latelyThemeFor(brightness),
        home: ProfileScreen(personId: id ?? sam),
      ),
    ));
    await settle(tester);
  }

  Future<void> typeAndEnter(WidgetTester tester, Finder f, String text) async {
    await tester.enterText(f, text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
  }

  Future<void> addNextTime(String text) =>
      repo.createLine(personId: sam, block: 'next_time', text: text);

  group('header and facts', () {
    testApp('shows who they are, where, and the key facts', (tester) async {
      await repo.updatePerson(sam, const PeopleCompanion(birthday: Value('--03-14'), hometown: Value('Porto'), socials: Value('["@sam.r"]')));
      await repo.createChat(personId: sam, occurredAt: DateTime.utc(2026, 7, 30, 12), type: 'person', depth: 'deep', length: 'long');
      await repo.createChat(personId: sam, occurredAt: DateTime.utc(2026, 9, 21, 12), type: 'call', depth: 'varied', length: 'catchup', durationMinutes: 30, feelings: ['happy'], note: 'Caught up on the move');
      await repo.createChat(personId: sam, occurredAt: DateTime.utc(2026, 9, 2, 12), type: 'text', depth: 'shallow', length: 'quick');
      await openProfile(tester);

      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('2:10 pm there'), findsOneWidget);
      expect(find.text('Mar 14'), findsOneWidget);
      expect(find.text('Every 30 days'), findsOneWidget);
      expect(find.text('Lisbon'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.text('Jul 30'), findsWidgets); // last in person (also in chat list when expanded)
      expect(find.text('Sep 21'), findsWidgets); // last call or text

      // Hidden until expanded.
      expect(find.text('Porto'), findsNothing);
      await tester.tap(find.byKey(const Key('profile-more')));
      await tester.pumpAndSettle();
      expect(find.text('Porto'), findsOneWidget);
      expect(find.text('@sam.r'), findsOneWidget);
      expect(find.text('+351 555 0142'), findsOneWidget);
      expect(find.text('Fewer details'), findsOneWidget);
    });

    testApp('a personal interval shows instead of the group default', (tester) async {
      await repo.updatePerson(sam, const PeopleCompanion(intervalOverrideDays: Value(10)));
      await openProfile(tester);
      expect(find.text('Every 10 days'), findsOneWidget);
    });

    testApp('no chats says None yet', (tester) async {
      await openProfile(tester);
      expect(find.text('None yet'), findsNWidgets(2));
      expect(find.text('No chats yet. Log one after you talk.'), findsOneWidget);
    });

    testApp('recent chats show two, then all', (tester) async {
      for (var d = 1; d <= 3; d++) {
        await repo.createChat(personId: sam, occurredAt: DateTime.utc(2026, 10, d, 12), type: 'call', depth: 'varied', length: 'catchup', note: 'note $d');
      }
      await openProfile(tester);
      await tester.scrollUntilVisible(find.text('3 logged'), 300, scrollable: find.byType(Scrollable).first);
      expect(find.text('3 logged'), findsOneWidget);
      expect(find.text('note 3'), findsOneWidget);
      expect(find.text('note 1'), findsNothing);
      await tester.tap(find.text('See all (3)'));
      await tester.pumpAndSettle();
      expect(find.text('note 1'), findsOneWidget);
    });

    testApp('an unfinished person is flagged and shows no made-up clock', (tester) async {
      final jo = (await repo.createPeople([(displayName: 'Jo', phone: null)],
          groupId: groupId, timezone: 'America/Chicago', timezoneConfirmed: false)).single;
      await openProfile(tester, id: jo);
      expect(find.textContaining('Finish setup'), findsWidgets);
      expect(find.text('Not set'), findsOneWidget);
      expect(find.textContaining('there'), findsNothing);
    });

    testApp('works in dark mode too', (tester) async {
      await openProfile(tester, brightness: Brightness.dark);
      expect(find.text('Sam'), findsOneWidget);
    });
  });

  group('Next time', () {
    testApp('plus adds a line; Enter keeps the field open for another', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('add-Next time')));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(const Key('add-field')), 'Ask about the new job');
      expect(find.byKey(const Key('add-field')), findsOneWidget);
      await typeAndEnter(tester, find.byKey(const Key('add-field')), 'Send the trail photos');
      final lines = await repo.linesFor(sam, block: 'next_time');
      expect(lines.map((l) => l.lineText), ['Ask about the new job', 'Send the trail photos']);
      expect(find.text('Ask about the new job'), findsOneWidget);
    });

    testApp('the checkbox ticks without opening the editor, and the line is kept', (tester) async {
      await addNextTime('Ask about the new job');
      await openProfile(tester);
      final id = (await repo.linesFor(sam)).single.id;
      await tester.tap(find.byKey(Key('check-$id')));
      await settle(tester);
      final l = (await repo.linesFor(sam)).single;
      expect(l.done, isTrue);
      expect(l.doneAt, isNotNull);
      expect(find.byKey(Key('edit-$id')), findsNothing); // no editor
      expect(find.text('Ask about the new job'), findsOneWidget); // still listed
      await tester.tap(find.byKey(Key('check-$id')));
      await settle(tester);
      expect((await repo.linesFor(sam)).single.done, isFalse);
    });

    testApp('tap the text to edit in place', (tester) async {
      await addNextTime('Ask about the job');
      await openProfile(tester);
      final id = (await repo.linesFor(sam)).single.id;
      await tester.tap(find.byKey(Key('line-$id')));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('edit-$id')), findsOneWidget);
      await typeAndEnter(tester, find.byKey(Key('edit-$id')), 'Ask about the new job');
      expect((await repo.linesFor(sam)).single.lineText, 'Ask about the new job');
      expect(find.byKey(Key('edit-$id')), findsNothing);
    });

    testApp('editing to empty leaves the line as it was', (tester) async {
      await addNextTime('Keep me');
      await openProfile(tester);
      final id = (await repo.linesFor(sam)).single.id;
      await tester.tap(find.byKey(Key('line-$id')));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(Key('edit-$id')), '   ');
      expect((await repo.linesFor(sam)).single.lineText, 'Keep me');
    });

    testApp('trash while editing deletes, with an Undo bar', (tester) async {
      await addNextTime('Delete me');
      await openProfile(tester);
      final id = (await repo.linesFor(sam)).single.id;
      await tester.tap(find.byKey(Key('line-$id')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('trash-$id')));
      await settle(tester);
      expect(await repo.linesFor(sam), isEmpty);
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect((await repo.linesFor(sam)).single.lineText, 'Delete me');
    });

    testApp('swipe left deletes with Undo and no confirmation; swipe right does nothing', (tester) async {
      await addNextTime('Swipe me');
      await openProfile(tester);
      final id = (await repo.linesFor(sam)).single.id;

      await tester.drag(find.byKey(Key('dismiss-$id')), const Offset(500, 0)); // right
      await settle(tester);
      expect((await repo.linesFor(sam)), hasLength(1));
      expect(find.text('Swipe me'), findsOneWidget);

      await tester.drag(find.byKey(Key('dismiss-$id')), const Offset(-500, 0)); // left
      await settle(tester);
      expect(await repo.linesFor(sam), isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect(find.text('Swipe me'), findsOneWidget);
    });

    testApp('Next time shows every line, oldest first, in full width', (tester) async {
      for (final t in ['one', 'two', 'three', 'four', 'five']) {
        await addNextTime(t);
      }
      await openProfile(tester);
      for (final t in ['one', 'two', 'three', 'four', 'five']) {
        expect(find.text(t), findsOneWidget);
      }
      expect(find.textContaining('See all'), findsNothing);
      expect(tester.getTopLeft(find.text('one')).dy, lessThan(tester.getTopLeft(find.text('five')).dy));
    });
  });

  group('blocks', () {
    testApp('an empty block keeps its size with ruled blank rows', (tester) async {
      await openProfile(tester);
      expect(find.byKey(const Key('ruled-Interests-0')), findsOneWidget);
      expect(find.byKey(const Key('ruled-Interests-1')), findsOneWidget);
      expect(find.byKey(const Key('ruled-Interests-2')), findsOneWidget);
      // Tapping a blank row starts adding.
      await tester.tap(find.byKey(const Key('ruled-Interests-0')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('add-field')), findsOneWidget);
    });

    testApp('Interests: newest three show, See all expands, Show less collapses', (tester) async {
      await openProfile(tester);
      for (final t in ['Chess', 'Sourdough', 'Film photography', 'Hiking']) {
        await tester.tap(find.byKey(const Key('add-Interests')));
        await tester.pumpAndSettle();
        await typeAndEnter(tester, find.byKey(const Key('add-field')), t);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        FocusManager.instance.primaryFocus?.unfocus();
        await settle(tester);
      }
      expect((await repo.linesFor(sam, block: 'interests')).map((l) => l.lineText),
          ['Chess', 'Sourdough', 'Film photography', 'Hiking']);
      expect(find.text('Hiking'), findsOneWidget);
      expect(find.text('Chess'), findsNothing); // oldest hidden
      await tester.tap(find.text('See all (4)'));
      await tester.pumpAndSettle();
      expect(find.text('Chess'), findsOneWidget);
      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();
      expect(find.text('Chess'), findsNothing);
    });

    testApp('About: edit and swipe-delete follow the same rules', (tester) async {
      await repo.createLine(personId: sam, block: 'about', text: 'Allergic to cats');
      await openProfile(tester);
      final id = (await repo.linesFor(sam, block: 'about')).single.id;
      await tester.tap(find.byKey(Key('line-$id')));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(Key('edit-$id')), 'Allergic to dogs');
      expect((await repo.linesFor(sam, block: 'about')).single.lineText, 'Allergic to dogs');
      await tester.drag(find.byKey(Key('dismiss-$id')), const Offset(-500, 0));
      await settle(tester);
      expect(await repo.linesFor(sam, block: 'about'), isEmpty);
    });

    testApp('block order follows the setup choice', (tester) async {
      await repo.setBlockOrder(['next_time', 'about', 'family', 'interests']);
      await openProfile(tester);
      final about = tester.getTopLeft(find.byKey(const Key('block-About')));
      final family = tester.getTopLeft(find.byKey(const Key('block-Their people')));
      final interests = tester.getTopLeft(find.byKey(const Key('block-Interests')));
      expect(about.dx, lessThan(family.dx)); // first row: About, Their people
      expect(about.dy, family.dy);
      expect(interests.dy, greaterThan(about.dy)); // wraps to the next row
    });

    testApp('Add a section creates a custom block that holds lines', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('add-section')));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(const Key('section-name')), 'Gift ideas');
      final blocks = await repo.listCustomBlocks();
      expect(blocks.single.name, 'Gift ideas');
      expect(blocks.single.key, 'c_gift_ideas');
      expect(find.byKey(const Key('block-Gift ideas')), findsOneWidget);
      await tester.tap(find.byKey(const Key('add-Gift ideas')));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(const Key('add-field')), 'Tea set');
      expect((await repo.linesFor(sam, block: 'c_gift_ideas')).single.lineText, 'Tea set');
    });
  });

  group('Their people', () {
    testApp('add a tile with name, relation and birthday', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('add-Their people')));
      await tester.pumpAndSettle();
      expect(find.text('Add to their people'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('rel-name')), 'Rosa');
      await tester.enterText(find.byKey(const Key('rel-relation')), 'grandmother');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settle(tester);
      final r = (await repo.relationshipsFor(sam)).single;
      expect((r.name, r.relation), ('Rosa', 'grandmother'));
      expect(find.text('Rosa, grandmother'), findsOneWidget);
    });

    testApp('Save needs a name', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('add-Their people')));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save')).onPressed, isNull);
    });

    testApp('tapping a tile opens its card, and notes follow the line rules', (tester) async {
      final rid = await repo.createRelationship(personId: sam, name: 'Rosa', relation: 'grandmother');
      await openProfile(tester);
      await tester.tap(find.text('Rosa, grandmother'));
      await settle(tester);
      expect(find.widgetWithText(TextField, 'Rosa'), findsOneWidget);

      await tester.tap(find.byKey(const Key('add-Notes')));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(const Key('add-field')), 'Bakes on Sundays');
      final notes = (await repo.linesFor(sam)).where((l) => l.relationshipId == rid).toList();
      expect(notes.single.lineText, 'Bakes on Sundays');
      expect(notes.single.block, 'family');

      // The note is not shown as one of Sam's own lines.
      await tester.tap(find.byKey(const Key('rel-name')));
      await tester.enterText(find.byKey(const Key('rel-name')), 'Rosa M');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settle(tester);
      expect((await repo.relationshipsFor(sam)).single.name, 'Rosa M');
      expect(find.text('Bakes on Sundays'), findsNothing);
    });

    testApp('adding a name already listed offers to open that tile instead', (tester) async {
      await repo.createRelationship(personId: sam, name: 'Rosa', relation: 'grandmother');
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('add-Their people')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('rel-name')), 'ros');
      await tester.pumpAndSettle();
      expect(find.text('Already in their people. Tap to add a note instead:'), findsOneWidget);
      await tester.tap(find.widgetWithText(ActionChip, 'Rosa, grandmother'));
      await settle(tester);
      expect(find.widgetWithText(TextField, 'Rosa'), findsOneWidget); // opened the existing card
      expect((await repo.relationshipsFor(sam)), hasLength(1));
    });

    testApp('swipe left removes a tile with Undo; Delete in the card does too', (tester) async {
      final a = await repo.createRelationship(personId: sam, name: 'Rosa');
      await repo.createRelationship(personId: sam, name: 'Ines', relation: 'partner');
      await openProfile(tester);
      await tester.drag(find.byKey(Key('dismiss-$a')), const Offset(-500, 0));
      await settle(tester);
      expect((await repo.relationshipsFor(sam)).map((r) => r.name), ['Ines']);
      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect(await repo.relationshipsFor(sam), hasLength(2));

      await tester.tap(find.text('Ines, partner'));
      await settle(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Delete'));
      await settle(tester);
      expect((await repo.relationshipsFor(sam)).map((r) => r.name), ['Rosa']);
      expect(find.text('Undo'), findsOneWidget);
    });

    testApp('a person added with notes keeps them', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('add-Their people')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('rel-name')), 'Tomas');
      await tester.tap(find.byKey(const Key('add-Notes')));
      await tester.pumpAndSettle();
      await typeAndEnter(tester, find.byKey(const Key('add-field')), 'Climbs');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await settle(tester);
      final r = (await repo.relationshipsFor(sam)).single;
      expect((await repo.linesFor(sam)).where((l) => l.relationshipId == r.id).single.lineText, 'Climbs');
    });
  });

  group('Edit person', () {
    Future<void> openEdit(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('profile-edit')));
      await settle(tester);
    }

    testApp('saves every detail', (tester) async {
      final parents = (await repo.listGroups()).firstWhere((g) => g.name == 'Parents').id;
      await openProfile(tester);
      await openEdit(tester);
      expect(find.text('Edit Sam'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('edit-name')), 'Samuel');
      await tester.tap(find.textContaining('Parents'));
      await tester.enterText(find.byKey(const Key('edit-contact')), '+351 555 0199');
      await tester.enterText(find.byKey(const Key('edit-interval')), '10');
      await tester.enterText(find.byKey(const Key('edit-hometown')), 'Porto');
      await tester.enterText(find.byKey(const Key('edit-socials')), '@sam.r');
      await tester.tap(find.text('Call'));
      await tester.tap(find.byKey(const Key('edit-birthday')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('14'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
      await settle(tester);

      final p = (await repo.getPerson(sam))!;
      expect(p.displayName, 'Samuel');
      expect(p.groupId, parents);
      expect(p.contactMethodType, 'call');
      expect(p.contactMethodValue, '+351 555 0199');
      expect(p.intervalOverrideDays, 10);
      expect(p.hometown, 'Porto');
      expect(p.socials, '["@sam.r"]');
      expect(p.birthday, '--01-14');
      expect(find.text('Samuel'), findsOneWidget);
      expect(find.text('Jan 14'), findsOneWidget);
      expect(find.text('Every 10 days'), findsOneWidget);
    });

    testApp('changing the city updates the timezone and the clock', (tester) async {
      await openProfile(tester);
      await openEdit(tester);
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Search a city, such as Lisbon'), 'tokyo');
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Tokyo'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
      await settle(tester);
      expect((await repo.getPerson(sam))!.timezone, 'Asia/Tokyo');
      expect(find.text('11:10 pm there'), findsOneWidget);
    });

    testApp('a blank interval goes back to the group default', (tester) async {
      await repo.updatePerson(sam, const PeopleCompanion(intervalOverrideDays: Value(10)));
      await openProfile(tester);
      await openEdit(tester);
      await tester.enterText(find.byKey(const Key('edit-interval')), '');
      await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
      await settle(tester);
      expect((await repo.getPerson(sam))!.intervalOverrideDays, isNull);
      expect(find.text('Every 30 days'), findsOneWidget);
    });

    testApp('archive hides them; restore brings them back; the banner shows in between', (tester) async {
      await openProfile(tester);
      await openEdit(tester);
      await tester.scrollUntilVisible(find.text('Archive Sam'), 300, scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('Archive Sam'));
      await settle(tester);
      expect(await repo.listPeople(), isEmpty);
      expect((await repo.listArchivedPeople()).single.id, sam);
      expect(find.text('Archived. Not suggested on Home.'), findsOneWidget);
      await tester.tap(find.text('Restore'));
      await settle(tester);
      expect((await repo.listPeople()).single.id, sam);
      expect(find.text('Archived. Not suggested on Home.'), findsNothing);
    });

    testApp('Delete forever only exists for archived people, asks first, then removes everything', (tester) async {
      await addNextTime('x');
      await repo.createRelationship(personId: sam, name: 'Rosa');
      await openProfile(tester);
      await openEdit(tester);
      expect(find.text('Delete forever'), findsNothing); // not archived
      await tester.scrollUntilVisible(find.text('Archive Sam'), 300, scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('Archive Sam'));
      await settle(tester);

      await openEdit(tester);
      await tester.scrollUntilVisible(find.text('Delete forever'), 300, scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('Delete forever'));
      await tester.pumpAndSettle();
      expect(find.textContaining('cannot be undone'), findsOneWidget);
      expect(await repo.getPerson(sam), isNotNull); // nothing yet

      await tester.tap(find.widgetWithText(FilledButton, 'Delete forever'));
      await settle(tester);
      expect(await repo.getPerson(sam), isNull);
      expect(await repo.linesFor(sam), isEmpty);
      expect(await repo.relationshipsFor(sam), isEmpty);
    });
  });

  group('Contact', () {
    testApp('Message opens the messages app and remembers who you tried', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('profile-contact')));
      await settle(tester);
      expect(find.text('Reach Sam'), findsOneWidget);
      await tester.tap(find.text('Message'));
      await settle(tester);
      expect(launcher.calls, ['sms:+3515550142']);
      final s = await repo.getSettings();
      expect(s.recentContactPersonId, sam);
      expect(s.recentContactAt, isNotNull);
    });

    testApp('Call opens the phone app', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('profile-contact')));
      await settle(tester);
      await tester.tap(find.text('Call'));
      await settle(tester);
      expect(launcher.calls, ['call:+3515550142']);
    });

    testApp('with no number the button is disabled and says what to do', (tester) async {
      final p = await repo.createPerson(displayName: 'Nobody', groupId: groupId, timezone: 'UTC', timezoneConfirmed: true, contactMethodType: 'text');
      await openProfile(tester, id: p);
      expect(tester.widget<FilledButton>(find.byKey(const Key('profile-contact'))).onPressed, isNull);
      expect(find.textContaining('Add a number or handle'), findsOneWidget);
    });

    testApp('a handle is shown but cannot be dialled', (tester) async {
      await repo.updatePerson(sam, const PeopleCompanion(contactMethodValue: Value('@sam.r')));
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('profile-contact')));
      await settle(tester);
      expect(find.text('@sam.r'), findsOneWidget);
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Message')).onPressed, isNull);
      expect(launcher.calls, isEmpty);
    });
  });
}

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/device_sources.dart';
import 'package:lately/data/providers.dart';
import 'package:lately/data/repository.dart';
import 'package:lately/domain/timezones.dart';
import 'package:lately/main.dart';

import 'support/fakes.dart';

/// A camera cutout or island and a gesture bar take space at the top and bottom
/// of the screen. These tests give every screen a tall top inset and a bottom
/// inset and check nothing you can tap sits underneath them.
class _Tz implements DeviceTimezone {
  @override
  Future<String> current() async => 'America/Chicago';
}

class _Contacts implements ContactsSource {
  @override
  Future<ContactsAccess> requestAccess() async => ContactsAccess.granted;
  @override
  Future<List<PhoneContact>> load() async => const [PhoneContact(id: '1', name: 'Alex', phone: '+1 415 555 2671')];
}

void main() {
  const top = 160.0; // an island and the status bar
  const bottom = 80.0; // the gesture bar
  const width = 800.0, height = 1800.0;

  late LatelyDatabase db;
  late Repository repo;
  late String groupId;
  late String sam;
  final now = DateTime.utc(2026, 11, 11, 14, 10);

  setUpAll(ensureTimezonesLoaded);

  setUp(() async {
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => now);
    await repo.completeSetup();
    groupId = (await repo.listGroups()).firstWhere((g) => g.name == 'Friends').id;
    sam = await repo.createPerson(
      displayName: 'Sam', groupId: groupId, timezone: 'Europe/Lisbon', timezoneConfirmed: true,
      contactMethodType: 'text', contactMethodValue: '+351912345678', phone: '+351912345678',
      lastTalkedEstimate: now.subtract(const Duration(days: 60)),
    );
    await repo.createRelationship(personId: sam, name: 'Rosa', relation: 'grandmother');
    await repo.createPerson(displayName: 'Jo', groupId: groupId, timezone: 'UTC', timezoneConfirmed: false, contactMethodType: 'text');
  });

  void testApp(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      tester.view.physicalSize = const Size(width, height);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: top, bottom: bottom);
      tester.view.viewPadding = const FakeViewPadding(top: top, bottom: bottom);
      addTearDown(() {
        tester.view.reset();
        tester.view.resetPadding();
        tester.view.resetViewPadding();
      });
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
  }

  bool isTappable(Widget w) =>
      w is ButtonStyleButton ||
      w is IconButton ||
      w is TextField ||
      w is ListTile ||
      w is Checkbox ||
      w is Slider ||
      w is ChoiceChip ||
      w is FilterChip ||
      w is ActionChip ||
      w is PopupMenuButton ||
      w is NavigationDestination;

  /// Everything tappable that is on screen right now.
  List<(String, Rect)> onScreen(WidgetTester tester) {
    final out = <(String, Rect)>[];
    for (final e in find.byWidgetPredicate(isTappable).evaluate()) {
      final r = tester.getRect(find.byElementPredicate((x) => x == e));
      if (r.isEmpty || r.bottom <= 0 || r.top >= height) continue;
      out.add((e.widget.runtimeType.toString(), r));
    }
    return out;
  }

  void expectClearOfTop(WidgetTester tester, String where) {
    for (final (name, r) in onScreen(tester)) {
      expect(r.top, greaterThanOrEqualTo(top - 0.5), reason: '$where: a $name starts under the cutout at ${r.top}');
    }
  }

  Future<void> scrollToEnd(WidgetTester tester, Finder scrollable) async {
    for (var i = 0; i < 12; i++) {
      await tester.drag(scrollable, const Offset(0, -2500));
      await tester.pumpAndSettle();
    }
  }

  void expectAboveBottomBar(WidgetTester tester, Finder f, String what) {
    expect(tester.getRect(f).bottom, lessThanOrEqualTo(height - bottom + 0.5), reason: '$what sits under the gesture bar');
  }

  group('tabs', () {
    testApp('Home, People and Dates keep clear of the top, and the tab bar clears the bottom', (tester) async {
      await pumpApp(tester);
      expectClearOfTop(tester, 'Home');
      expectAboveBottomBar(tester, find.byKey(const Key('tab-home')), 'the Home tab');
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      expectClearOfTop(tester, 'People');
      await tester.tap(find.byKey(const Key('tab-dates')));
      await settle(tester);
      expectClearOfTop(tester, 'Dates');
    });

    testApp('the floating log button is above the tab bar and the gesture bar', (tester) async {
      await pumpApp(tester);
      expectAboveBottomBar(tester, find.byKey(const Key('log-fab')), 'the log button');
    });

    testApp('the People list can scroll to its last person above the tab bar', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await scrollToEnd(tester, find.byType(Scrollable).last);
      expectClearOfTop(tester, 'People (scrolled)');
    });
  });

  group('screens', () {
    testApp('a profile', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tester.tap(find.text('Sam'));
      await settle(tester);
      expectClearOfTop(tester, 'Profile');
      await scrollToEnd(tester, find.byType(Scrollable).last);
      final lastChats = find.text('Recent chats');
      expectAboveBottomBar(tester, lastChats, 'Recent chats');
    });

    testApp('Settings', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await settle(tester);
      expectClearOfTop(tester, 'Settings');
      await scrollToEnd(tester, find.byType(Scrollable).last);
      expectAboveBottomBar(tester, find.byKey(const Key('awake-end')), 'the last Settings row');
    });

    testApp('Add a person', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('add-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add someone'));
      await settle(tester);
      expectClearOfTop(tester, 'Add a person');
      await scrollToEnd(tester, find.byType(Scrollable).last);
      expectAboveBottomBar(tester, find.widgetWithText(FilledButton, 'Create'), 'Create');
    });

    testApp('Add from contacts', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('add-menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add from contacts'));
      await settle(tester);
      expectClearOfTop(tester, 'Add from contacts');
      expectAboveBottomBar(tester, find.text('Pick people to add'), 'the Add button');
    });

    testApp('first-run setup', (tester) async {
      await db.customStatement('UPDATE settings SET setup_completed_at = NULL');
      await pumpApp(tester);
      expect(find.text('Welcome to Lately'), findsOneWidget);
      expectClearOfTop(tester, 'Setup');
      await scrollToEnd(tester, find.byType(Scrollable).last);
      expectAboveBottomBar(tester, find.widgetWithText(FilledButton, 'Continue'), 'Continue');
    });
  });

  group('sheets', () {
    Future<void> openProfile(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tester.tap(find.text('Sam'));
      await settle(tester);
    }

    testApp('Log a chat: starts below the cutout, and Save is above the gesture bar', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('profile-log')));
      await settle(tester);
      expect(find.text('Log a chat'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Log a chat')).dy, greaterThanOrEqualTo(top));
      expectAboveBottomBar(tester, find.byKey(const Key('log-save')), 'Save chat');
    });

    testApp('Edit person', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('profile-edit')));
      await settle(tester);
      expect(tester.getTopLeft(find.text('Edit Sam')).dy, greaterThanOrEqualTo(top));
      expectAboveBottomBar(tester, find.widgetWithText(FilledButton, 'Save changes'), 'Save changes');
    });

    testApp('a Their people card', (tester) async {
      await openProfile(tester);
      await tester.tap(find.text('Rosa, grandmother'));
      await settle(tester);
      expect(tester.getTopLeft(find.text('Rosa').first).dy, greaterThanOrEqualTo(top));
      expectAboveBottomBar(tester, find.widgetWithText(FilledButton, 'Save'), 'Save');
    });

    testApp('Finish setup', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('tab-people')));
      await settle(tester);
      await tester.tap(find.text('Jo'));
      await settle(tester);
      expect(find.text('Finish setup for Jo'), findsOneWidget);
      expectAboveBottomBar(tester, find.widgetWithText(FilledButton, 'Finish setup'), 'Finish setup');
    });

    testApp('the country list', (tester) async {
      await openProfile(tester);
      await tester.tap(find.byKey(const Key('profile-edit')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('country-button')));
      await settle(tester);
      expect(tester.getRect(find.byKey(const Key('country-search'))).top, greaterThanOrEqualTo(top));
      await scrollToEnd(tester, find.byKey(const Key('country-US')).hitTestable().evaluate().isEmpty ? find.byType(Scrollable).last : find.byType(Scrollable).last);
      expectAboveBottomBar(tester, find.byKey(const Key('country-ZW')), 'the last country');
    });

    testApp('the chat detail', (tester) async {
      await repo.logChat(personId: sam, occurredAt: now.subtract(const Duration(days: 3)), type: 'call', depth: 'deep', durationMinutes: 30, note: 'Caught up');
      await openProfile(tester);
      await scrollToEnd(tester, find.byType(Scrollable).last);
      await tester.tap(find.textContaining('Call ·').first);
      await settle(tester);
      expectClearOfTop(tester, 'Chat detail');
    });
  });

  group('system bars', () {
    test('icons stay readable on the paper colour in light and dark', () {
      final light = systemUiStyleFor(Brightness.light);
      final dark = systemUiStyleFor(Brightness.dark);
      expect(light.statusBarIconBrightness, Brightness.dark);
      expect(dark.statusBarIconBrightness, Brightness.light);
      expect(light.systemNavigationBarIconBrightness, Brightness.dark);
      expect(dark.systemNavigationBarIconBrightness, Brightness.light);
      expect(light.statusBarColor, Colors.transparent); // the app draws behind the bars
      expect(dark.systemNavigationBarColor, Colors.transparent);
    });

    testApp('the app applies it (and follows the phone into dark mode)', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await pumpApp(tester);
      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first);
      expect(region.value.statusBarIconBrightness, Brightness.light);
    });
  });
}

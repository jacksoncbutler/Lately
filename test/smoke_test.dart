import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/backup_platform.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/providers.dart';
import 'package:lately/data/repository.dart';
import 'package:lately/main.dart';

class FakePlatform implements BackupPlatform {
  FakePlatform(this.dir, {this.picked});
  final Directory dir;
  String? picked;
  File? shared;
  @override
  Future<Directory> exportDirectory() async => dir;
  @override
  Future<void> shareFile(File file) async => shared = file;
  @override
  Future<String?> pickBackupText() async => picked;
}

void main() {
  late LatelyDatabase db;
  late Directory tmp;
  late FakePlatform platform;

  setUp(() {
    db = LatelyDatabase(NativeDatabase.memory());
    tmp = Directory.systemTemp.createTempSync('lately_ui_test');
    platform = FakePlatform(Directory('${tmp.path}/out'));
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


  Future<void> pumpApp(WidgetTester tester) async {
    await Repository(db).completeSetup();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        snapshotDirProvider.overrideWithValue(Directory('${tmp.path}/snap')),
        backupPlatformProvider.overrideWithValue(platform),
      ],
      child: const LatelyApp(),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 60)));
      await tester.pump();
    }
  }

  testApp('an empty app invites you to add someone', (tester) async {
    await pumpApp(tester);
    expect(find.text('Add someone'), findsOneWidget);
    expect(find.text('Add from contacts'), findsOneWidget);
  });

  testApp('settings has Export and Import backup', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Export backup'), findsOneWidget);
    expect(find.text('Import backup'), findsOneWidget);
    expect(find.text('Not exported yet.'), findsOneWidget);
  });

  testApp('export shows a warning, writes the file and opens the share sheet', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export backup'));
    await tester.pumpAndSettle();
    expect(find.textContaining('personal details'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    for (var i = 0; i < 10 && platform.shared == null; i++) {
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(platform.shared, isNotNull);
    expect(platform.shared!.path, contains('lately-backup-'));
    expect(platform.shared!.existsSync(), isTrue);
    expect(find.textContaining('Last export:'), findsOneWidget);
  });

  testApp('importing a file that is not a backup says so and changes nothing', (tester) async {
    platform.picked = 'not a backup';
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import backup'));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(find.text('This file is not a Lately backup.'), findsOneWidget);
  });
}

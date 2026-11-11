import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/backup_platform.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/providers.dart';
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
  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        snapshotDirProvider.overrideWithValue(Directory('${tmp.path}/snap')),
        backupPlatformProvider.overrideWithValue(platform),
      ],
      child: const LatelyApp(),
    ));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
  }

  testWidgets('home shows the app is up', (tester) async {
    await pumpApp(tester);
    expect(find.text('Lately'), findsOneWidget);
    expect(find.text('Database ready · 3 groups'), findsOneWidget);
  });

  testWidgets('settings has Export and Import backup', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Export backup'), findsOneWidget);
    expect(find.text('Import backup'), findsOneWidget);
    expect(find.text('Not exported yet.'), findsOneWidget);
  });

  testWidgets('export shows a warning, writes the file and opens the share sheet', (tester) async {
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

  testWidgets('importing a file that is not a backup says so and changes nothing', (tester) async {
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

import 'dart:io';

import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/repository.dart';
import 'package:lately/data/safe_open.dart';

void main() {
  late Directory tmp;
  late File dbFile;
  late Directory snaps;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('lately_open_test');
    dbFile = File('${tmp.path}/lately.sqlite');
    snaps = Directory('${tmp.path}/snapshots');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  /// A database file exactly as build 0.2.0 wrote it (schema version 1).
  Future<void> makeVersion1File() async {
    final db = LatelyDatabase(NativeDatabase(dbFile));
    final repo = Repository(db);
    final g = (await repo.listGroups()).first.id;
    await repo.createPerson(
        displayName: 'Sam', groupId: g, timezone: 'UTC', contactMethodType: 'text');
    await db.customStatement('ALTER TABLE settings DROP COLUMN last_export_at');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();
  }

  QueryExecutor Function(File) plain() => (f) => NativeDatabase(f);

  test('fresh install: opens, seeds, no snapshot taken', () async {
    final db = await openDatabaseSafely(dbFile: dbFile, snapshotDir: snaps, connect: plain());
    expect(await Repository(db).listGroups(), hasLength(3));
    expect(snaps.existsSync(), isFalse);
    await db.close();
  });

  test('upgrade from 0.2.0 data: copy taken first, data kept, new column works', () async {
    await makeVersion1File();
    final db = await openDatabaseSafely(dbFile: dbFile, snapshotDir: snaps, connect: plain());
    final repo = Repository(db);
    expect((await repo.listPeople()).single.displayName, 'Sam');
    expect((await repo.getSettings()).lastExportAt, isNull); // column exists again
    final copies = snaps.listSync().map((e) => e.path).where((p) => p.contains('pre-migration-v1-to-v2'));
    expect(copies, hasLength(1));
    await db.close();
  });

  test('failed upgrade puts the data back exactly as it was', () async {
    await makeVersion1File();
    final before = dbFile.readAsBytesSync();

    await expectLater(
      openDatabaseSafely(
        dbFile: dbFile,
        snapshotDir: snaps,
        // Damages the data, then fails, the way a broken migration might.
        connect: (f) => NativeDatabase(f, setup: (raw) {
          raw.execute('DELETE FROM people');
          raw.execute('DROP TABLE groups');
          throw StateError('boom');
        }),
      ),
      throwsA(isA<DatabaseOpenFailed>().having((e) => e.restored, 'restored', isTrue)),
    );

    expect(dbFile.readAsBytesSync(), before);
    // And the restored file still opens normally afterwards.
    final db = await openDatabaseSafely(dbFile: dbFile, snapshotDir: snaps, connect: plain());
    expect((await Repository(db).listPeople()).single.displayName, 'Sam');
    await db.close();
  });

  test('data from a newer version is left alone', () async {
    await makeVersion1File();
    final before = dbFile.readAsBytesSync();
    await expectLater(
      openDatabaseSafely(dbFile: dbFile, snapshotDir: snaps, connect: plain(), targetVersion: 0 + 0),
      throwsA(isA<DatabaseOpenFailed>()),
    );
    expect(dbFile.readAsBytesSync(), before);
  });

  test('only the newest few migration copies are kept', () async {
    for (var i = 0; i < 5; i++) {
      await makeVersion1File();
      final db = await openDatabaseSafely(
          dbFile: dbFile,
          snapshotDir: snaps,
          connect: plain(),
          clock: () => DateTime.utc(2026, 11, 1 + i));
      await db.close();
      dbFile.deleteSync();
    }
    expect(snaps.listSync(), hasLength(3));
  });
}

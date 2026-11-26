import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sql;

import 'database.dart';

/// The app could not open its data safely. The data on disk is unchanged
/// (or restored from the copy taken just before migrating).
class DatabaseOpenFailed implements Exception {
  DatabaseOpenFailed(this.message, {this.restored = false, this.cause});
  final String message;
  final bool restored;
  final Object? cause;
  @override
  String toString() => message;
}

int _userVersion(File f) {
  final db = sql.sqlite3.open(f.path, mode: sql.OpenMode.readOnly);
  try {
    return db.select('PRAGMA user_version').first.values.first as int;
  } finally {
    db.close();
  }
}

/// Opens the database. If the file on disk is from an older schema, it is
/// copied aside first; if migrating fails, the copy is put back and
/// [DatabaseOpenFailed] is thrown, so an update can never cost data.
Future<LatelyDatabase> openDatabaseSafely({
  required File dbFile,
  required Directory snapshotDir,
  required QueryExecutor Function(File file) connect,
  int targetVersion = LatelyDatabase.currentSchemaVersion,
  DateTime Function()? clock,
}) async {
  File? copy;
  if (dbFile.existsSync() && dbFile.lengthSync() > 0) {
    final from = _userVersion(dbFile);
    if (from > targetVersion) {
      throw DatabaseOpenFailed(
          'This data was saved by a newer version of Lately. Install the newer '
          'version again. Nothing was changed.');
    }
    if (from > 0 && from < targetVersion) {
      await snapshotDir.create(recursive: true);
      final stamp = (clock ?? DateTime.now)()
          .toUtc()
          .toIso8601String()
          .replaceAll(':', '-');
      copy = await dbFile.copy(
          p.join(snapshotDir.path, 'pre-migration-v$from-to-v$targetVersion-$stamp.sqlite'));
      _pruneMigrationCopies(snapshotDir);
    }
  }

  final db = LatelyDatabase(connect(dbFile));
  try {
    // Forces the database to open, which runs any migration.
    await db.customSelect('SELECT 1').get();
    return db;
  } catch (e) {
    try {
      await db.close();
    } catch (_) {}
    if (copy != null) {
      await copy.copy(dbFile.path);
      for (final ext in ['-wal', '-shm', '-journal']) {
        final side = File('${dbFile.path}$ext');
        if (side.existsSync()) await side.delete();
      }
      throw DatabaseOpenFailed(
          'This update could not upgrade your data, so your data was put back '
          'exactly as it was. Please reinstall the previous version and export '
          'a backup.',
          restored: true,
          cause: e);
    }
    throw DatabaseOpenFailed('Lately could not open its data: $e', cause: e);
  }
}

void _pruneMigrationCopies(Directory dir, {int keep = 3}) {
  final all = dir
      .listSync()
      .whereType<File>()
      .where((f) => p.basename(f.path).startsWith('pre-migration-'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final f in all.take(all.length > keep ? all.length - keep : 0)) {
    f.deleteSync();
  }
}

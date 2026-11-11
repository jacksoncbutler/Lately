import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/constants.dart';
import 'tables.dart';

part 'database.g.dart';

const settingsId = 'settings';
const defaultBlockOrder = ['next_time', 'family', 'interests', 'about'];
const _uuid = Uuid();

String newId() => _uuid.v4();

@DriftDatabase(tables: [
  Settings,
  Groups,
  People,
  Relationships,
  Chats,
  Lines,
  ImportantDates,
  CustomBlocks,
])
class LatelyDatabase extends _$LatelyDatabase {
  LatelyDatabase(super.e);

  /// Bump with every table change and add a step in [onUpgrade]. The database
  /// file is copied aside before migrating (see lib/data/safe_open.dart).
  static const currentSchemaVersion = 3;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seed();
        },
        onUpgrade: (m, from, to) async {
          // Each step is kept forever. Add new steps below; never edit old ones.
          if (from < 2) {
            await m.addColumn(settings, settings.lastExportAt);
            await (update(settings)..where((t) => t.id.equals(settingsId)))
                .write(const SettingsCompanion(schemaVersion: Value(2)));
          }
          if (from < 3) {
            await m.addColumn(settings, settings.setupCompletedAt);
            // Anyone who already has people has been through setup.
            await customStatement(
                'UPDATE settings SET setup_completed_at = updated_at '
                'WHERE EXISTS (SELECT 1 FROM people)');
            await (update(settings)..where((t) => t.id.equals(settingsId)))
                .write(const SettingsCompanion(schemaVersion: Value(3)));
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Settings row and the three starting groups.
  Future<void> seed({DateTime? now}) async {
    final t = (now ?? DateTime.now()).toUtc();
    await into(settings).insert(SettingsCompanion.insert(
      id: settingsId,
      createdAt: t,
      updatedAt: t,
      blockOrder: jsonEncode(defaultBlockOrder),
      schemaVersion: currentSchemaVersion,
    ));
    var order = 0;
    for (final e in Tune.groupIntervalDays.entries) {
      await into(groups).insert(GroupsCompanion.insert(
        id: newId(),
        createdAt: t,
        updatedAt: t,
        name: e.key[0].toUpperCase() + e.key.substring(1),
        defaultIntervalDays: e.value,
        sortOrder: Value(order++),
      ));
    }
  }
}

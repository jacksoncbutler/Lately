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

  /// Bump with every table change and add a step in [migration]. A snapshot of
  /// the data is taken before migrating (build step 3).
  static const currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seed();
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

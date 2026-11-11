import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/chat_rules.dart';
import 'database.dart';

/// Create, read, update, archive and soft-delete for every entity. Storage
/// only: no ranking rules here (those live in lib/domain).
/// Every write stamps updatedAt in UTC. Reads skip soft-deleted rows.
/// Drift returns DateTimes in local time; call .toUtc() before exporting.
class Repository {
  Repository(this.db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final LatelyDatabase db;
  final DateTime Function() _clock;
  DateTime get _now => _clock().toUtc();

  // ---- Settings ----
  Future<AppSettings> getSettings() =>
      (db.select(db.settings)..where((t) => t.id.equals(settingsId))).getSingle();

  Future<void> updateSettings(SettingsCompanion c) =>
      (db.update(db.settings)..where((t) => t.id.equals(settingsId)))
          .write(c.copyWith(updatedAt: Value(_now)));

  Future<bool> isSetupComplete() async =>
      (await getSettings()).setupCompletedAt != null;

  Future<void> completeSetup() => updateSettings(
      SettingsCompanion(setupCompletedAt: Value(_now)));

  Future<void> setBlockOrder(List<String> order) => updateSettings(
      SettingsCompanion(blockOrder: Value(jsonEncode(order))));

  List<String> blockOrderOf(AppSettings s) =>
      (jsonDecode(s.blockOrder) as List).cast<String>();

  // ---- Groups ----
  Future<String> createGroup(String name, int intervalDays,
      {int sortOrder = 0, String? color}) async {
    final id = newId();
    final t = _now;
    await db.into(db.groups).insert(GroupsCompanion.insert(
        id: id,
        createdAt: t,
        updatedAt: t,
        name: name,
        defaultIntervalDays: intervalDays,
        sortOrder: Value(sortOrder),
        color: Value(color)));
    return id;
  }

  Future<List<GroupRow>> listGroups() => (db.select(db.groups)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();

  Future<GroupRow?> getGroup(String id) => (db.select(db.groups)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  Future<void> updateGroup(String id, GroupsCompanion c) =>
      (db.update(db.groups)..where((t) => t.id.equals(id)))
          .write(c.copyWith(updatedAt: Value(_now)));

  // ---- People ----
  Future<String> createPerson({
    required String displayName,
    required String groupId,
    required String timezone,
    required String contactMethodType,
    String? contactMethodValue,
    DateTime? lastTalkedEstimate,
    bool timezoneConfirmed = false,
    String? phone,
  }) async {
    final id = newId();
    final t = _now;
    await db.into(db.people).insert(PeopleCompanion.insert(
        id: id,
        createdAt: t,
        updatedAt: t,
        displayName: displayName,
        groupId: groupId,
        timezone: timezone,
        contactMethodType: contactMethodType,
        contactMethodValue: Value(contactMethodValue),
        phone: Value(phone),
        lastTalkedEstimate: Value(lastTalkedEstimate?.toUtc()),
        timezoneConfirmed: Value(timezoneConfirmed)));
    return id;
  }

  /// Adds many people in one transaction (bulk add). Returns their ids.
  Future<List<String>> createPeople(
      List<
              ({
                String displayName,
                String? phone,
              })>
          people,
      {required String groupId,
      required String timezone,
      required bool timezoneConfirmed,
      DateTime? lastTalkedEstimate}) {
    return db.transaction(() async {
      final ids = <String>[];
      for (final p in people) {
        ids.add(await createPerson(
            displayName: p.displayName,
            groupId: groupId,
            timezone: timezone,
            timezoneConfirmed: timezoneConfirmed,
            contactMethodType: 'text',
            contactMethodValue: p.phone,
            phone: p.phone,
            lastTalkedEstimate: lastTalkedEstimate));
      }
      return ids;
    });
  }

  Future<PersonRow?> getPerson(String id) => (db.select(db.people)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  /// Active people only (not archived, not deleted).
  Future<List<PersonRow>> listPeople() => (db.select(db.people)
        ..where((t) => t.deletedAt.isNull() & t.archivedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
      .get();

  Future<List<PersonRow>> listArchivedPeople() => (db.select(db.people)
        ..where((t) => t.deletedAt.isNull() & t.archivedAt.isNotNull())
        ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
      .get();

  Future<void> updatePerson(String id, PeopleCompanion c) =>
      (db.update(db.people)..where((t) => t.id.equals(id)))
          .write(c.copyWith(updatedAt: Value(_now)));

  Future<void> archivePerson(String id) =>
      updatePerson(id, PeopleCompanion(archivedAt: Value(_now)));

  Future<void> restorePerson(String id) =>
      updatePerson(id, const PeopleCompanion(archivedAt: Value(null)));

  /// Only archived people can be deleted. Soft-deletes the person and
  /// everything attached, so a backup merge cannot bring them back.
  Future<void> deletePersonForever(String id) async {
    final p = await getPerson(id);
    if (p == null || p.archivedAt == null) {
      throw StateError('Only archived people can be deleted forever');
    }
    final t = _now;
    await db.transaction(() async {
      final attached = <TableInfo<Table, dynamic>>[
        db.relationships,
        db.chats,
        db.lines,
        db.importantDates
      ];
      for (final tbl in attached) {
        await db.customUpdate(
          'UPDATE ${tbl.actualTableName} SET deleted_at = ?, updated_at = ? '
          'WHERE person_id = ? AND deleted_at IS NULL',
          variables: [
            Variable<DateTime>(t),
            Variable<DateTime>(t),
            Variable<String>(id)
          ],
          updates: {tbl},
        );
      }
      await updatePerson(id, PeopleCompanion(deletedAt: Value(t)));
    });
  }

  /// Person override, else the group default.
  Future<int> intervalDaysFor(PersonRow p) async {
    if (p.intervalOverrideDays != null) return p.intervalOverrideDays!;
    final g = await getGroup(p.groupId);
    return g!.defaultIntervalDays;
  }

  // ---- Chats ----
  Future<String> createChat({
    required String personId,
    required DateTime occurredAt,
    required String type,
    required String depth,
    required String length,
    int? durationMinutes,
    List<String> feelings = const [],
    String? note,
    bool timeApproximate = false,
    String source = 'manual',
  }) async {
    final id = newId();
    final t = _now;
    await db.into(db.chats).insert(ChatsCompanion.insert(
        id: id,
        createdAt: t,
        updatedAt: t,
        personId: personId,
        occurredAt: occurredAt.toUtc(),
        type: type,
        depth: depth,
        length: length,
        durationMinutes: Value(durationMinutes),
        feelings: Value(jsonEncode(feelings)),
        note: Value(note),
        timeApproximate: Value(timeApproximate),
        source: Value(source)));
    return id;
  }

  Future<ChatRow?> getChat(String id) => (db.select(db.chats)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  /// Newest first.
  Future<List<ChatRow>> chatsFor(String personId) => (db.select(db.chats)
        ..where((t) => t.personId.equals(personId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
      .get();

  Future<void> updateChat(String id, ChatsCompanion c) =>
      (db.update(db.chats)..where((t) => t.id.equals(id)))
          .write(c.copyWith(updatedAt: Value(_now)));

  Future<void> deleteChat(String id) =>
      updateChat(id, ChatsCompanion(deletedAt: Value(_now)));

  /// Newest chat, else the last-talked estimate, else null.
  Future<DateTime?> lastContactOf(PersonRow p) async {
    final chats = await chatsFor(p.id);
    if (chats.isNotEmpty) return chats.first.occurredAt;
    return p.lastTalkedEstimate;
  }

  // ---- Lines ----
  Future<String> createLine(
      {required String personId,
      required String block,
      required String text,
      String? relationshipId,
      String? addedInChatId,
      int? sortOrder}) async {
    final id = newId();
    final t = _now;
    // Later lines sort after earlier ones even when added in the same second.
    final order = sortOrder ?? await _nextLineOrder(personId, block);
    await db.into(db.lines).insert(LinesCompanion.insert(
        id: id,
        createdAt: t,
        updatedAt: t,
        personId: personId,
        block: block,
        lineText: text,
        relationshipId: Value(relationshipId),
        addedInChatId: Value(addedInChatId),
        sortOrder: Value(order)));
    return id;
  }

  Future<int> _nextLineOrder(String personId, String block) async {
    final max = db.lines.sortOrder.max();
    final row = await (db.selectOnly(db.lines)
          ..addColumns([max])
          ..where(db.lines.personId.equals(personId) & db.lines.block.equals(block)))
        .getSingle();
    return (row.read(max) ?? 0) + 1;
  }

  Future<List<LineRow>> linesFor(String personId, {String? block}) =>
      (db.select(db.lines)
            ..where((t) {
              var c = t.personId.equals(personId) & t.deletedAt.isNull();
              if (block != null) c = c & t.block.equals(block);
              return c;
            })
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.createdAt)
            ]))
          .get();

  Future<void> updateLine(String id, LinesCompanion c) =>
      (db.update(db.lines)..where((t) => t.id.equals(id)))
          .write(c.copyWith(updatedAt: Value(_now)));

  Future<void> setLineDone(String id, bool done) => updateLine(
      id,
      LinesCompanion(
          done: Value(done), doneAt: Value(done ? _now : null)));

  Future<void> deleteLine(String id) =>
      updateLine(id, LinesCompanion(deletedAt: Value(_now)));

  Future<void> undeleteLine(String id) =>
      updateLine(id, const LinesCompanion(deletedAt: Value(null)));

  // ---- Relationships (Their people) ----
  Future<String> createRelationship(
      {required String personId,
      required String name,
      String? relation,
      String? birthday,
      String? addedInChatId}) async {
    final id = newId();
    final t = _now;
    await db.into(db.relationships).insert(RelationshipsCompanion.insert(
        id: id,
        createdAt: t,
        updatedAt: t,
        personId: personId,
        name: name,
        relation: Value(relation),
        birthday: Value(birthday),
        addedInChatId: Value(addedInChatId)));
    return id;
  }

  Future<List<RelationshipRow>> relationshipsFor(String personId) =>
      (db.select(db.relationships)
            ..where((t) => t.personId.equals(personId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<void> updateRelationship(String id, RelationshipsCompanion c) =>
      (db.update(db.relationships)..where((t) => t.id.equals(id)))
          .write(c.copyWith(updatedAt: Value(_now)));

  Future<void> deleteRelationship(String id) =>
      updateRelationship(id, RelationshipsCompanion(deletedAt: Value(_now)));

  // ---- Important dates ----
  Future<String> createImportantDate(
      {required String personId,
      required String label,
      required String date,
      bool repeatsYearly = true}) async {
    final id = newId();
    final t = _now;
    await db.into(db.importantDates).insert(ImportantDatesCompanion.insert(
        id: id,
        createdAt: t,
        updatedAt: t,
        personId: personId,
        label: label,
        date: date,
        repeatsYearly: Value(repeatsYearly)));
    return id;
  }

  Future<List<ImportantDateRow>> importantDatesFor(String personId) =>
      (db.select(db.importantDates)
            ..where((t) => t.personId.equals(personId) & t.deletedAt.isNull()))
          .get();

  Future<void> updateImportantDate(String id, ImportantDatesCompanion c) =>
      (db.update(db.importantDates)..where((t) => t.id.equals(id)))
          .write(c.copyWith(updatedAt: Value(_now)));

  Future<void> deleteImportantDate(String id) =>
      updateImportantDate(id, ImportantDatesCompanion(deletedAt: Value(_now)));

  // ---- Custom blocks ----
  Future<String> createCustomBlock(String key, String name,
      {int sortOrder = 0}) async {
    final id = newId();
    final t = _now;
    await db.into(db.customBlocks).insert(CustomBlocksCompanion.insert(
        id: id,
        createdAt: t,
        updatedAt: t,
        key: key,
        name: name,
        sortOrder: Value(sortOrder)));
    return id;
  }

  Future<List<CustomBlockRow>> listCustomBlocks() => (db.select(db.customBlocks)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();

  Future<void> updateCustomBlock(String id, CustomBlocksCompanion c) =>
      (db.update(db.customBlocks)..where((t) => t.id.equals(id)))
          .write(c.copyWith(updatedAt: Value(_now)));

  Future<void> deleteCustomBlock(String id) =>
      updateCustomBlock(id, CustomBlocksCompanion(deletedAt: Value(_now)));

  /// Saves a logged conversation and everything tied to it in one step:
  /// the chat, the Next time items it covered (linked to it), lines and
  /// people added from the popup (stamped with it), and the person's clock
  /// (snooze and skip are cleared; the recent-contact prompt is cleared).
  Future<String> logChat({
    required String personId,
    required DateTime occurredAt,
    bool timeApproximate = false,
    required String type,
    required String depth,
    required int durationMinutes,
    List<String> feelings = const [],
    String? note,
    List<String> coveredLineIds = const [],
    List<String> addedLineIds = const [],
    List<String> addedRelationshipIds = const [],
  }) {
    return db.transaction(() async {
      final chatId = await createChat(
        personId: personId,
        occurredAt: occurredAt,
        timeApproximate: timeApproximate,
        type: type,
        depth: depth,
        length: lengthForMinutes(durationMinutes),
        durationMinutes: durationMinutes,
        feelings: [for (final f in feelings) f.toLowerCase()],
        note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      );
      for (final id in coveredLineIds) {
        await updateLine(id, LinesCompanion(chatId: Value(chatId)));
      }
      for (final id in addedLineIds) {
        await updateLine(id, LinesCompanion(addedInChatId: Value(chatId)));
      }
      for (final id in addedRelationshipIds) {
        await updateRelationship(id, RelationshipsCompanion(addedInChatId: Value(chatId)));
      }
      await updatePerson(
          personId,
          const PeopleCompanion(snoozedUntil: Value(null), skippedUntil: Value(null)));
      final s = await getSettings();
      if (s.recentContactPersonId == personId) {
        await updateSettings(const SettingsCompanion(
            recentContactPersonId: Value(null), recentContactAt: Value(null)));
      }
      return chatId;
    });
  }

  /// Last contact for every active person: newest chat, else the estimate.
  Future<Map<String, DateTime?>> lastContactByPerson() async {
    final people = await listPeople();
    final chats = await db.select(db.chats).get();
    final newest = <String, DateTime>{};
    for (final c in chats) {
      if (c.deletedAt != null) continue;
      final cur = newest[c.personId];
      if (cur == null || c.occurredAt.isAfter(cur)) newest[c.personId] = c.occurredAt;
    }
    return {for (final p in people) p.id: newest[p.id] ?? p.lastTalkedEstimate};
  }

  // ---- Streams for screens (re-run when the data changes) ----
  Stream<PersonRow?> watchPerson(String id) => (db.select(db.people)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .watchSingleOrNull();

  Stream<List<PersonRow>> watchPeople() => (db.select(db.people)
        ..where((t) => t.deletedAt.isNull() & t.archivedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
      .watch();

  Stream<List<PersonRow>> watchArchivedPeople() => (db.select(db.people)
        ..where((t) => t.deletedAt.isNull() & t.archivedAt.isNotNull())
        ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
      .watch();

  Stream<List<GroupRow>> watchGroups() => (db.select(db.groups)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();

  Stream<List<LineRow>> watchLines(String personId) => (db.select(db.lines)
        ..where((t) => t.personId.equals(personId) & t.deletedAt.isNull())
        ..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.createdAt)
        ]))
      .watch();

  Stream<List<RelationshipRow>> watchRelationships(String personId) =>
      (db.select(db.relationships)
            ..where((t) => t.personId.equals(personId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Stream<List<ChatRow>> watchChats(String personId) => (db.select(db.chats)
        ..where((t) => t.personId.equals(personId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
      .watch();

  Stream<List<CustomBlockRow>> watchCustomBlocks() =>
      (db.select(db.customBlocks)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Stream<AppSettings> watchSettings() =>
      (db.select(db.settings)..where((t) => t.id.equals(settingsId))).watchSingle();

  Future<void> undeleteRelationship(String id) =>
      updateRelationship(id, const RelationshipsCompanion(deletedAt: Value(null)));

  /// A custom profile section. The key is derived from the name and kept
  /// unique, and every key starts with c_ so it cannot clash with built-ins.
  Future<String> addCustomSection(String name) async {
    final existing = {for (final b in await listCustomBlocks()) b.key};
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    var key = 'c_${slug.isEmpty ? 'section' : slug}';
    var n = 2;
    while (existing.contains(key)) {
      key = 'c_${slug.isEmpty ? 'section' : slug}_${n++}';
    }
    return createCustomBlock(key, name.trim(), sortOrder: existing.length);
  }

  /// Remembers who you just tapped Contact for (the Home prompt and the log
  /// popup default use it for a few hours).
  Future<void> setRecentContact(String personId) => updateSettings(
      SettingsCompanion(
          recentContactPersonId: Value(personId), recentContactAt: Value(_now)));

  /// Completes a bulk-added person: where they are and roughly when you last
  /// talked. [lastTalked] null leaves the estimate as it is.
  Future<void> finishSetup(String id,
      {required String timezone, required DateTime lastTalked}) =>
      updatePerson(
          id,
          PeopleCompanion(
              timezone: Value(timezone),
              timezoneConfirmed: const Value(true),
              lastTalkedEstimate: Value(lastTalked.toUtc())));
}

/// Bulk-added people stay "unfinished" until you confirm where they are and
/// roughly when you last talked.
bool needsFinishing(PersonRow p) => !p.timezoneConfirmed;

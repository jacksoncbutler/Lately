import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../app_config.dart';
import '../database.dart';
import 'backup_codec.dart';
import 'backup_models.dart';

/// Writes the whole database to a backup file and reads one back.
/// Every import validates first and then writes in a single transaction, so a
/// failure leaves the data untouched. A replace import also saves a snapshot
/// of the current data first, which "Undo last import" can restore.
class BackupService {
  BackupService(this.db, {required this.snapshotDir, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final LatelyDatabase db;
  final Directory snapshotDir;
  final DateTime Function() _clock;

  static const _keepSnapshots = 5;

  // ------------------------------------------------------------------ export

  /// The backup as text. Soft-deleted rows are included so a later merge
  /// cannot bring back something that was removed.
  Future<String> exportToString() async {
    final settings = await (db.select(db.settings)
          ..where((t) => t.id.equals(settingsId)))
        .getSingle();
    final extra = _decodeMap(settings.extra);

    final data = <String, dynamic>{
      ...(extra['dataExtra'] as Map<String, dynamic>? ?? {}),
      'settings': {
        ...(extra['fields'] as Map<String, dynamic>? ?? {}),
        'id': settings.id,
        'createdAt': _t(settings.createdAt),
        'updatedAt': _t(settings.updatedAt),
        'awakeStart': settings.awakeStart,
        'awakeEnd': settings.awakeEnd,
        'blockOrder': jsonDecode(settings.blockOrder),
        if (settings.skipPolicy != null) 'skipPolicy': settings.skipPolicy,
        if (settings.theme != null) 'theme': settings.theme,
        if (settings.recentContactPersonId != null)
          'recentContactPersonId': settings.recentContactPersonId,
        if (settings.recentContactAt != null)
          'recentContactAt': _t(settings.recentContactAt!),
      },
      'groups': [
        for (final r in await db.select(db.groups).get())
          _rec(r.extra, {
            'id': r.id,
            'name': r.name,
            'defaultIntervalDays': r.defaultIntervalDays,
            'sortOrder': r.sortOrder,
            'color': r.color,
          }, r.createdAt, r.updatedAt, r.deletedAt),
      ],
      'people': [
        for (final r in await db.select(db.people).get())
          _rec(r.extra, {
            'id': r.id,
            'displayName': r.displayName,
            'groupId': r.groupId,
            'timezone': r.timezone,
            'timezoneConfirmed': r.timezoneConfirmed,
            'contactMethod': {
              'type': r.contactMethodType,
              if (r.contactMethodValue != null) 'value': r.contactMethodValue,
            },
            'fullName': r.fullName,
            'middleName': r.middleName,
            'birthday': r.birthday,
            'intervalOverrideDays': r.intervalOverrideDays,
            'phone': r.phone,
            'socials': r.socials == null ? null : jsonDecode(r.socials!),
            'hometown': r.hometown,
            'lastTalkedEstimate': _tn(r.lastTalkedEstimate),
            'snoozedUntil': _tn(r.snoozedUntil),
            'skippedUntil': _tn(r.skippedUntil),
            'archivedAt': _tn(r.archivedAt),
          }, r.createdAt, r.updatedAt, r.deletedAt),
      ],
      'customBlocks': [
        for (final r in await db.select(db.customBlocks).get())
          _rec(r.extra, {
            'id': r.id,
            'key': r.key,
            'name': r.name,
            'sortOrder': r.sortOrder,
          }, r.createdAt, r.updatedAt, r.deletedAt),
      ],
      'familyMembers': [
        for (final r in await db.select(db.relationships).get())
          _rec(r.extra, {
            'id': r.id,
            'personId': r.personId,
            'name': r.name,
            'relation': r.relation,
            'birthday': r.birthday,
            'addedInChatId': r.addedInChatId,
          }, r.createdAt, r.updatedAt, r.deletedAt),
      ],
      'chats': [
        for (final r in await db.select(db.chats).get())
          _rec(r.extra, {
            'id': r.id,
            'personId': r.personId,
            'occurredAt': _t(r.occurredAt),
            'timeApproximate': r.timeApproximate,
            'type': r.type,
            'depth': r.depth,
            'length': r.length,
            'durationMinutes': r.durationMinutes,
            'feelings': r.feelings == null ? null : jsonDecode(r.feelings!),
            'note': r.note,
            'source': r.source,
            'callId': r.callId,
          }, r.createdAt, r.updatedAt, r.deletedAt),
      ],
      'lines': [
        for (final r in await db.select(db.lines).get())
          _rec(r.extra, {
            'id': r.id,
            'personId': r.personId,
            'block': r.block,
            'text': r.lineText,
            'done': r.done,
            'doneAt': _tn(r.doneAt),
            'chatId': r.chatId,
            'relationshipId': r.relationshipId,
            'addedInChatId': r.addedInChatId,
            'sortOrder': r.sortOrder,
          }, r.createdAt, r.updatedAt, r.deletedAt),
      ],
      'importantDates': [
        for (final r in await db.select(db.importantDates).get())
          _rec(r.extra, {
            'id': r.id,
            'personId': r.personId,
            'label': r.label,
            'date': r.date,
            'repeatsYearly': r.repeatsYearly,
          }, r.createdAt, r.updatedAt, r.deletedAt),
      ],
    };

    // Round-trip through JSON so the checksum is over exactly what is written.
    final plain = jsonDecode(jsonEncode(data));
    final file = {
      'format': AppConfig.backupFormat,
      'formatVersion': AppConfig.backupFormatVersion,
      'appVersion': AppConfig.appVersion,
      'exportedAt': _t(_clock()),
      'checksum': checksumOf(plain),
      'data': plain,
    };
    return const JsonEncoder.withIndent('  ').convert(file);
  }

  /// Writes the export to [dir] as lately-backup-YYYY-MM-DD.json and records
  /// the export time. Returns the file.
  Future<File> exportToFile(Directory dir) async {
    final now = _clock();
    final name = 'lately-backup-${_ymd(now)}.json';
    final f = File(p.join(dir.path, name));
    await dir.create(recursive: true);
    await f.writeAsString(await exportToString(), flush: true);
    await (db.update(db.settings)..where((t) => t.id.equals(settingsId)))
        .write(SettingsCompanion(lastExportAt: Value(now.toUtc())));
    return f;
  }

  Future<DateTime?> lastExportAt() async => (await (db.select(db.settings)
            ..where((t) => t.id.equals(settingsId)))
          .getSingle())
      .lastExportAt;

  // ------------------------------------------------------------------ import

  /// Validates and writes [backup]. Replace saves a snapshot first.
  Future<ImportResult> importBackup(ParsedBackup backup, ImportMode mode,
      {bool snapshot = true}) async {
    if (mode == ImportMode.replace && snapshot) {
      await _saveSnapshot('pre-import');
    }
    var inserted = 0;
    var updated = 0;
    await db.transaction(() async {
      if (mode == ImportMode.replace) {
        // Children before parents.
        for (final t in <TableInfo<Table, dynamic>>[
          db.lines,
          db.chats,
          db.relationships,
          db.importantDates,
          db.people,
          db.customBlocks,
          db.groups,
        ]) {
          await db.delete(t).go();
        }
      }
      final existing = await _existingUpdatedAt();

      Future<void> put(String coll, Map<String, dynamic> rec,
          Future<void> Function() write) async {
        final id = rec['id'] as String;
        final have = existing[coll]![id];
        if (mode == ImportMode.merge && have != null) {
          if (!(rec['updatedAt'] as DateTime).isAfter(have)) return;
          updated++;
        } else {
          inserted++;
        }
        await write();
      }

      final d = backup.data;
      for (final r in d['groups'] as List<Map<String, dynamic>>) {
        final c = GroupsCompanion(
          id: Value(r['id']),
          name: Value(r['name']),
          defaultIntervalDays: Value(r['defaultIntervalDays']),
          sortOrder: Value(r['sortOrder'] ?? 0),
          color: Value(r['color']),
          createdAt: Value(r['createdAt']),
          updatedAt: Value(r['updatedAt']),
          deletedAt: Value(r['deletedAt']),
          extra: Value(_encodeExtra(r)),
        );
        await put('groups', r, () => db.into(db.groups).insertOnConflictUpdate(c));
      }
      for (final r in d['people'] as List<Map<String, dynamic>>) {
        final cmExtra = r['_contactMethodExtra'];
        final c = PeopleCompanion(
          id: Value(r['id']),
          displayName: Value(r['displayName']),
          groupId: Value(r['groupId']),
          timezone: Value(r['timezone']),
          timezoneConfirmed: Value(r['timezoneConfirmed'] ?? false),
          contactMethodType: Value(r['contactMethodType']),
          contactMethodValue: Value(r['contactMethodValue']),
          fullName: Value(r['fullName']),
          middleName: Value(r['middleName']),
          birthday: Value(r['birthday']),
          intervalOverrideDays: Value(r['intervalOverrideDays']),
          phone: Value(r['phone']),
          socials: Value(r['socials'] == null ? null : jsonEncode(r['socials'])),
          hometown: Value(r['hometown']),
          lastTalkedEstimate: Value(r['lastTalkedEstimate']),
          snoozedUntil: Value(r['snoozedUntil']),
          skippedUntil: Value(r['skippedUntil']),
          archivedAt: Value(r['archivedAt']),
          createdAt: Value(r['createdAt']),
          updatedAt: Value(r['updatedAt']),
          deletedAt: Value(r['deletedAt']),
          extra: Value(_encodeExtra(r, cmExtra: cmExtra)),
        );
        await put('people', r, () => db.into(db.people).insertOnConflictUpdate(c));
      }
      for (final r in d['customBlocks'] as List<Map<String, dynamic>>) {
        final c = CustomBlocksCompanion(
          id: Value(r['id']),
          key: Value(r['key']),
          name: Value(r['name']),
          sortOrder: Value(r['sortOrder'] ?? 0),
          createdAt: Value(r['createdAt']),
          updatedAt: Value(r['updatedAt']),
          deletedAt: Value(r['deletedAt']),
          extra: Value(_encodeExtra(r)),
        );
        await put('customBlocks', r, () => db.into(db.customBlocks).insertOnConflictUpdate(c));
      }
      for (final r in d['familyMembers'] as List<Map<String, dynamic>>) {
        final c = RelationshipsCompanion(
          id: Value(r['id']),
          personId: Value(r['personId']),
          name: Value(r['name']),
          relation: Value(r['relation']),
          birthday: Value(r['birthday']),
          addedInChatId: Value(r['addedInChatId']),
          createdAt: Value(r['createdAt']),
          updatedAt: Value(r['updatedAt']),
          deletedAt: Value(r['deletedAt']),
          extra: Value(_encodeExtra(r)),
        );
        await put('familyMembers', r, () => db.into(db.relationships).insertOnConflictUpdate(c));
      }
      for (final r in d['chats'] as List<Map<String, dynamic>>) {
        final c = ChatsCompanion(
          id: Value(r['id']),
          personId: Value(r['personId']),
          occurredAt: Value(r['occurredAt']),
          timeApproximate: Value(r['timeApproximate'] ?? false),
          type: Value(r['type']),
          depth: Value(r['depth']),
          length: Value(r['length']),
          durationMinutes: Value(r['durationMinutes']),
          feelings: Value(r['feelings'] == null ? null : jsonEncode(r['feelings'])),
          note: Value(r['note']),
          source: Value(r['source'] ?? 'manual'),
          callId: Value(r['callId']),
          createdAt: Value(r['createdAt']),
          updatedAt: Value(r['updatedAt']),
          deletedAt: Value(r['deletedAt']),
          extra: Value(_encodeExtra(r)),
        );
        await put('chats', r, () => db.into(db.chats).insertOnConflictUpdate(c));
      }
      for (final r in d['lines'] as List<Map<String, dynamic>>) {
        final c = LinesCompanion(
          id: Value(r['id']),
          personId: Value(r['personId']),
          block: Value(r['block']),
          lineText: Value(r['text']),
          done: Value(r['done'] ?? false),
          doneAt: Value(r['doneAt']),
          chatId: Value(r['chatId']),
          relationshipId: Value(r['relationshipId']),
          addedInChatId: Value(r['addedInChatId']),
          sortOrder: Value(r['sortOrder'] ?? 0),
          createdAt: Value(r['createdAt']),
          updatedAt: Value(r['updatedAt']),
          deletedAt: Value(r['deletedAt']),
          extra: Value(_encodeExtra(r)),
        );
        await put('lines', r, () => db.into(db.lines).insertOnConflictUpdate(c));
      }
      for (final r in d['importantDates'] as List<Map<String, dynamic>>) {
        final c = ImportantDatesCompanion(
          id: Value(r['id']),
          personId: Value(r['personId']),
          label: Value(r['label']),
          date: Value(r['date']),
          repeatsYearly: Value(r['repeatsYearly'] ?? true),
          createdAt: Value(r['createdAt']),
          updatedAt: Value(r['updatedAt']),
          deletedAt: Value(r['deletedAt']),
          extra: Value(_encodeExtra(r)),
        );
        await put('importantDates', r, () => db.into(db.importantDates).insertOnConflictUpdate(c));
      }

      await _writeSettings(backup, mode);
      // Restoring a backup means setup is not needed on this device.
      await (db.update(db.settings)
            ..where((t) => t.id.equals(settingsId) & t.setupCompletedAt.isNull()))
          .write(SettingsCompanion(setupCompletedAt: Value(_clock().toUtc())));
    });
    return ImportResult(inserted: inserted, updated: updated);
  }

  Future<void> _writeSettings(ParsedBackup b, ImportMode mode) async {
    final s = b.data['settings'] as Map<String, dynamic>;
    final now = _clock().toUtc();
    final cur = await (db.select(db.settings)
          ..where((t) => t.id.equals(settingsId)))
        .getSingle();
    final theirs = (s['updatedAt'] as DateTime?) ?? now;
    if (mode == ImportMode.merge && !theirs.isAfter(cur.updatedAt)) {
      // Keep this device's settings, but never lose unknown collections.
      if (b.dataExtra.isNotEmpty) {
        final ex = _decodeMap(cur.extra);
        ex['dataExtra'] = {...(ex['dataExtra'] as Map? ?? {}), ...b.dataExtra};
        await (db.update(db.settings)..where((t) => t.id.equals(settingsId)))
            .write(SettingsCompanion(extra: Value(jsonEncode(ex))));
      }
      return;
    }
    final extra = <String, dynamic>{
      if ((s['_extra'] as Map).isNotEmpty) 'fields': s['_extra'],
      if (b.dataExtra.isNotEmpty) 'dataExtra': b.dataExtra,
    };
    await (db.update(db.settings)..where((t) => t.id.equals(settingsId))).write(
      SettingsCompanion(
        awakeStart: Value(s['awakeStart']),
        awakeEnd: Value(s['awakeEnd']),
        blockOrder: Value(jsonEncode(s['blockOrder'])),
        skipPolicy: Value(s['skipPolicy']),
        theme: Value(s['theme']),
        recentContactPersonId: Value(s['recentContactPersonId']),
        recentContactAt: Value(s['recentContactAt']),
        updatedAt: Value(theirs),
        createdAt: Value((s['createdAt'] as DateTime?) ?? cur.createdAt),
        schemaVersion: const Value(LatelyDatabase.currentSchemaVersion),
        extra: Value(extra.isEmpty ? null : jsonEncode(extra)),
      ),
    );
  }

  Future<Map<String, Map<String, DateTime>>> _existingUpdatedAt() async {
    Map<String, DateTime> m(List<(String, DateTime)> l) => {for (final e in l) e.$1: e.$2};
    return {
      'groups': m([for (final r in await db.select(db.groups).get()) (r.id, r.updatedAt)]),
      'people': m([for (final r in await db.select(db.people).get()) (r.id, r.updatedAt)]),
      'customBlocks': m([for (final r in await db.select(db.customBlocks).get()) (r.id, r.updatedAt)]),
      'familyMembers': m([for (final r in await db.select(db.relationships).get()) (r.id, r.updatedAt)]),
      'chats': m([for (final r in await db.select(db.chats).get()) (r.id, r.updatedAt)]),
      'lines': m([for (final r in await db.select(db.lines).get()) (r.id, r.updatedAt)]),
      'importantDates': m([for (final r in await db.select(db.importantDates).get()) (r.id, r.updatedAt)]),
    };
  }

  // --------------------------------------------------------------- snapshots

  Future<File> _saveSnapshot(String kind) async {
    await snapshotDir.create(recursive: true);
    final stamp = _clock().toUtc().toIso8601String().replaceAll(':', '-');
    final f = File(p.join(snapshotDir.path, '$kind-$stamp.json'));
    await f.writeAsString(await exportToString(), flush: true);
    final all = snapshotDir
        .listSync()
        .whereType<File>()
        .where((e) => p.basename(e.path).startsWith('$kind-'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final old in all.take(all.length > _keepSnapshots ? all.length - _keepSnapshots : 0)) {
      await old.delete();
    }
    return f;
  }

  File? _latestSnapshot() {
    if (!snapshotDir.existsSync()) return null;
    final all = snapshotDir
        .listSync()
        .whereType<File>()
        .where((e) => p.basename(e.path).startsWith('pre-import-'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    return all.isEmpty ? null : all.last;
  }

  bool get canUndoLastImport => _latestSnapshot() != null;

  /// Puts the data back as it was before the last replace import.
  Future<void> undoLastImport() async {
    final f = _latestSnapshot();
    if (f == null) throw StateError('Nothing to undo');
    final parsed = parseBackup(await f.readAsString());
    // Restoring must not itself become the "last import".
    await importBackup(parsed, ImportMode.replace, snapshot: false);
    await f.delete();
  }

  // ----------------------------------------------------------------- helpers

  static String _t(DateTime d) => d.toUtc().toIso8601String();
  static String? _tn(DateTime? d) => d == null ? null : _t(d);
  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Map<String, dynamic> _decodeMap(String? s) =>
      s == null ? {} : Map<String, dynamic>.from(jsonDecode(s) as Map);

  /// A record's known fields (nulls dropped) plus anything unknown it carried.
  Map<String, dynamic> _rec(String? extra, Map<String, dynamic> known,
      DateTime created, DateTime updated, DateTime? deleted) {
    final out = <String, dynamic>{..._decodeMap(extra)};
    // Reconstruct nested contactMethod extras if present.
    for (final e in known.entries) {
      if (e.value != null) out[e.key] = e.value;
    }
    out['createdAt'] = _t(created);
    out['updatedAt'] = _t(updated);
    if (deleted != null) out['deletedAt'] = _t(deleted);
    final cmx = out.remove('_contactMethodExtra');
    if (cmx is Map && out['contactMethod'] is Map) {
      out['contactMethod'] = {...cmx, ...(out['contactMethod'] as Map)};
    }
    return out;
  }

  String? _encodeExtra(Map<String, dynamic> r, {Object? cmExtra}) {
    final m = <String, dynamic>{...(r['_extra'] as Map)};
    if (cmExtra != null) m['_contactMethodExtra'] = cmExtra;
    return m.isEmpty ? null : jsonEncode(m);
  }
}

import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../app_config.dart';
import 'backup_models.dart';

/// Pure backup file logic: checksum, validation, migration. No storage here.

/// JSON with sorted keys and no whitespace, so the checksum does not depend on
/// how the file was formatted.
String canonicalJson(Object? v) => jsonEncode(_sorted(v));

Object? _sorted(Object? v) {
  if (v is Map) {
    final keys = v.keys.map((k) => k.toString()).toList()..sort();
    return {for (final k in keys) k: _sorted(v[k])};
  }
  if (v is List) return v.map(_sorted).toList();
  return v;
}

String checksumOf(Object? data) =>
    'sha256:${sha256.convert(utf8.encode(canonicalJson(data)))}';

/// Collections in the order they must be written (references point upward).
const collectionOrder = [
  'groups',
  'people',
  'customBlocks',
  'familyMembers',
  'chats',
  'lines',
  'importantDates',
];

enum _K { str, int_, bool_, inst, strList, date }

class _F {
  const _F(this.name, this.kind, {this.required = false});
  final String name;
  final _K kind;
  final bool required;
}

const _common = [
  _F('id', _K.str, required: true),
  _F('createdAt', _K.inst, required: true),
  _F('updatedAt', _K.inst, required: true),
  _F('deletedAt', _K.inst),
];

const _fields = <String, List<_F>>{
  'groups': [
    _F('name', _K.str, required: true),
    _F('defaultIntervalDays', _K.int_, required: true),
    _F('sortOrder', _K.int_),
    _F('color', _K.str),
  ],
  'people': [
    _F('displayName', _K.str, required: true),
    _F('groupId', _K.str, required: true),
    _F('timezone', _K.str, required: true),
    // contactMethod {type, value} is handled by hand below.
    _F('timezoneConfirmed', _K.bool_),
    _F('fullName', _K.str),
    _F('middleName', _K.str),
    _F('birthday', _K.date),
    _F('intervalOverrideDays', _K.int_),
    _F('phone', _K.str),
    _F('socials', _K.strList),
    _F('hometown', _K.str),
    _F('lastTalkedEstimate', _K.inst),
    _F('snoozedUntil', _K.inst),
    _F('skippedUntil', _K.inst),
    _F('archivedAt', _K.inst),
  ],
  'chats': [
    _F('personId', _K.str, required: true),
    _F('occurredAt', _K.inst, required: true),
    _F('type', _K.str, required: true),
    _F('depth', _K.str, required: true),
    _F('length', _K.str, required: true),
    _F('durationMinutes', _K.int_),
    _F('timeApproximate', _K.bool_),
    _F('feelings', _K.strList),
    _F('note', _K.str),
    _F('source', _K.str),
    _F('callId', _K.str),
  ],
  'lines': [
    _F('personId', _K.str, required: true),
    _F('block', _K.str, required: true),
    _F('text', _K.str, required: true),
    _F('done', _K.bool_),
    _F('doneAt', _K.inst),
    _F('chatId', _K.str),
    _F('relationshipId', _K.str),
    _F('addedInChatId', _K.str),
    _F('sortOrder', _K.int_),
  ],
  'familyMembers': [
    _F('personId', _K.str, required: true),
    _F('name', _K.str, required: true),
    _F('relation', _K.str),
    _F('birthday', _K.date),
    _F('addedInChatId', _K.str),
  ],
  'importantDates': [
    _F('personId', _K.str, required: true),
    _F('label', _K.str, required: true),
    _F('date', _K.date, required: true),
    _F('repeatsYearly', _K.bool_),
  ],
  'customBlocks': [
    _F('key', _K.str, required: true),
    _F('name', _K.str, required: true),
    _F('sortOrder', _K.int_),
  ],
};

const _settingsFields = [
  _F('awakeStart', _K.str, required: true),
  _F('awakeEnd', _K.str, required: true),
  // blockOrder (list of strings) is handled by hand.
  _F('skipPolicy', _K.str),
  _F('theme', _K.str),
  _F('recentContactPersonId', _K.str),
  _F('recentContactAt', _K.inst),
  _F('id', _K.str),
  _F('createdAt', _K.inst),
  _F('updatedAt', _K.inst),
];

final _versionRe = RegExp(r'^(\d+)\.(\d+)$');
final _dateRe = RegExp(r'^(\d{4}|-)-\d{2}-\d{2}$');
final _timeRe = RegExp(r'^\d{2}:\d{2}$');

/// Upgrades a file's data one major version at a time. Entry `n` upgrades
/// major n to n + 1. Kept forever; empty while only major 1 exists.
final Map<int, Map<String, dynamic> Function(Map<String, dynamic> data)>
    dataMigrations = {};

/// Validates [text] completely and returns it ready to write, or throws a
/// [BackupException]. Nothing outside this function is touched.
ParsedBackup parseBackup(String text) {
  Object? root;
  try {
    root = jsonDecode(text);
  } catch (_) {
    throw BackupException(
        BackupProblem.notABackup, 'This file is not a Lately backup.');
  }
  if (root is! Map || root['format'] != AppConfig.backupFormat) {
    throw BackupException(
        BackupProblem.notABackup, 'This file is not a Lately backup.');
  }

  final version = root['formatVersion'];
  final vm = version is String ? _versionRe.firstMatch(version) : null;
  if (vm == null) {
    throw BackupException(
        BackupProblem.invalid, 'The backup has no valid format version.');
  }
  final major = int.parse(vm.group(1)!);
  if (major > AppConfig.backupMajor) {
    throw BackupException(
        BackupProblem.newerVersion,
        'This backup was made by a newer version of Lately (format $version). '
        'Update the app, then try again. Nothing was changed.');
  }
  if (major < 1) {
    throw BackupException(BackupProblem.invalid, 'Unknown format version $version.');
  }

  var data = root['data'];
  if (data is! Map) {
    throw BackupException(BackupProblem.invalid, 'The backup has no data.');
  }
  final given = root['checksum'];
  if (given is! String || given != checksumOf(data)) {
    throw BackupException(
        BackupProblem.corrupted,
        'This backup is damaged or was edited (checksum does not match). '
        'Nothing was changed.');
  }

  var dataMap = Map<String, dynamic>.from(data);
  for (var m = major; m < AppConfig.backupMajor; m++) {
    final step = dataMigrations[m];
    if (step == null) {
      throw BackupException(
          BackupProblem.invalid, 'No upgrade path from format $version.');
    }
    dataMap = step(dataMap);
  }

  final out = <String, dynamic>{};
  final ids = <String, Set<String>>{};

  // Settings
  final s = dataMap['settings'];
  if (s is! Map) throw _bad('settings', 'is missing');
  out['settings'] = _settings(Map<String, dynamic>.from(s));

  for (final name in collectionOrder) {
    final raw = dataMap[name] ?? <dynamic>[];
    if (raw is! List) throw _bad(name, 'must be a list');
    final records = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (var i = 0; i < raw.length; i++) {
      final r = raw[i];
      if (r is! Map) throw _bad('$name[$i]', 'must be an object');
      final rec = _record(name, i, Map<String, dynamic>.from(r));
      if (!seen.add(rec['id'] as String)) {
        throw _bad('$name[$i]', 'duplicate id ${rec['id']}');
      }
      records.add(rec);
    }
    out[name] = records;
    ids[name] = seen;
  }

  _checkRefs(out, ids);

  final known = {'settings', ...collectionOrder};
  final extra = {
    for (final e in dataMap.entries)
      if (!known.contains(e.key)) e.key: e.value,
  };

  DateTime? exportedAt;
  final ea = root['exportedAt'];
  if (ea is String) exportedAt = DateTime.tryParse(ea)?.toUtc();

  return ParsedBackup(
    formatVersion: version as String,
    appVersion: root['appVersion'] is String ? root['appVersion'] as String : null,
    exportedAt: exportedAt,
    data: out,
    dataExtra: extra,
  );
}

BackupException _bad(String where, String what) =>
    BackupException(BackupProblem.invalid, 'Backup problem in $where: $what.');

Map<String, dynamic> _settings(Map<String, dynamic> raw) {
  final rec = <String, dynamic>{};
  final known = <String>{'blockOrder'};
  for (final f in _settingsFields) {
    known.add(f.name);
    _field('settings', f, raw, rec);
  }
  final t = [rec['awakeStart'], rec['awakeEnd']];
  if (t.any((v) => !_timeRe.hasMatch(v as String))) {
    throw _bad('settings', 'awake times must look like 08:00');
  }
  final bo = raw['blockOrder'];
  if (bo is! List || bo.any((e) => e is! String)) {
    throw _bad('settings.blockOrder', 'must be a list of text');
  }
  rec['blockOrder'] = List<String>.from(bo);
  rec['_extra'] = {
    for (final e in raw.entries)
      if (!known.contains(e.key)) e.key: e.value,
  };
  return rec;
}

Map<String, dynamic> _record(String coll, int i, Map<String, dynamic> raw) {
  final where = '$coll[$i]';
  final rec = <String, dynamic>{};
  final known = <String>{};
  for (final f in [..._common, ..._fields[coll]!]) {
    known.add(f.name);
    _field(where, f, raw, rec);
  }
  if (coll == 'people') {
    known.add('contactMethod');
    final cm = raw['contactMethod'];
    if (cm is! Map || cm['type'] is! String) {
      throw _bad(where, 'contactMethod needs a type');
    }
    rec['contactMethodType'] = cm['type'];
    final v = cm['value'];
    if (v != null && v is! String) throw _bad(where, 'contactMethod.value must be text');
    rec['contactMethodValue'] = v;
    final cmExtra = {
      for (final e in cm.entries)
        if (e.key != 'type' && e.key != 'value') e.key: e.value,
    };
    if (cmExtra.isNotEmpty) rec['_contactMethodExtra'] = cmExtra;
  }
  rec['_extra'] = {
    for (final e in raw.entries)
      if (!known.contains(e.key)) e.key: e.value,
  };
  return rec;
}

void _field(String where, _F f, Map<String, dynamic> raw, Map<String, dynamic> out) {
  final v = raw[f.name];
  if (v == null) {
    if (f.required) throw _bad(where, '${f.name} is required');
    out[f.name] = null;
    return;
  }
  switch (f.kind) {
    case _K.str:
      if (v is! String) throw _bad(where, '${f.name} must be text');
      if (f.required && v.isEmpty) throw _bad(where, '${f.name} must not be empty');
      out[f.name] = v;
    case _K.int_:
      if (v is! int) throw _bad(where, '${f.name} must be a whole number');
      out[f.name] = v;
    case _K.bool_:
      if (v is! bool) throw _bad(where, '${f.name} must be true or false');
      out[f.name] = v;
    case _K.inst:
      final d = v is String ? DateTime.tryParse(v) : null;
      if (d == null) throw _bad(where, '${f.name} must be an ISO 8601 time');
      out[f.name] = d.toUtc();
    case _K.date:
      if (v is! String || !_dateRe.hasMatch(v)) {
        throw _bad(where, '${f.name} must look like 2026-03-14 or --03-14');
      }
      out[f.name] = v;
    case _K.strList:
      if (v is! List || v.any((e) => e is! String)) {
        throw _bad(where, '${f.name} must be a list of text');
      }
      out[f.name] = List<String>.from(v);
  }
}

void _checkRefs(Map<String, dynamic> d, Map<String, Set<String>> ids) {
  void need(String coll, String field, String target, {bool optional = false}) {
    for (final r in d[coll] as List<Map<String, dynamic>>) {
      final v = r[field] as String?;
      if (v == null) {
        if (optional) continue;
      } else if (!ids[target]!.contains(v)) {
        throw _bad('$coll ${r['id']}', '$field points to a missing $target record');
      }
    }
  }

  need('people', 'groupId', 'groups');
  for (final c in ['chats', 'lines', 'familyMembers', 'importantDates']) {
    need(c, 'personId', 'people');
  }
  need('lines', 'relationshipId', 'familyMembers', optional: true);
  need('lines', 'chatId', 'chats', optional: true);
  need('lines', 'addedInChatId', 'chats', optional: true);
  need('familyMembers', 'addedInChatId', 'chats', optional: true);
}

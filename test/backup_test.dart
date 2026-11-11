import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/app_config.dart';
import 'package:lately/data/backup/backup_codec.dart';
import 'package:lately/data/backup/backup_models.dart';
import 'package:lately/data/backup/backup_service.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/repository.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Re-signs [data] so tests can build files that are valid except for one thing.
String signed(Map<String, dynamic> file) {
  file['checksum'] = checksumOf(file['data']);
  return jsonEncode(file);
}

Map<String, dynamic> fixtureMap(String name) =>
    jsonDecode(fixture(name)) as Map<String, dynamic>;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory tmp;
  late LatelyDatabase db;
  late BackupService svc;
  late Repository repo;
  var now = DateTime.utc(2026, 11, 9, 8);

  LatelyDatabase newDb() => LatelyDatabase(NativeDatabase.memory());

  setUp(() {
    now = DateTime.utc(2026, 11, 9, 8);
    tmp = Directory.systemTemp.createTempSync('lately_backup_test');
    db = newDb();
    svc = BackupService(db, snapshotDir: Directory('${tmp.path}/snap'), clock: () => now);
    repo = Repository(db, clock: () => now);
  });
  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  const fixtures = [
    'backup_v1_0_minimal.json',
    'backup_v1_0_full.json',
    'backup_v1_7_unknown_fields.json',
  ];

  group('every sample file for every format version imports', () {
    for (final f in fixtures) {
      test(f, () async {
        final parsed = parseBackup(fixture(f));
        await svc.importBackup(parsed, ImportMode.replace);
        expect((await repo.listPeople()), isNotEmpty);
        // And a second device can read what this one writes back out.
        final again = parseBackup(await svc.exportToString());
        expect(again.count('people'), parsed.count('people'));
      });
    }
  });

  test('minimal file (the example in the technical plan) lands correctly', () async {
    await svc.importBackup(parseBackup(fixture('backup_v1_0_minimal.json')), ImportMode.replace);
    final sam = (await repo.getPerson('p-001'))!;
    expect(sam.displayName, 'Sam');
    expect(sam.timezone, 'Europe/Lisbon');
    expect(sam.contactMethodType, 'text');
    expect(sam.birthday, '--03-14');
    expect((await repo.listGroups()).single.name, 'Friends');
    expect((await repo.chatsFor('p-001')).single.length, 'catchup');
    expect((await repo.linesFor('p-001')).single.lineText, 'Ask about the new job');
    expect((await repo.getSettings()).awakeEnd, '22:00');
  });

  test('full file keeps every field, including soft deletes', () async {
    await svc.importBackup(parseBackup(fixture('backup_v1_0_full.json')), ImportMode.replace);
    final ruth = (await repo.getPerson('p-ruth'))!;
    expect(ruth.intervalOverrideDays, 21);
    expect(ruth.timezoneConfirmed, isTrue);
    expect(ruth.birthday, '1990-09-27');
    expect((await repo.listArchivedPeople()).single.id, 'p-old');
    expect((await repo.chatsFor('p-ruth')).single.timeApproximate, isTrue);
    expect((await repo.linesFor('p-ruth')).map((l) => l.id), unorderedEquals(['l-1', 'l-2']));
    final exported = jsonDecode(await svc.exportToString())['data'] as Map;
    final lines = (exported['lines'] as List).cast<Map>();
    expect(lines.firstWhere((l) => l['id'] == 'l-deleted')['deletedAt'], isNotNull);
    expect((await repo.getSettings()).skipPolicy, 'midnight');
  });

  test('round trip: export, import on an empty database, export again is identical', () async {
    await svc.importBackup(parseBackup(fixture('backup_v1_0_full.json')), ImportMode.replace);
    final first = jsonDecode(await svc.exportToString()) as Map;

    final db2 = newDb();
    addTearDown(db2.close);
    final svc2 = BackupService(db2, snapshotDir: Directory('${tmp.path}/snap2'), clock: () => now);
    await svc2.importBackup(parseBackup(jsonEncode(first)), ImportMode.replace);
    final second = jsonDecode(await svc2.exportToString()) as Map;

    expect(canonicalJson(second['data']), canonicalJson(first['data']));
    expect(second['checksum'], first['checksum']);
  });

  test('a newer minor version is accepted and its unknown fields survive export', () async {
    await svc.importBackup(parseBackup(fixture('backup_v1_7_unknown_fields.json')), ImportMode.replace);
    final data = jsonDecode(await svc.exportToString())['data'] as Map;
    expect((data['people'] as List).single['pronouns'], 'they/them');
    expect((data['people'] as List).single['contactMethod']['verified'], isTrue);
    expect((data['groups'] as List).single['icon'], 'star');
    expect((data['chats'] as List).single['mood'], 'bright');
    expect((data['chats'] as List).single['type'], 'video'); // unknown value kept
    expect(data['gifts'], [
      {'id': 'x-1', 'idea': 'Tea'}
    ]);
    expect((data['settings'] as Map)['futureSetting'], {'a': 1});
  });

  group('files that must be refused, with nothing changed', () {
    Future<void> expectRefused(String text, BackupProblem problem) async {
      await svc.importBackup(parseBackup(fixture('backup_v1_0_minimal.json')), ImportMode.replace);
      final before = await svc.exportToString();
      expect(() => parseBackup(text),
          throwsA(isA<BackupException>().having((e) => e.problem, 'problem', problem)));
      expect(jsonDecode(await svc.exportToString())['data'], jsonDecode(before)['data']);
    }

    test('not JSON', () => expectRefused('hello', BackupProblem.notABackup));
    test('other JSON', () => expectRefused('{"a":1}', BackupProblem.notABackup));

    test('newer major version', () {
      final m = fixtureMap('backup_v1_0_minimal.json')..['formatVersion'] = '2.0';
      return expectRefused(jsonEncode(m), BackupProblem.newerVersion);
    });

    test('edited after export (bad checksum)', () {
      final m = fixtureMap('backup_v1_0_minimal.json');
      (m['data']['people'][0] as Map)['displayName'] = 'Mallory';
      return expectRefused(jsonEncode(m), BackupProblem.corrupted);
    });

    test('truncated file', () async {
      final t = fixture('backup_v1_0_minimal.json');
      await expectRefused(t.substring(0, t.length ~/ 2), BackupProblem.notABackup);
    });

    test('missing checksum', () {
      final m = fixtureMap('backup_v1_0_minimal.json')..remove('checksum');
      return expectRefused(jsonEncode(m), BackupProblem.corrupted);
    });

    test('missing required field', () {
      final m = fixtureMap('backup_v1_0_minimal.json');
      (m['data']['people'][0] as Map).remove('timezone');
      return expectRefused(signed(m), BackupProblem.invalid);
    });

    test('wrong type', () {
      final m = fixtureMap('backup_v1_0_minimal.json');
      (m['data']['groups'][0] as Map)['defaultIntervalDays'] = 'thirty';
      return expectRefused(signed(m), BackupProblem.invalid);
    });

    test('reference to a person that is not in the file', () {
      final m = fixtureMap('backup_v1_0_minimal.json');
      (m['data']['chats'][0] as Map)['personId'] = 'p-nope';
      return expectRefused(signed(m), BackupProblem.invalid);
    });

    test('duplicate ids', () {
      final m = fixtureMap('backup_v1_0_minimal.json');
      (m['data']['groups'] as List).add(Map.of(m['data']['groups'][0] as Map));
      return expectRefused(signed(m), BackupProblem.invalid);
    });

    test('bad date', () {
      final m = fixtureMap('backup_v1_0_minimal.json');
      (m['data']['people'][0] as Map)['birthday'] = 'March 14';
      return expectRefused(signed(m), BackupProblem.invalid);
    });
  });

  test('a write that fails half way rolls everything back', () async {
    await svc.importBackup(parseBackup(fixture('backup_v1_0_minimal.json')), ImportMode.replace);
    final before = jsonDecode(await svc.exportToString())['data'];

    final bad = parseBackup(fixture('backup_v1_0_full.json'));
    // Passes validation, then breaks a database rule part way through.
    (bad.data['lines'] as List<Map<String, dynamic>>).last['personId'] = 'ghost';
    await expectLater(svc.importBackup(bad, ImportMode.replace), throwsA(anything));

    expect(jsonDecode(await svc.exportToString())['data'], before);
    expect((await repo.getPerson('p-001')), isNotNull);
  });

  group('merge', () {
    Future<Map<String, dynamic>> loadMinimal() async {
      await svc.importBackup(parseBackup(fixture('backup_v1_0_minimal.json')), ImportMode.replace);
      return fixtureMap('backup_v1_0_minimal.json');
    }

    test('adds records that are missing and keeps what is here', () async {
      await loadMinimal();
      await repo.createPerson(displayName: 'Local', groupId: 'g-001', timezone: 'UTC', contactMethodType: 'text');
      final r = await svc.importBackup(parseBackup(fixture('backup_v1_0_full.json')), ImportMode.merge);
      expect(r.inserted, greaterThan(0));
      final names = (await repo.listPeople()).map((p) => p.displayName);
      expect(names, containsAll(['Sam', 'Local', 'Ruth']));
    });

    test('newer edit in the file wins', () async {
      final m = await loadMinimal();
      (m['data']['people'][0] as Map)
        ..['displayName'] = 'Samuel'
        ..['updatedAt'] = '2026-12-01T00:00:00Z';
      final r = await svc.importBackup(parseBackup(signed(m)), ImportMode.merge);
      expect(r.updated, 1);
      expect((await repo.getPerson('p-001'))!.displayName, 'Samuel');
    });

    test('older edit in the file loses', () async {
      final m = await loadMinimal();
      await repo.updatePerson('p-001', const PeopleCompanion(displayName: Value('Local edit')));
      (m['data']['people'][0] as Map)
        ..['displayName'] = 'Old name'
        ..['updatedAt'] = '2026-01-01T00:00:00Z';
      await svc.importBackup(parseBackup(signed(m)), ImportMode.merge);
      expect((await repo.getPerson('p-001'))!.displayName, 'Local edit');
    });

    test('a deletion carries across and is not undone by an older copy', () async {
      final m = await loadMinimal();
      await repo.deleteLine('l-001');
      // The file still holds the live, older copy of the line.
      await svc.importBackup(parseBackup(signed(m)), ImportMode.merge);
      expect(await repo.linesFor('p-001'), isEmpty);
    });
  });

  test('replace removes what the backup does not contain', () async {
    await svc.importBackup(parseBackup(fixture('backup_v1_0_full.json')), ImportMode.replace);
    await svc.importBackup(parseBackup(fixture('backup_v1_0_minimal.json')), ImportMode.replace);
    expect((await repo.listPeople()).map((p) => p.id), ['p-001']);
    expect(await repo.listArchivedPeople(), isEmpty);
  });

  test('undo last import restores the data from before a replace', () async {
    await repo.createPerson(
        displayName: 'Mine', groupId: (await repo.listGroups()).first.id,
        timezone: 'UTC', contactMethodType: 'text');
    final before = jsonDecode(await svc.exportToString())['data'];
    await svc.importBackup(parseBackup(fixture('backup_v1_0_minimal.json')), ImportMode.replace);
    expect((await repo.listPeople()).single.displayName, 'Sam');
    expect(svc.canUndoLastImport, isTrue);
    await svc.undoLastImport();
    expect(jsonDecode(await svc.exportToString())['data'], before);
    expect(svc.canUndoLastImport, isFalse);
  });

  test('export writes lately-backup-YYYY-MM-DD.json and remembers when', () async {
    now = DateTime.utc(2026, 11, 9, 8);
    expect(await svc.lastExportAt(), isNull);
    final f = await svc.exportToFile(Directory('${tmp.path}/out'));
    expect(f.path.endsWith('lately-backup-${now.year}-11-09.json'), isTrue);
    final j = jsonDecode(f.readAsStringSync()) as Map;
    expect(j['format'], 'lately-backup');
    expect(j['formatVersion'], AppConfig.backupFormatVersion);
    expect(j['appVersion'], AppConfig.appVersion);
    expect((await svc.lastExportAt())!.toUtc(), now);
    expect(f.readAsStringSync().contains('lastExportAt'), isFalse);
  });

  test('checksum does not depend on key order or spacing', () {
    final a = {'b': 1, 'a': [1, 2, {'y': 1, 'x': 2}]};
    final b = jsonDecode('{ "a": [1,2,{"x":2,"y":1}],\n "b":1 }');
    expect(checksumOf(a), checksumOf(b));
  });

  test('app version constant matches pubspec.yaml', () {
    final v = RegExp(r'^version:\s*([\d.]+)\+', multiLine: true)
        .firstMatch(File('pubspec.yaml').readAsStringSync())!
        .group(1);
    expect(AppConfig.appVersion, v);
  });
}

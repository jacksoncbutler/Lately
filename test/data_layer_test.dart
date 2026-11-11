import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/repository.dart';

void main() {
  late LatelyDatabase db;
  late Repository repo;
  var clock = DateTime.utc(2026, 11, 8, 12);

  setUp(() {
    clock = DateTime.utc(2026, 11, 8, 12);
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => clock);
  });
  tearDown(() => db.close());

  Future<String> friend() async =>
      (await repo.listGroups()).firstWhere((g) => g.name == 'Friends').id;

  Future<String> person({String name = 'Sam'}) async => repo.createPerson(
      displayName: name,
      groupId: await friend(),
      timezone: 'Europe/Lisbon',
      contactMethodType: 'text',
      contactMethodValue: '+351000000000');

  test('seeds settings and the three groups with default intervals', () async {
    final s = await repo.getSettings();
    expect(s.awakeStart, '08:00');
    expect(s.awakeEnd, '22:00');
    expect(repo.blockOrderOf(s), defaultBlockOrder);
    expect(s.schemaVersion, LatelyDatabase.currentSchemaVersion);
    final g = {for (final x in await repo.listGroups()) x.name: x.defaultIntervalDays};
    expect(g, {'Parents': 14, 'Siblings': 21, 'Friends': 30});
  });

  test('settings: update', () async {
    await repo.updateSettings(const SettingsCompanion(awakeEnd: Value('23:00')));
    expect((await repo.getSettings()).awakeEnd, '23:00');
  });

  test('groups: create, read, update', () async {
    final id = await repo.createGroup('Cousins', 45, sortOrder: 9);
    expect((await repo.getGroup(id))!.defaultIntervalDays, 45);
    clock = clock.add(const Duration(days: 1));
    await repo.updateGroup(id, const GroupsCompanion(defaultIntervalDays: Value(60)));
    final g = (await repo.getGroup(id))!;
    expect(g.defaultIntervalDays, 60);
    expect(g.updatedAt.isAfter(g.createdAt), isTrue);
  });

  test('people: create, read, update, archive, restore', () async {
    final id = await person();
    expect((await repo.getPerson(id))!.displayName, 'Sam');
    await repo.updatePerson(id, const PeopleCompanion(hometown: Value('Porto')));
    expect((await repo.getPerson(id))!.hometown, 'Porto');
    await repo.archivePerson(id);
    expect(await repo.listPeople(), isEmpty);
    expect((await repo.listArchivedPeople()).single.id, id);
    await repo.restorePerson(id);
    expect((await repo.listPeople()).single.id, id);
  });

  test('interval: override wins, else group default', () async {
    final id = await person();
    expect(await repo.intervalDaysFor((await repo.getPerson(id))!), 30);
    await repo.updatePerson(id, const PeopleCompanion(intervalOverrideDays: Value(10)));
    expect(await repo.intervalDaysFor((await repo.getPerson(id))!), 10);
  });

  test('chats: create, read, update, delete; last contact is computed', () async {
    final id = await person();
    final est = DateTime.utc(2026, 9, 1);
    await repo.updatePerson(id, PeopleCompanion(lastTalkedEstimate: Value(est)));
    expect((await repo.lastContactOf((await repo.getPerson(id))!))!.toUtc(), est);

    final older = await repo.createChat(
        personId: id, occurredAt: DateTime.utc(2026, 10, 1), type: 'call',
        depth: 'varied', length: 'catchup', durationMinutes: 30,
        feelings: ['happy']);
    final newer = await repo.createChat(
        personId: id, occurredAt: DateTime.utc(2026, 10, 20, 12), type: 'text',
        depth: 'shallow', length: 'quick', timeApproximate: true);
    final p = (await repo.getPerson(id))!;
    expect((await repo.lastContactOf(p))!.toUtc(), DateTime.utc(2026, 10, 20, 12));
    expect((await repo.getChat(newer))!.timeApproximate, isTrue);

    await repo.updateChat(older, const ChatsCompanion(note: Value('Job news')));
    expect((await repo.getChat(older))!.note, 'Job news');

    await repo.deleteChat(newer);
    expect(await repo.getChat(newer), isNull);
    expect((await repo.lastContactOf(p))!.toUtc(), DateTime.utc(2026, 10, 1));
    await repo.deleteChat(older);
    expect((await repo.lastContactOf(p))!.toUtc(), est);
  });

  test('lines: create, edit, tick, delete, undo delete', () async {
    final id = await person();
    final l = await repo.createLine(personId: id, block: 'next_time', text: 'Ask about the job');
    await repo.updateLine(l, const LinesCompanion(lineText: Value('Ask about the new job')));
    expect((await repo.linesFor(id, block: 'next_time')).single.lineText, 'Ask about the new job');
    await repo.setLineDone(l, true);
    var row = (await repo.linesFor(id)).single;
    expect(row.done, isTrue);
    expect(row.doneAt, isNotNull);
    await repo.setLineDone(l, false);
    expect((await repo.linesFor(id)).single.doneAt, isNull);
    await repo.deleteLine(l);
    expect(await repo.linesFor(id), isEmpty);
    await repo.undeleteLine(l);
    expect(await repo.linesFor(id), hasLength(1));
  });

  test('relationships: create, update, delete, with their own notes', () async {
    final id = await person();
    final r = await repo.createRelationship(personId: id, name: 'Dana', relation: 'partner');
    await repo.createLine(personId: id, block: 'family', text: 'Likes climbing', relationshipId: r);
    await repo.updateRelationship(r, const RelationshipsCompanion(birthday: Value('--10-03')));
    final got = (await repo.relationshipsFor(id)).single;
    expect(got.birthday, '--10-03');
    expect((await repo.linesFor(id, block: 'family')).single.relationshipId, r);
    await repo.deleteRelationship(r);
    expect(await repo.relationshipsFor(id), isEmpty);
  });

  test('important dates: create, update, delete', () async {
    final id = await person();
    final d = await repo.createImportantDate(personId: id, label: 'Documentary release', date: '2027-03-01', repeatsYearly: false);
    await repo.updateImportantDate(d, const ImportantDatesCompanion(label: Value('Premiere')));
    expect((await repo.importantDatesFor(id)).single.label, 'Premiere');
    await repo.deleteImportantDate(d);
    expect(await repo.importantDatesFor(id), isEmpty);
  });

  test('custom blocks: create, update, delete', () async {
    final c = await repo.createCustomBlock('gifts', 'Gift ideas', sortOrder: 1);
    await repo.updateCustomBlock(c, const CustomBlocksCompanion(name: Value('Gifts')));
    expect((await repo.listCustomBlocks()).single.name, 'Gifts');
    await repo.deleteCustomBlock(c);
    expect(await repo.listCustomBlocks(), isEmpty);
  });

  test('delete forever: only archived, removes everything attached', () async {
    final id = await person();
    await repo.createChat(personId: id, occurredAt: clock, type: 'call', depth: 'deep', length: 'long');
    await repo.createLine(personId: id, block: 'about', text: 'x');
    await repo.createRelationship(personId: id, name: 'Dana');
    await repo.createImportantDate(personId: id, label: 'l', date: '2027-01-01');
    await expectLater(repo.deletePersonForever(id), throwsStateError);
    await repo.archivePerson(id);
    await repo.deletePersonForever(id);
    expect(await repo.getPerson(id), isNull);
    expect(await repo.listArchivedPeople(), isEmpty);
    expect(await repo.chatsFor(id), isEmpty);
    expect(await repo.linesFor(id), isEmpty);
    expect(await repo.relationshipsFor(id), isEmpty);
    expect(await repo.importantDatesFor(id), isEmpty);
  });

  test('foreign keys are enforced', () async {
    await expectLater(
        repo.createPerson(displayName: 'X', groupId: 'missing', timezone: 'UTC', contactMethodType: 'text'),
        throwsA(anything));
  });
}

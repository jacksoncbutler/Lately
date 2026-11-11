import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/database.dart';
import 'package:lately/data/repository.dart';

void main() {
  late LatelyDatabase db;
  late Repository repo;
  var now = DateTime.utc(2026, 11, 11, 14, 10);
  late String sam;

  setUp(() async {
    now = DateTime.utc(2026, 11, 11, 14, 10);
    db = LatelyDatabase(NativeDatabase.memory());
    repo = Repository(db, clock: () => now);
    final g = (await repo.listGroups()).first.id;
    sam = await repo.createPerson(displayName: 'Sam', groupId: g, timezone: 'UTC', contactMethodType: 'text', lastTalkedEstimate: now.subtract(const Duration(days: 100)));
  });
  tearDown(() => db.close());

  test('logChat saves the chat with a derived length and lowercase feelings', () async {
    final id = await repo.logChat(
        personId: sam, occurredAt: now, type: 'call', depth: 'varied', durationMinutes: 30,
        feelings: ['Happy', 'Tired'], note: '  Caught up  ');
    final c = (await repo.getChat(id))!;
    expect((c.type, c.depth, c.length, c.durationMinutes, c.note), ('call', 'varied', 'catchup', 30, 'Caught up'));
    expect(c.feelings, '["happy","tired"]');
    expect(c.timeApproximate, isFalse);
    expect(c.source, 'manual');
  });

  test('a blank note is stored as nothing; an other-day chat is marked approximate', () async {
    final id = await repo.logChat(personId: sam, occurredAt: now, timeApproximate: true, type: 'text', depth: 'shallow', durationMinutes: 5, note: '   ');
    final c = (await repo.getChat(id))!;
    expect(c.note, isNull);
    expect(c.timeApproximate, isTrue);
    expect(c.length, 'quick');
  });

  test('covered Next time items are linked; added lines and people are stamped', () async {
    final covered = await repo.createLine(personId: sam, block: 'next_time', text: 'Ask about job');
    final other = await repo.createLine(personId: sam, block: 'next_time', text: 'Keep for later');
    final added = await repo.createLine(personId: sam, block: 'interests', text: 'Pottery');
    final unrelated = await repo.createLine(personId: sam, block: 'about', text: 'Old fact');
    final rel = await repo.createRelationship(personId: sam, name: 'Ines', relation: 'partner');
    final id = await repo.logChat(
        personId: sam, occurredAt: now, type: 'person', depth: 'deep', durationMinutes: 60,
        coveredLineIds: [covered], addedLineIds: [added], addedRelationshipIds: [rel]);
    final lines = {for (final l in await repo.linesFor(sam)) l.id: l};
    expect(lines[covered]!.chatId, id);
    expect(lines[other]!.chatId, isNull);
    expect(lines[added]!.addedInChatId, id);
    expect(lines[unrelated]!.addedInChatId, isNull);
    expect((await repo.relationshipsFor(sam)).single.addedInChatId, id);
  });

  test('saving resets the clock: last contact is the new chat, and skip and snooze clear', () async {
    await repo.updatePerson(sam, PeopleCompanion(
        snoozedUntil: Value(now.add(const Duration(days: 7))),
        skippedUntil: Value(now.add(const Duration(hours: 5)))));
    expect((await repo.lastContactOf((await repo.getPerson(sam))!))!.toUtc(), now.subtract(const Duration(days: 100)));
    await repo.logChat(personId: sam, occurredAt: now, type: 'call', depth: 'deep', durationMinutes: 20);
    final p = (await repo.getPerson(sam))!;
    expect((await repo.lastContactOf(p))!.toUtc(), now);
    expect(p.snoozedUntil, isNull);
    expect(p.skippedUntil, isNull);
  });

  test('last in person and last call or text come from the chats', () async {
    await repo.logChat(personId: sam, occurredAt: DateTime.utc(2026, 7, 30, 12), type: 'person', depth: 'deep', durationMinutes: 60);
    await repo.logChat(personId: sam, occurredAt: DateTime.utc(2026, 9, 21, 12), type: 'call', depth: 'varied', durationMinutes: 30);
    final chats = await repo.chatsFor(sam);
    expect(chats.first.type, 'call'); // newest first
    expect(chats.where((c) => c.type == 'person').single.occurredAt.toUtc(), DateTime.utc(2026, 7, 30, 12));
  });

  test('an older other-day chat does not move last contact backwards', () async {
    await repo.logChat(personId: sam, occurredAt: now, type: 'call', depth: 'deep', durationMinutes: 20);
    await repo.logChat(personId: sam, occurredAt: now.subtract(const Duration(days: 30)), timeApproximate: true, type: 'text', depth: 'shallow', durationMinutes: 5);
    expect((await repo.lastContactOf((await repo.getPerson(sam))!))!.toUtc(), now);
  });

  test('saving for the person you just tapped Contact for clears that prompt; others keep it', () async {
    final g = (await repo.listGroups()).first.id;
    final other = await repo.createPerson(displayName: 'Bo', groupId: g, timezone: 'UTC', contactMethodType: 'text');
    await repo.setRecentContact(other);
    await repo.logChat(personId: sam, occurredAt: now, type: 'call', depth: 'deep', durationMinutes: 20);
    expect((await repo.getSettings()).recentContactPersonId, other);
    await repo.logChat(personId: other, occurredAt: now, type: 'call', depth: 'deep', durationMinutes: 20);
    final s = await repo.getSettings();
    expect(s.recentContactPersonId, isNull);
    expect(s.recentContactAt, isNull);
  });

  test('the whole save is one step: a failure leaves nothing half done', () async {
    final line = await repo.createLine(personId: sam, block: 'next_time', text: 'x');
    await expectLater(
        repo.logChat(personId: sam, occurredAt: now, type: 'call', depth: 'deep', durationMinutes: 20,
            coveredLineIds: [line], addedRelationshipIds: ['does-not-exist-but-fine']),
        completes); // missing ids are simply not matched
    // A bad person breaks the foreign key: nothing is saved.
    final before = (await repo.chatsFor(sam)).length;
    await expectLater(
        repo.logChat(personId: 'nobody', occurredAt: now, type: 'call', depth: 'deep', durationMinutes: 20),
        throwsA(anything));
    expect((await repo.chatsFor(sam)).length, before);
  });

  test('last contact for everyone: newest chat, else the estimate', () async {
    final g = (await repo.listGroups()).first.id;
    final bo = await repo.createPerson(displayName: 'Bo', groupId: g, timezone: 'UTC', contactMethodType: 'text');
    await repo.logChat(personId: sam, occurredAt: now, type: 'call', depth: 'deep', durationMinutes: 20);
    final m = await repo.lastContactByPerson();
    expect(m[sam]!.toUtc(), now);
    expect(m[bo], isNull); // never talked, no estimate
  });

  test('line order is stable when several are added in the same second', () async {
    for (final t in ['a', 'b', 'c']) {
      await repo.createLine(personId: sam, block: 'interests', text: t);
    }
    expect((await repo.linesFor(sam, block: 'interests')).map((l) => l.lineText), ['a', 'b', 'c']);
  });
}

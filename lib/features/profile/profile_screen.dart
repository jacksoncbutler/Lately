import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../domain/profile_format.dart';
import '../../domain/timezones.dart';
import '../../ui/theme.dart';
import 'edit_person_sheet.dart';
import 'finish_setup_sheet.dart';
import 'reach_sheet.dart';
import '../log/chat_detail_sheet.dart';
import '../log/log_sheet.dart';
import 'profile_blocks.dart';

/// A person's profile: header, key facts, Next time, blocks, recent chats.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.personId, this.backLabel = 'People'});
  final String personId;
  final String backLabel;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _more = false;
  bool _allChats = false;
  Repository get repo => ref.read(repositoryProvider);

  Future<void> _edit(PersonRow p) async {
    final out = await showEditPersonSheet(context, p);
    if (out == EditOutcome.deleted && mounted) Navigator.of(context).pop();
  }

  /// Lines and people tied to a chat: ticked off from Next time or added in it.
  int _newCount(String chatId, List<LineRow> lines, List<RelationshipRow> rels) =>
      lines.where((l) => l.chatId == chatId || l.addedInChatId == chatId).length +
      rels.where((r) => r.addedInChatId == chatId).length;

  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personProvider(widget.personId));
    final person = personAsync.value;
    if (person == null) {
      return Scaffold(
          body: Center(
              child: personAsync.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('This person is no longer here.')));
    }
    final c = LatelyColors.of(context);
    final t = Theme.of(context).textTheme;
    final now = ref.watch(nowProvider);
    final groups = ref.watch(groupsProvider).value ?? const <GroupRow>[];
    final group = groups.where((g) => g.id == person.groupId).firstOrNull;
    final lines = ref.watch(linesProvider(person.id)).value ?? const <LineRow>[];
    final rels = ref.watch(relationshipsProvider(person.id)).value ?? const <RelationshipRow>[];
    final chats = ref.watch(chatsProvider(person.id)).value ?? const <ChatRow>[];

    final interval = person.intervalOverrideDays ?? group?.defaultIntervalDays;
    DateTime? lastOf(bool Function(ChatRow) f) =>
        chats.where(f).map((x) => x.occurredAt).fold<DateTime?>(
            null, (a, b) => a == null || b.isAfter(a) ? b : a);
    final lastPerson = lastOf((x) => x.type == 'person');
    final lastRemote = lastOf((x) => x.type == 'call' || x.type == 'text');
    final value = person.contactMethodValue ?? person.phone;
    final hasContact = value != null && value.trim().isNotEmpty;
    final socials = () {
      if (person.socials == null) return null;
      try {
        return (jsonDecode(person.socials!) as List).join(', ');
      } catch (_) {
        return null;
      }
    }();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
          children: [
            Row(children: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left),
                label: Text(widget.backLabel),
              ),
              const Spacer(),
              TextButton(
                key: const Key('profile-edit'),
                onPressed: () => _edit(person),
                child: const Text('Edit'),
              ),
            ]),
            if (person.archivedAt != null)
              _Strip(
                text: 'Archived. Not suggested on Home.',
                action: 'Restore',
                onAction: () => repo.restorePerson(person.id),
              ),
            if (needsFinishing(person))
              _Strip(
                text: 'Finish setup: where they are and when you last talked.',
                action: 'Finish setup',
                onAction: () => showFinishSetupSheet(context, person),
              ),
            const SizedBox(height: 4),
            Row(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: c.accent,
                foregroundColor: c.onAccent,
                child: Text(person.displayName.characters.first.toUpperCase(),
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(person.displayName,
                      style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
                    if (group != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                            color: c.soft, borderRadius: BorderRadius.circular(10)),
                        child: Text(group.name,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600, color: c.muted)),
                      ),
                    if (!needsFinishing(person))
                      Text('${clockText(person.timezone, now())} there',
                          style: TextStyle(fontSize: 13, color: c.muted)),
                  ]),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                flex: 13,
                child: FilledButton(
                  key: const Key('profile-contact'),
                  onPressed: hasContact ? () => showReachSheet(context, person) : null,
                  child: const Text('Contact'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 10,
                child: OutlinedButton(
                  key: const Key('profile-log'),
                  onPressed: () => showLogSheet(context, personId: person.id),
                  child: const Text('Log'),
                ),
              ),
            ]),
            if (!hasContact)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  Text('Add a number or handle to reach them. ', style: t.bodySmall),
                  GestureDetector(
                    onTap: () => _edit(person),
                    child: Text('Edit',
                        style: t.bodySmall?.copyWith(
                            color: c.accent, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(children: [
                  _FactGrid(facts: [
                    ('Birthday', birthdayLabel(person.birthday) ?? 'Not added'),
                    ('Interval', interval == null ? '' : 'Every $interval days'),
                    ('Timezone',
                        needsFinishing(person) ? 'Not set' : zoneLabel(person.timezone)),
                    ('Prefers', person.contactMethodType == 'call' ? 'Call' : 'Text'),
                    ('Last in person',
                        lastPerson == null ? 'None yet' : shortDate(lastPerson, now())),
                    ('Last call or text',
                        lastRemote == null ? 'None yet' : shortDate(lastRemote, now())),
                  ]),
                  if (_more)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _FactGrid(facts: [
                        ('Number or handle', hasContact ? value : 'Not added'),
                        ('Hometown', person.hometown ?? 'Not added'),
                        ('Socials', socials ?? 'Not added'),
                      ]),
                    ),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      key: const Key('profile-more'),
                      onPressed: () => setState(() => _more = !_more),
                      child: Text(_more ? 'Fewer details' : 'More details'),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            ProfileBlocks(personId: person.id),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SizedBox(
                    height: 44,
                    child: Row(children: [
                      Text('Recent chats',
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('${chats.length} logged', style: t.bodySmall),
                    ]),
                  ),
                  if (chats.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('No chats yet. Log one after you talk.', style: t.bodySmall),
                    )
                  else
                    for (final ch in (_allChats ? chats : chats.take(2)))
                      InkWell(
                        key: Key('chat-${ch.id}'),
                        onTap: () => showChatDetailSheet(context, personId: person.id, chat: ch),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
                          child: Row(children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(shortDate(ch.occurredAt, now()),
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(
                                    chatSummary(
                                      type: ch.type,
                                      length: ch.length,
                                      depth: ch.depth,
                                      minutes: ch.durationMinutes,
                                      feelings: ch.feelings == null
                                          ? const []
                                          : (jsonDecode(ch.feelings!) as List).cast<String>(),
                                    ),
                                    style: t.bodySmall),
                                if (ch.note != null && ch.note!.isNotEmpty)
                                  Text(ch.note!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.bodyMedium),
                              ]),
                            ),
                            if (_newCount(ch.id, lines, rels) > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                    color: c.soft, borderRadius: BorderRadius.circular(10)),
                                child: Text('${_newCount(ch.id, lines, rels)} new',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600, color: c.muted)),
                              ),
                            Icon(Icons.chevron_right, color: c.muted),
                          ]),
                        ),
                      ),
                  if (chats.length > 2)
                    TextButton(
                      onPressed: () => setState(() => _allChats = !_allChats),
                      child: Text(_allChats ? 'Show fewer' : 'See all (${chats.length})'),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({required this.text, required this.action, required this.onAction});
  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        TextButton(onPressed: onAction, child: Text(action)),
      ]),
    );
  }
}

class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.facts});
  final List<(String, String)> facts;

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    return LayoutBuilder(builder: (context, box) {
      final w = (box.maxWidth - 12) / 2;
      return Wrap(spacing: 12, runSpacing: 10, children: [
        for (final f in facts)
          SizedBox(
            width: w,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.$1, style: TextStyle(fontSize: 12, color: c.muted)),
              Text(f.$2, style: const TextStyle(fontWeight: FontWeight.w500)),
            ]),
          ),
      ]);
    });
  }
}

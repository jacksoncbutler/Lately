import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../domain/profile_format.dart';
import '../../domain/timezones.dart';
import '../../ui/block_tile.dart';
import '../../ui/swipe_line.dart';
import '../../ui/theme.dart';
import 'edit_person_sheet.dart';
import 'finish_setup_sheet.dart';
import 'reach_sheet.dart';
import 'relationship_sheet.dart';

const _builtInTitles = {
  'family': 'Their people',
  'interests': 'Interests',
  'about': 'About',
};

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
  bool _addingSection = false;
  final _open = <String>{};
  final _sectionName = TextEditingController();
  final _sectionFocus = FocusNode();

  @override
  void dispose() {
    _sectionName.dispose();
    _sectionFocus.dispose();
    super.dispose();
  }

  Repository get repo => ref.read(repositoryProvider);

  void _deleteLine(String id) {
    repo.deleteLine(id);
    showUndoBar(context, 'Line deleted', () => repo.undeleteLine(id));
  }

  Future<void> _openRelationship(String? id) async {
    final r = await showRelationshipSheet(context,
        personId: widget.personId, relationshipId: id);
    if (r?.deletedId != null && mounted) {
      showUndoBar(context, 'Removed from their people',
          () => repo.undeleteRelationship(r!.deletedId!));
    }
  }

  Future<void> _edit(PersonRow p) async {
    final out = await showEditPersonSheet(context, p);
    if (out == EditOutcome.deleted && mounted) Navigator.of(context).pop();
  }

  Future<void> _addSection() async {
    final name = _sectionName.text.trim();
    if (name.isNotEmpty) await repo.addCustomSection(name);
    _sectionName.clear();
    if (mounted) setState(() => _addingSection = false);
  }

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
    final custom = ref.watch(customBlocksProvider).value ?? const <CustomBlockRow>[];
    final settings = ref.watch(settingsProvider).value;

    final order = <String>[
      if (settings != null) ...repo.blockOrderOf(settings).where(_builtInTitles.containsKey),
    ];
    for (final k in _builtInTitles.keys) {
      if (!order.contains(k)) order.add(k);
    }

    List<BlockItem> linesFor(String block) => [
          for (final l in lines)
            if (l.block == block && l.relationshipId == null)
              BlockItem(l.id, l.lineText, done: l.done),
        ];

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

    Widget tileBlock(String key) {
      final isOpen = _open.contains(key);
      {
        final Widget tile;
        if (key == 'family') {
          tile = BlockTile(
            title: _builtInTitles[key]!,
            open: isOpen,
            onOpenChanged: (v) => setState(() => v ? _open.add(key) : _open.remove(key)),
            items: [for (final r in rels) BlockItem(r.id, relationshipLine(r.name, r.relation))],
            onAddRequest: () => _openRelationship(null),
            onTapItem: _openRelationship,
            onDelete: (id) {
              repo.deleteRelationship(id);
              showUndoBar(context, 'Removed from their people', () => repo.undeleteRelationship(id));
            },
          );
        } else {
          final title = _builtInTitles[key] ?? custom.firstWhere((b) => b.key == key).name;
          tile = BlockTile(
            title: title,
            open: isOpen,
            onOpenChanged: (v) => setState(() => v ? _open.add(key) : _open.remove(key)),
            items: linesFor(key),
            onAdd: (text) => repo.createLine(personId: person.id, block: key, text: text),
            onSave: (id, text) => repo.updateLine(id, LinesCompanion(lineText: Value(text))),
            onDelete: _deleteLine,
          );
        }
        return tile;
      }
    }

    final sectionKeys = [...order, for (final b in custom) b.key];

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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('profile-contact'),
                onPressed: hasContact ? () => showReachSheet(context, person) : null,
                child: const Text('Contact'),
              ),
            ),
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
            BlockTile(
              title: 'Next time',
              next: true,
              open: false,
              onOpenChanged: (_) {},
              items: linesFor('next_time'),
              onAdd: (text) => repo.createLine(personId: person.id, block: 'next_time', text: text),
              onSave: (id, text) => repo.updateLine(id, LinesCompanion(lineText: Value(text))),
              onDelete: _deleteLine,
              onToggle: (id) {
                final l = lines.firstWhere((x) => x.id == id);
                repo.setLineDone(id, !l.done);
              },
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: [
              for (final k in sectionKeys)
                SizedBox(
                  width: _open.contains(k)
                      ? double.infinity
                      : (MediaQuery.of(context).size.width - 36 - 12) / 2,
                  child: tileBlock(k),
                ),
              SizedBox(
                width: double.infinity,
                child: _addingSection
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: c.surface,
                          border: Border.all(color: c.line),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          key: const Key('section-name'),
                          controller: _sectionName,
                          focusNode: _sectionFocus,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Name the section, press Enter',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          onSubmitted: (_) => _addSection(),
                          onTapOutside: (_) => _addSection(),
                        ),
                      )
                    : OutlinedButton.icon(
                        key: const Key('add-section'),
                        onPressed: () => setState(() => _addingSection = true),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add a section'),
                      ),
              ),
            ]),
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
                      Container(
                        key: Key('chat-${ch.id}'),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
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

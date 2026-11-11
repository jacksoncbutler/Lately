import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../domain/profile_format.dart';
import '../../ui/block_tile.dart';
import '../../ui/swipe_line.dart';
import '../../ui/theme.dart';
import 'relationship_sheet.dart';

const builtInBlockTitles = {
  'family': 'Their people',
  'interests': 'Interests',
  'about': 'About',
};

/// Next time plus the block grid (Their people, Interests, About, custom).
/// Used by the profile and by the log popup, so the rules are identical in both.
class ProfileBlocks extends ConsumerStatefulWidget {
  const ProfileBlocks({
    super.key,
    required this.personId,
    this.allowAddSection = true,
    this.onLineAdded,
    this.onRelationshipAdded,
  });

  final String personId;
  final bool allowAddSection;

  /// Called with the id of every line added here (the log popup collects
  /// them to link to the chat when it is saved).
  final ValueChanged<String>? onLineAdded;
  final ValueChanged<String>? onRelationshipAdded;

  @override
  ConsumerState<ProfileBlocks> createState() => _ProfileBlocksState();
}

class _ProfileBlocksState extends ConsumerState<ProfileBlocks> {
  bool _addingSection = false;
  final _open = <String>{};
  final _sectionName = TextEditingController();

  @override
  void dispose() {
    _sectionName.dispose();
    super.dispose();
  }

  Repository get repo => ref.read(repositoryProvider);

  void _deleteLine(String id) {
    repo.deleteLine(id);
    showUndoBar(context, 'Line deleted', () => repo.undeleteLine(id));
  }

  Future<String> _addLine(String block, String text) async {
    final id = await repo.createLine(personId: widget.personId, block: block, text: text);
    widget.onLineAdded?.call(id);
    return id;
  }

  Future<void> _openRelationship(String? id) async {
    final r = await showRelationshipSheet(context,
        personId: widget.personId, relationshipId: id);
    if (r?.createdId != null) widget.onRelationshipAdded?.call(r!.createdId!);
    if (r?.deletedId != null && mounted) {
      showUndoBar(context, 'Removed from their people',
          () => repo.undeleteRelationship(r!.deletedId!));
    }
  }

  Future<void> _addSection() async {
    final name = _sectionName.text.trim();
    if (name.isNotEmpty) await repo.addCustomSection(name);
    _sectionName.clear();
    if (mounted) setState(() => _addingSection = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    final id = widget.personId;
    final lines = ref.watch(linesProvider(id)).value ?? const <LineRow>[];
    final rels = ref.watch(relationshipsProvider(id)).value ?? const <RelationshipRow>[];
    final custom = ref.watch(customBlocksProvider).value ?? const <CustomBlockRow>[];
    final settings = ref.watch(settingsProvider).value;

    final order = <String>[
      if (settings != null) ...repo.blockOrderOf(settings).where(builtInBlockTitles.containsKey),
    ];
    for (final k in builtInBlockTitles.keys) {
      if (!order.contains(k)) order.add(k);
    }
    final sectionKeys = [...order, for (final b in custom) b.key];

    List<BlockItem> linesFor(String block) => [
          for (final l in lines)
            if (l.block == block && l.relationshipId == null)
              BlockItem(l.id, l.lineText, done: l.done),
        ];

    Widget tile(String key) {
      final isOpen = _open.contains(key);
      void setOpen(bool v) => setState(() => v ? _open.add(key) : _open.remove(key));
      if (key == 'family') {
        return BlockTile(
          title: builtInBlockTitles[key]!,
          open: isOpen,
          onOpenChanged: setOpen,
          items: [for (final r in rels) BlockItem(r.id, relationshipLine(r.name, r.relation))],
          onAddRequest: () => _openRelationship(null),
          onTapItem: _openRelationship,
          onDelete: (rid) {
            repo.deleteRelationship(rid);
            showUndoBar(context, 'Removed from their people', () => repo.undeleteRelationship(rid));
          },
        );
      }
      final title = builtInBlockTitles[key] ?? custom.firstWhere((b) => b.key == key).name;
      return BlockTile(
        title: title,
        open: isOpen,
        onOpenChanged: setOpen,
        items: linesFor(key),
        onAdd: (text) => _addLine(key, text),
        onSave: (lid, text) => repo.updateLine(lid, LinesCompanion(lineText: Value(text))),
        onDelete: _deleteLine,
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      BlockTile(
        title: 'Next time',
        next: true,
        open: false,
        onOpenChanged: (_) {},
        items: linesFor('next_time'),
        onAdd: (text) => _addLine('next_time', text),
        onSave: (lid, text) => repo.updateLine(lid, LinesCompanion(lineText: Value(text))),
        onDelete: _deleteLine,
        onToggle: (lid) {
          final l = lines.firstWhere((x) => x.id == lid);
          repo.setLineDone(lid, !l.done);
        },
      ),
      const SizedBox(height: 12),
      LayoutBuilder(builder: (context, box) {
        final half = (box.maxWidth - 12) / 2;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final k in sectionKeys)
            SizedBox(width: _open.contains(k) ? box.maxWidth : half, child: tile(k)),
          if (widget.allowAddSection)
            SizedBox(
              width: box.maxWidth,
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
        ]);
      }),
    ]);
  }
}

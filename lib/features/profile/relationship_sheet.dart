import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/profile_format.dart';
import '../../ui/birthday_picker.dart';
import '../../ui/block_tile.dart';
import '../../ui/swipe_line.dart';

/// Result of closing the card: [deleted] is set when the person was removed
/// from Their people (so the caller can show the Undo bar).
class RelationshipResult {
  const RelationshipResult({this.deletedId});
  final String? deletedId;
}

/// Adds or edits a tile in Their people. Pass [relationshipId] to edit.
Future<RelationshipResult?> showRelationshipSheet(
  BuildContext context, {
  required String personId,
  String? relationshipId,
}) =>
    showModalBottomSheet<RelationshipResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: RelationshipSheet(personId: personId, relationshipId: relationshipId),
      ),
    );

class RelationshipSheet extends ConsumerStatefulWidget {
  const RelationshipSheet({super.key, required this.personId, this.relationshipId});
  final String personId;
  final String? relationshipId;

  @override
  ConsumerState<RelationshipSheet> createState() => _RelationshipSheetState();
}

class _RelationshipSheetState extends ConsumerState<RelationshipSheet> {
  final _name = TextEditingController();
  final _relation = TextEditingController();
  String? _birthday;
  String? _id; // set once the person exists (edit mode, or after switching)
  bool _loaded = false;
  bool _notesOpen = false;
  // Notes typed while adding, saved with the person.
  final _pendingNotes = <BlockItem>[];

  @override
  void initState() {
    super.initState();
    _id = widget.relationshipId;
    _load();
  }

  Future<void> _load() async {
    if (_id == null) {
      setState(() => _loaded = true);
      return;
    }
    final rels = await ref.read(repositoryProvider).relationshipsFor(widget.personId);
    final r = rels.where((x) => x.id == _id).firstOrNull;
    if (r != null) {
      _name.text = r.name;
      _relation.text = r.relation ?? '';
      _birthday = r.birthday;
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _name.dispose();
    _relation.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final r = await showBirthdayPicker(context, initial: _birthday);
    if (r != null) setState(() => _birthday = r.value);
  }

  Future<void> _save() async {
    final repo = ref.read(repositoryProvider);
    final name = _name.text.trim();
    final rel = _relation.text.trim();
    if (_id == null) {
      final id = await repo.createRelationship(
        personId: widget.personId,
        name: name,
        relation: rel.isEmpty ? null : rel,
        birthday: _birthday,
      );
      for (final n in _pendingNotes) {
        await repo.createLine(
            personId: widget.personId, block: 'family', text: n.text, relationshipId: id);
      }
    } else {
      await repo.updateRelationship(
          _id!,
          RelationshipsCompanion(
            name: Value(name),
            relation: Value(rel.isEmpty ? null : rel),
            birthday: Value(_birthday),
          ));
    }
    if (mounted) Navigator.pop(context, const RelationshipResult());
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());
    final t = Theme.of(context).textTheme;
    final repo = ref.read(repositoryProvider);
    final existing = ref.watch(relationshipsProvider(widget.personId)).value ?? const [];
    final q = _name.text.trim().toLowerCase();
    final matches = (_id == null && q.length >= 2)
        ? existing.where((x) => x.name.toLowerCase().contains(q)).take(3).toList()
        : const <RelationshipRow>[];
    final lines = _id == null
        ? null
        : ref.watch(linesProvider(widget.personId)).value
            ?.where((l) => l.relationshipId == _id)
            .toList();
    final notes = _id == null
        ? _pendingNotes
        : [for (final l in lines ?? const <LineRow>[]) BlockItem(l.id, l.lineText)];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 0),
          child: Row(children: [
            Expanded(
              child: Text(
                  _id == null ? 'Add to their people' : (_name.text.isEmpty ? 'Their people' : _name.text),
                  style: t.titleLarge),
            ),
            IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            children: [
              Text('Name', style: t.labelLarge),
              const SizedBox(height: 4),
              TextField(
                key: const Key('rel-name'),
                controller: _name,
                autofocus: _id == null,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              if (matches.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Already in their people. Tap to add a note instead:', style: t.bodySmall),
                Wrap(spacing: 8, children: [
                  for (final m in matches)
                    ActionChip(
                      label: Text(relationshipLine(m.name, m.relation)),
                      onPressed: () {
                        Navigator.pop(context);
                        showRelationshipSheet(context,
                            personId: widget.personId, relationshipId: m.id);
                      },
                    ),
                ]),
              ],
              const SizedBox(height: 12),
              Text('How they are connected', style: t.labelLarge),
              const SizedBox(height: 4),
              TextField(
                key: const Key('rel-relation'),
                controller: _relation,
                decoration: const InputDecoration(hintText: 'mother, brother, partner, best friend'),
              ),
              const SizedBox(height: 12),
              Text('Birthday', style: t.labelLarge),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickBirthday,
                    child: Text(birthdayLabel(_birthday) ?? 'Add birthday'),
                  ),
                ),
                if (_birthday != null)
                  IconButton(
                      tooltip: 'Clear birthday',
                      onPressed: () => setState(() => _birthday = null),
                      icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 14),
              BlockTile(
                title: 'Notes',
                wide: true,
                items: notes,
                open: _notesOpen,
                onOpenChanged: (v) => setState(() => _notesOpen = v),
                onAdd: (text) async {
                  if (_id == null) {
                    setState(() => _pendingNotes.add(BlockItem(newId(), text)));
                  } else {
                    await repo.createLine(
                        personId: widget.personId,
                        block: 'family',
                        text: text,
                        relationshipId: _id);
                  }
                },
                onSave: (id, text) async {
                  if (_id == null) {
                    setState(() {
                      final i = _pendingNotes.indexWhere((n) => n.id == id);
                      _pendingNotes[i] = BlockItem(id, text);
                    });
                  } else {
                    await repo.updateLine(id, LinesCompanion(lineText: Value(text)));
                  }
                },
                onDelete: (id) async {
                  if (_id == null) {
                    setState(() => _pendingNotes.removeWhere((n) => n.id == id));
                  } else {
                    await repo.deleteLine(id);
                    if (context.mounted) {
                      showUndoBar(context, 'Note deleted', () => repo.undeleteLine(id));
                    }
                  }
                },
              ),
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            if (_id != null)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error),
                onPressed: () async {
                  await repo.deleteRelationship(_id!);
                  if (context.mounted) {
                    Navigator.pop(context, RelationshipResult(deletedId: _id));
                  }
                },
                child: const Text('Delete'),
              ),
            if (_id != null) const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _name.text.trim().isEmpty ? null : _save,
                child: const Text('Save'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

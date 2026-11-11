import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../domain/timezones.dart';
import '../../ui/log_fab.dart';
import '../profile/finish_setup_sheet.dart';
import '../profile/profile_screen.dart';
import 'add_person_screen.dart';
import 'bulk_add_screen.dart';

/// Minimal People list for build steps 4 and 5 (add people, open profiles).
/// Search, grouping by group and the tab itself arrive in step 8.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider).value ?? const <PersonRow>[];
    final archived = ref.watch(archivedPeopleProvider).value ?? const <PersonRow>[];
    final groups = {for (final g in ref.watch(groupsProvider).value ?? <GroupRow>[]) g.id: g.name};
    final now = ref.watch(nowProvider);

    Widget tile(PersonRow p) => ListTile(
          key: Key('person-${p.id}'),
          title: Text(p.displayName),
          subtitle: Text(needsFinishing(p)
              ? groups[p.groupId] ?? ''
              : '${groups[p.groupId] ?? ''} · ${zoneLabel(p.timezone)} · ${clockText(p.timezone, now())} there'),
          trailing: needsFinishing(p)
              ? const Chip(label: Text('Finish setup'), visualDensity: VisualDensity.compact)
              : const Icon(Icons.chevron_right),
          onTap: () => _open(context, p),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: people.isEmpty ? null : const LogFab(),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _bulk(context),
                child: const Text('Add from contacts'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AddPersonScreen())),
                child: const Text('Add someone'),
              ),
            ),
          ]),
        ),
        Expanded(
          child: people.isEmpty && archived.isEmpty
              ? const Center(child: Text('No one yet.'))
              : ListView(padding: const EdgeInsets.only(bottom: 96), children: [
                  for (final p in people) ...[tile(p), const Divider(height: 1)],
                  if (archived.isNotEmpty)
                    ExpansionTile(
                      key: const Key('archived-section'),
                      title: Text('Archived (${archived.length})'),
                      children: [for (final p in archived) tile(p)],
                    ),
                ]),
        ),
      ]),
    );
  }

  Future<void> _open(BuildContext context, PersonRow p) async {
    // Bulk-added people finish setup first, then open their profile.
    if (needsFinishing(p) && p.archivedAt == null) {
      final done = await showFinishSetupSheet(context, p);
      if (!done || !context.mounted) return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ProfileScreen(personId: p.id)));
  }

  Future<void> _bulk(BuildContext context) async {
    final n = await Navigator.of(context)
        .push<int>(MaterialPageRoute(builder: (_) => const BulkAddScreen()));
    if (n != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $n. Tap anyone to finish their setup.')));
    }
  }
}

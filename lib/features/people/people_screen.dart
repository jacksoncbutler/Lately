import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/timezones.dart';
import '../../ui/city_picker.dart';
import 'add_person_screen.dart';
import 'bulk_add_screen.dart';

/// Minimal People list for build step 4 (add people and check their local
/// times). Search, grouping, Archived and profiles arrive in steps 5 and 8.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider).value ?? const <PersonRow>[];
    final groups = {for (final g in ref.watch(groupsProvider).value ?? <GroupRow>[]) g.id: g.name};
    final now = ref.watch(nowProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      body: people.isEmpty
          ? const Center(child: Text('No one yet.'))
          : ListView.separated(
              itemCount: people.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = people[i];
                return ListTile(
                  title: Text(p.displayName),
                  subtitle: Text(
                      '${groups[p.groupId] ?? ''} · ${zoneLabel(p.timezone)} · ${clockText(p.timezone, now())} there'),
                  trailing: p.timezoneConfirmed
                      ? null
                      : const Chip(label: Text('Set timezone'), visualDensity: VisualDensity.compact),
                  onTap: () => _editTimezone(context, ref, p),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
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
      ),
    );
  }

  Future<void> _bulk(BuildContext context) async {
    final n = await Navigator.of(context)
        .push<int>(MaterialPageRoute(builder: (_) => const BulkAddScreen()));
    if (n != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $n. Tap anyone to set where they are.')));
    }
  }

  Future<void> _editTimezone(BuildContext context, WidgetRef ref, PersonRow p) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => _TimezoneSheet(person: p),
    );
  }
}

class _TimezoneSheet extends ConsumerStatefulWidget {
  const _TimezoneSheet({required this.person});
  final PersonRow person;

  @override
  ConsumerState<_TimezoneSheet> createState() => _TimezoneSheetState();
}

class _TimezoneSheetState extends ConsumerState<_TimezoneSheet> {
  late String? _zone = widget.person.timezoneConfirmed ? widget.person.timezone : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where is ${widget.person.displayName}?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          CityPicker(
            zone: _zone,
            now: ref.read(nowProvider),
            onChanged: (z) => setState(() => _zone = z),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _zone == null
                ? null
                : () async {
                    await ref.read(repositoryProvider).updatePerson(
                        widget.person.id,
                        PeopleCompanion(
                            timezone: Value(_zone!), timezoneConfirmed: const Value(true)));
                    ref.invalidate(peopleProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

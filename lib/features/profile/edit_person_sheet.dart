import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/profile_format.dart';
import '../../ui/birthday_picker.dart';
import '../../ui/city_picker.dart';

enum EditOutcome { saved, archived, restored, deleted }

/// One sheet with every detail, plus Manage (archive, restore, delete forever).
Future<EditOutcome?> showEditPersonSheet(BuildContext context, PersonRow person) =>
    showModalBottomSheet<EditOutcome>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: EditPersonSheet(person: person),
      ),
    );

class EditPersonSheet extends ConsumerStatefulWidget {
  const EditPersonSheet({super.key, required this.person});
  final PersonRow person;

  @override
  ConsumerState<EditPersonSheet> createState() => _EditPersonSheetState();
}

class _EditPersonSheetState extends ConsumerState<EditPersonSheet> {
  late final _name = TextEditingController(text: widget.person.displayName);
  late final _contact = TextEditingController(
      text: widget.person.contactMethodValue ?? widget.person.phone ?? '');
  late final _interval = TextEditingController(
      text: widget.person.intervalOverrideDays?.toString() ?? '');
  late final _hometown = TextEditingController(text: widget.person.hometown ?? '');
  late final _socials = TextEditingController(text: _socialsText(widget.person.socials));
  late String _groupId = widget.person.groupId;
  late String _method = widget.person.contactMethodType == 'call' ? 'call' : 'text';
  late String? _zone = widget.person.timezoneConfirmed ? widget.person.timezone : null;
  late String? _birthday = widget.person.birthday;
  bool _confirmDelete = false;

  static String _socialsText(String? json) {
    if (json == null) return '';
    try {
      return (jsonDecode(json) as List).cast<String>().join(', ');
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _contact, _interval, _hometown, _socials]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final r = await showBirthdayPicker(context, initial: _birthday);
    if (r != null) setState(() => _birthday = r.value);
  }

  Future<void> _save() async {
    final contact = _contact.text.trim();
    final socials = _socials.text.trim();
    await ref.read(repositoryProvider).updatePerson(
          widget.person.id,
          PeopleCompanion(
            displayName: Value(_name.text.trim()),
            groupId: Value(_groupId),
            contactMethodType: Value(_method),
            contactMethodValue: Value(contact.isEmpty ? null : contact),
            phone: Value(contact.isEmpty ? null : contact),
            timezone: Value(_zone ?? widget.person.timezone),
            timezoneConfirmed: Value(_zone != null),
            birthday: Value(_birthday),
            intervalOverrideDays: Value(int.tryParse(_interval.text.trim())),
            hometown: Value(_hometown.text.trim().isEmpty ? null : _hometown.text.trim()),
            socials: Value(socials.isEmpty ? null : jsonEncode([socials])),
          ),
        );
    if (mounted) Navigator.pop(context, EditOutcome.saved);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = widget.person;
    final groups = ref.watch(groupsProvider).value ?? const <GroupRow>[];
    final groupDays = groups.where((g) => g.id == _groupId).firstOrNull?.defaultIntervalDays;
    final repo = ref.read(repositoryProvider);

    Widget label(String s) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 4),
          child: Text(s.toUpperCase(),
              style: t.labelSmall?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 0),
          child: Row(children: [
            Expanded(child: Text('Edit ${p.displayName}', style: t.titleLarge)),
            IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            children: [
              label('Name'),
              TextField(
                key: const Key('edit-name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              label('Group'),
              Wrap(spacing: 8, runSpacing: 4, children: [
                for (final g in groups)
                  ChoiceChip(
                    label: Text('${g.name} · ${g.defaultIntervalDays}d'),
                    selected: _groupId == g.id,
                    onSelected: (_) => setState(() => _groupId = g.id),
                  ),
              ]),
              label('How you reach them'),
              Row(children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'text', label: Text('Text')),
                    ButtonSegment(value: 'call', label: Text('Call')),
                  ],
                  selected: {_method},
                  onSelectionChanged: (s) => setState(() => _method = s.first),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const Key('edit-contact'),
                    controller: _contact,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: 'Number or handle'),
                  ),
                ),
              ]),
              label('Where they are'),
              CityPicker(
                zone: _zone,
                now: ref.read(nowProvider),
                onChanged: (z) => setState(() => _zone = z),
              ),
              label('Birthday'),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('edit-birthday'),
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
              label('Contact interval in days (blank uses the group)'),
              TextField(
                key: const Key('edit-interval'),
                controller: _interval,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: groupDays == null ? '' : 'Every $groupDays days'),
              ),
              label('Hometown'),
              TextField(key: const Key('edit-hometown'), controller: _hometown),
              label('Socials'),
              TextField(key: const Key('edit-socials'), controller: _socials),
              const SizedBox(height: 22),
              const Divider(),
              label('Manage'),
              if (p.archivedAt == null) ...[
                OutlinedButton(
                  onPressed: () async {
                    await repo.archivePerson(p.id);
                    if (context.mounted) Navigator.pop(context, EditOutcome.archived);
                  },
                  child: Text('Archive ${p.displayName}'),
                ),
                const SizedBox(height: 8),
                Text(
                    'Hides them from suggestions and the People list. Everything is kept, and you can restore them from People at any time.',
                    style: t.bodySmall),
              ] else ...[
                FilledButton(
                  onPressed: () async {
                    await repo.restorePerson(p.id);
                    if (context.mounted) Navigator.pop(context, EditOutcome.restored);
                  },
                  child: Text('Restore ${p.displayName}'),
                ),
                const SizedBox(height: 8),
                if (!_confirmDelete)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error),
                    onPressed: () => setState(() => _confirmDelete = true),
                    child: const Text('Delete forever'),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                            'This removes ${p.displayName}, their notes, chats and people for good. It cannot be undone.'),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _confirmDelete = false),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error),
                              onPressed: () async {
                                await repo.deletePersonForever(p.id);
                                if (context.mounted) Navigator.pop(context, EditOutcome.deleted);
                              },
                              child: const Text('Delete forever'),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _name.text.trim().isEmpty ? null : _save,
              child: const Text('Save changes'),
            ),
          ),
        ),
      ]),
    );
  }
}

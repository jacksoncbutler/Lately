import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/phone.dart';
import '../../domain/profile_format.dart';
import '../../domain/reach.dart';
import '../../ui/birthday_picker.dart';
import '../../ui/city_picker.dart';
import '../../ui/phone_field.dart';
import 'contact_action.dart';

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
  late final Reach _reach = Reach(widget.person);
  late final _instagram = TextEditingController(text: _reach.instagram ?? '');
  late Channel _channel = _reach.channel;
  late PhoneValue _phone = PhoneValue(PhoneParse(raw: _reach.phone ?? ''));
  late final _interval = TextEditingController(
      text: widget.person.intervalOverrideDays?.toString() ?? '');
  late final _hometown = TextEditingController(text: widget.person.hometown ?? '');
  late final _socials = TextEditingController(text: _socialsText(widget.person.socials));
  late String _groupId = widget.person.groupId;
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
    for (final c in [_name, _instagram, _interval, _hometown, _socials]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final r = await showBirthdayPicker(context, initial: _birthday);
    if (r != null) setState(() => _birthday = r.value);
  }

  Future<void> _pause(PersonRow p) async {
    final now = ref.read(nowProvider)();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final d = await showDatePicker(
      context: context,
      initialDate: tomorrow.add(const Duration(days: 6)),
      firstDate: tomorrow,
      lastDate: tomorrow.add(const Duration(days: 730)),
      // Pick from the calendar; no typing dates with slashes.
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Pause until which day?',
    );
    if (d == null) return;
    // Back on the morning of that day (midnight, your time).
    await ref.read(repositoryProvider).snoozeUntil(p.id, DateTime(d.year, d.month, d.day).toUtc());
    if (mounted) Navigator.pop(context, EditOutcome.saved);
  }

  Future<void> _save() async {
    final phone = _phone.stored;
    final ig = instagramUsername(_instagram.text);
    final socials = _socials.text.trim();
    await ref.read(repositoryProvider).updatePerson(
          widget.person.id,
          PeopleCompanion(
            displayName: Value(_name.text.trim()),
            groupId: Value(_groupId),
            contactMethodType: Value(channelType(_channel)),
            // The value mirrors what the preferred channel uses (older readers).
            contactMethodValue: Value(_channel == Channel.instagram ? ig : phone),
            phone: Value(phone),
            instagram: Value(ig),
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
              Wrap(spacing: 8, children: [
                for (final c in Channel.values)
                  ChoiceChip(
                    key: Key('channel-${c.name}'),
                    label: Text(channelLabel(c)),
                    selected: _channel == c,
                    onSelected: (_) => setState(() => _channel = c),
                  ),
              ]),
              const SizedBox(height: 8),
              Text('Contact opens straight to ${channelLabel(_channel)}.', style: t.bodySmall),
              const SizedBox(height: 8),
              PhoneField(
                key: const Key('edit-phone'),
                initial: _reach.phone,
                homeIso: countryOfZone(_zone),
                onChanged: (v) => setState(() => _phone = v),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('edit-instagram'),
                controller: _instagram,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Instagram username',
                  prefixText: '@',
                  errorText: _instagram.text.trim().isEmpty || instagramUsername(_instagram.text) != null
                      ? null
                      : "That doesn't look like a username",
                ),
                onChanged: (_) => setState(() {}),
              ),
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
              label('Other socials'),
              TextField(key: const Key('edit-socials'), controller: _socials),
              const SizedBox(height: 22),
              const Divider(),
              label('Manage'),
              if (p.archivedAt == null) ...[
                if (p.snoozedUntil != null && p.snoozedUntil!.isAfter(ref.read(nowProvider)())) ...[
                  Text('Paused until ${shortDate(p.snoozedUntil!, ref.read(nowProvider)())}',
                      key: const Key('paused-text'), style: t.bodyMedium),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('pause-change'),
                        onPressed: () => _pause(p),
                        child: const Text('Change date'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        key: const Key('pause-resume'),
                        onPressed: () async {
                          await repo.clearSnooze(p.id);
                          if (context.mounted) Navigator.pop(context, EditOutcome.saved);
                        },
                        child: const Text('Resume'),
                      ),
                    ),
                  ]),
                ] else
                  OutlinedButton(
                    key: const Key('pause-button'),
                    onPressed: () => _pause(p),
                    child: const Text('Pause suggestions until…'),
                  ),
                const SizedBox(height: 4),
                Text(
                    'Hides them from Home until that day. They stay in People, and you can resume any time.',
                    style: t.bodySmall),
                const SizedBox(height: 16),
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
              onPressed: _name.text.trim().isEmpty ||
                      (_instagram.text.trim().isNotEmpty && instagramUsername(_instagram.text) == null)
                  ? null
                  : _save,
              child: const Text('Save changes'),
            ),
          ),
        ),
      ]),
    );
  }
}

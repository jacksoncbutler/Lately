import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/device_sources.dart';
import '../../data/providers.dart';

String _digits(String? s) => (s ?? '').replaceAll(RegExp(r'\D'), '');

/// Pick many phone contacts and give the whole batch one group. Their
/// timezone is this phone's, marked unconfirmed, to be fixed afterwards.
class BulkAddScreen extends ConsumerStatefulWidget {
  const BulkAddScreen({super.key});

  @override
  ConsumerState<BulkAddScreen> createState() => _BulkAddScreenState();
}

class _BulkAddScreenState extends ConsumerState<BulkAddScreen> {
  ContactsAccess? _access;
  List<PhoneContact> _contacts = const [];
  Set<String> _existingPhones = {};
  Set<String> _existingNames = {};
  final _picked = <String>{};
  String? _groupId;
  String _query = '';
  bool _busy = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _loading = true);
    final access = await ref.read(contactsSourceProvider).requestAccess();
    if (access != ContactsAccess.granted) {
      if (mounted) setState(() { _access = access; _loading = false; });
      return;
    }
    final contacts = await ref.read(contactsSourceProvider).load();
    final people = await ref.read(repositoryProvider).listPeople();
    if (!mounted) return;
    setState(() {
      _access = access;
      _contacts = contacts;
      _existingPhones = {
        for (final p in people)
          if (_digits(p.phone ?? p.contactMethodValue).length >= 7)
            _digits(p.phone ?? p.contactMethodValue)
      };
      _existingNames = {for (final p in people) p.displayName.toLowerCase()};
      _loading = false;
    });
  }

  bool _already(PhoneContact c) {
    final d = _digits(c.phone);
    if (d.length >= 7) return _existingPhones.contains(d);
    return _existingNames.contains(c.name.toLowerCase());
  }

  Future<void> _add() async {
    setState(() => _busy = true);
    final repo = ref.read(repositoryProvider);
    final zone = await ref.read(deviceTimezoneProvider).current();
    final chosen = _contacts.where((c) => _picked.contains(c.id)).toList();
    await repo.createPeople(
      [for (final c in chosen) (displayName: c.name, phone: c.phone)],
      groupId: _groupId!,
      timezone: zone,
      timezoneConfirmed: false,
      // Where they are and when you last talked are set per person later
      // ("Finish setup"), because they differ for everyone.
    );
    ref.invalidate(peopleProvider);
    if (mounted) Navigator.of(context).pop(chosen.length);
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider).value ?? const [];
    _groupId ??= groups.isEmpty
        ? null
        : (groups.where((g) => g.name == 'Friends').firstOrNull ?? groups.first).id;
    return Scaffold(
      appBar: AppBar(title: const Text('Add from contacts')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _access != ContactsAccess.granted
              ? _denied(context)
              : _list(context, groups),
      bottomNavigationBar: _access == ContactsAccess.granted
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: _picked.isEmpty || _busy || _groupId == null ? null : _add,
                  child: Text(_picked.isEmpty
                      ? 'Pick people to add'
                      : 'Add ${_picked.length} ${_picked.length == 1 ? 'person' : 'people'}'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _denied(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              _access == ContactsAccess.permanentlyDenied
                  ? 'Contacts access is turned off for Lately. You can turn it on in your phone settings, or add people one at a time.'
                  : 'Lately needs to read your contacts once to let you pick people. Nothing leaves your phone.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_access != ContactsAccess.permanentlyDenied)
              FilledButton(onPressed: _start, child: const Text('Try again')),
          ]),
        ),
      );

  Widget _list(BuildContext context, List groups) {
    final q = _query.trim().toLowerCase();
    final shown = _contacts.where((c) => q.isEmpty || c.name.toLowerCase().contains(q)).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Group for everyone you pick (you will finish each person after)', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(spacing: 8, children: [
              for (final g in groups)
                ChoiceChip(
                  label: Text('${g.name} · ${g.defaultIntervalDays}d'),
                  selected: _groupId == g.id,
                  onSelected: (_) => setState(() => _groupId = g.id),
                ),
            ]),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                  hintText: 'Search contacts',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _query = v),
            ),
          ]),
        ),
        Expanded(
          child: shown.isEmpty
              ? const Center(child: Text('No contacts found.'))
              : ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (context, i) {
                    final c = shown[i];
                    final have = _already(c);
                    return CheckboxListTile(
                      value: have || _picked.contains(c.id),
                      onChanged: have
                          ? null
                          : (v) => setState(() =>
                              v == true ? _picked.add(c.id) : _picked.remove(c.id)),
                      title: Text(c.name),
                      subtitle: Text(have ? 'Already added' : (c.phone ?? 'No number')),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/constants.dart';
import '../../ui/city_picker.dart';

/// Single add: the minimum to start (name, group, how to reach, where they
/// are, roughly when you last talked).
class AddPersonScreen extends ConsumerStatefulWidget {
  const AddPersonScreen({super.key});

  @override
  ConsumerState<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends ConsumerState<AddPersonScreen> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  String? _groupId;
  String _method = 'text';
  String? _zone;
  int? _lastTalkedDays;
  String? _deviceZone;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(deviceTimezoneProvider).current().then((z) {
      if (mounted) setState(() => _deviceZone = z);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    super.dispose();
  }

  bool get _ready => _name.text.trim().isNotEmpty && _zone != null && _groupId != null;

  Future<void> _create({required bool addMore}) async {
    setState(() => _busy = true);
    final repo = ref.read(repositoryProvider);
    final now = ref.read(nowProvider)();
    final days = _lastTalkedDays ?? Tune.defaultLastTalkedDays;
    final value = _contact.text.trim();
    await repo.createPerson(
      displayName: _name.text.trim(),
      groupId: _groupId!,
      timezone: _zone!,
      timezoneConfirmed: true,
      contactMethodType: _method,
      contactMethodValue: value.isEmpty ? null : value,
      phone: value.isEmpty ? null : value,
      lastTalkedEstimate: now.subtract(Duration(days: days)),
    );
    ref.invalidate(peopleProvider);
    if (!mounted) return;
    final name = _name.text.trim();
    if (addMore) {
      setState(() {
        _name.clear();
        _contact.clear();
        _zone = null;
        _lastTalkedDays = null;
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $name')));
    } else {
      Navigator.of(context).pop(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider).value ?? const [];
    _groupId ??= groups.isEmpty
        ? null
        : (groups.where((g) => g.name == 'Friends').firstOrNull ?? groups.first).id;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Add a person')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Name', style: t.labelLarge),
          const SizedBox(height: 4),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'First name', border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text('Group', style: t.labelLarge),
          const SizedBox(height: 4),
          Wrap(spacing: 8, children: [
            for (final g in groups)
              ChoiceChip(
                label: Text('${g.name} · ${g.defaultIntervalDays}d'),
                selected: _groupId == g.id,
                onSelected: (_) => setState(() => _groupId = g.id),
              ),
          ]),
          const SizedBox(height: 16),
          Text('How you reach them', style: t.labelLarge),
          const SizedBox(height: 4),
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
                controller: _contact,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    hintText: 'Number or handle', border: OutlineInputBorder()),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Text('Where they are', style: t.labelLarge),
          const SizedBox(height: 4),
          CityPicker(
            zone: _zone,
            now: ref.read(nowProvider),
            deviceZone: _deviceZone,
            onChanged: (z) => setState(() => _zone = z),
          ),
          const SizedBox(height: 16),
          Text('Roughly when did you last talk?', style: t.labelLarge),
          const SizedBox(height: 4),
          Wrap(spacing: 8, children: [
            for (final c in Tune.lastTalkedChoices)
              ChoiceChip(
                label: Text(c.$1),
                selected: _lastTalkedDays == c.$2,
                onSelected: (_) =>
                    setState(() => _lastTalkedDays = _lastTalkedDays == c.$2 ? null : c.$2),
              ),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _ready && !_busy ? () => _create(addMore: true) : null,
                child: const Text('Create and add more'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _ready && !_busy ? () => _create(addMore: false) : null,
                child: const Text('Create'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

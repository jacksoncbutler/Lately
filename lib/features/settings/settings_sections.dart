import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/profile_format.dart';
import '../home/home_data.dart';
import '../setup/setup_screen.dart' show blockNames;

Widget _sectionTitle(BuildContext context, String title, String? note) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(note, style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );

/// Groups and how often you want to talk to each one.
class GroupsSection extends ConsumerWidget {
  const GroupsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider).value ?? const <GroupRow>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(context, 'Groups',
          'How often you want to talk to each group. A person can have their own interval on their profile.'),
      const SizedBox(height: 4),
      for (final g in groups)
        ListTile(
          key: Key('group-${g.id}'),
          contentPadding: EdgeInsets.zero,
          title: Text(g.name),
          subtitle: Text('every ${g.defaultIntervalDays} days'),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => showDialog<void>(context: context, builder: (_) => _GroupDialog(group: g)),
        ),
      TextButton.icon(
        key: const Key('add-group'),
        onPressed: () => showDialog<void>(context: context, builder: (_) => const _GroupDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Add a group'),
      ),
    ]);
  }
}

class _GroupDialog extends ConsumerStatefulWidget {
  const _GroupDialog({this.group});
  final GroupRow? group;

  @override
  ConsumerState<_GroupDialog> createState() => _GroupDialogState();
}

class _GroupDialogState extends ConsumerState<_GroupDialog> {
  late final _name = TextEditingController(text: widget.group?.name ?? '');
  late final _days =
      TextEditingController(text: (widget.group?.defaultIntervalDays ?? 30).toString());
  int _people = 0;
  int _groupCount = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    final g = widget.group;
    final people = g == null ? 0 : await repo.peopleInGroup(g.id);
    final count = (await repo.listGroups()).length;
    if (mounted) {
      setState(() {
        _people = people;
        _groupCount = count;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _days.dispose();
    super.dispose();
  }

  int? get _daysValue {
    final d = int.tryParse(_days.text.trim());
    return (d == null || d < 1 || d > 365) ? null : d;
  }

  bool get _valid => _name.text.trim().isNotEmpty && _daysValue != null;

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final canDelete = g != null && _people == 0 && _groupCount > 1;
    return AlertDialog(
      title: Text(g == null ? 'Add a group' : 'Edit ${g.name}'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            key: const Key('group-name'),
            controller: _name,
            autofocus: g == null,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('group-days'),
            controller: _days,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            decoration: InputDecoration(
              labelText: 'Talk about every (days)',
              errorText: _days.text.isEmpty || _daysValue != null ? null : 'Use 1 to 365 days',
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (g != null && !canDelete)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _people > 0
                    ? 'This group has $_people ${_people == 1 ? 'person' : 'people'}, so it cannot be removed. Move them to another group first.'
                    : 'Keep at least one group.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ]),
      ),
      actions: [
        if (canDelete)
          TextButton(
            key: const Key('group-delete'),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              await ref.read(repositoryProvider).deleteGroup(g.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          key: const Key('group-save'),
          onPressed: !_valid
              ? null
              : () async {
                  final repo = ref.read(repositoryProvider);
                  if (g == null) {
                    final n = (await repo.listGroups()).length;
                    await repo.createGroup(_name.text.trim(), _daysValue!, sortOrder: n);
                  } else {
                    await repo.updateGroup(
                        g.id,
                        GroupsCompanion(
                            name: Value(_name.text.trim()),
                            defaultIntervalDays: Value(_daysValue!)));
                  }
                  if (context.mounted) Navigator.pop(context);
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// The default order of the blocks on a profile (Next time always comes first).
class BlockOrderSection extends ConsumerWidget {
  const BlockOrderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final repo = ref.read(repositoryProvider);
    if (settings == null) return const SizedBox.shrink();
    final order = repo.blockOrderOf(settings).where((k) => k != 'next_time').toList();
    for (final k in blockNames.keys) {
      if (k != 'next_time' && !order.contains(k)) order.add(k);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(context, 'Profile blocks',
          'Drag to set the order of the blocks on every profile. Next time always comes first.'),
      const SizedBox(height: 4),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.lock_outline),
        title: Text('Next time'),
      ),
      ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorderItem: (from, to) {
          final next = [...order];
          next.insert(to, next.removeAt(from));
          repo.setBlockOrder(['next_time', ...next]);
        },
        children: [
          for (final k in order)
            ListTile(
              key: Key('block-order-$k'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.drag_handle),
              title: Text(blockNames[k] ?? k),
            ),
        ],
      ),
    ]);
  }
}

/// When people are assumed to be awake (in their own timezone).
class AwakeSection extends ConsumerWidget {
  const AwakeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null) return const SizedBox.shrink();
    final start = parseClockMinutes(settings.awakeStart, 8 * 60);
    final end = parseClockMinutes(settings.awakeEnd, 22 * 60);

    Future<void> pick({required bool isStart}) async {
      final current = isStart ? start : end;
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
        helpText: isStart ? 'People wake up at' : 'People go to bed at',
      );
      if (t == null) return;
      final minutes = t.hour * 60 + t.minute;
      final newStart = isStart ? minutes : start;
      final newEnd = isStart ? end : minutes;
      if (newStart >= newEnd) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wake-up time must be before bedtime.')));
        }
        return;
      }
      await ref.read(repositoryProvider).setAwakeWindow(clockStored(newStart), clockStored(newEnd));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle(context, 'Awake hours',
          'Home only suggests people during these hours in their own timezone.'),
      ListTile(
        key: const Key('awake-start'),
        contentPadding: EdgeInsets.zero,
        title: const Text('Awake from'),
        trailing: Text(clockLabel(start)),
        onTap: () => pick(isStart: true),
      ),
      ListTile(
        key: const Key('awake-end'),
        contentPadding: EdgeInsets.zero,
        title: const Text('Until'),
        trailing: Text(clockLabel(end)),
        onTap: () => pick(isStart: false),
      ),
    ]);
  }
}

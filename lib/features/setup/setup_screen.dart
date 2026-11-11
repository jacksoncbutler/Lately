import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';

const blockNames = {
  'next_time': 'Next time',
  'family': 'Their people',
  'interests': 'Interests and hobbies',
  'about': 'About',
};

const _intervalChoices = [7, 10, 14, 21, 30, 45, 60, 90, 120, 180];

/// First run: how often to talk to each group, and the default block order.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  List<GroupRow>? _groups;
  final _days = <String, int>{};
  List<String> _order = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    final groups = await repo.listGroups();
    final settings = await repo.getSettings();
    if (!mounted) return;
    setState(() {
      _groups = groups;
      for (final g in groups) {
        _days[g.id] = g.defaultIntervalDays;
      }
      _order = repo.blockOrderOf(settings).where((k) => k != 'next_time').toList();
    });
  }

  List<int> _choicesFor(int current) =>
      {..._intervalChoices, current}.toList()..sort();

  Future<void> _addGroup() async {
    final name = TextEditingController();
    var days = 30;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: const Text('Add a group'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name, such as Cousins')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: days,
              decoration: const InputDecoration(labelText: 'Talk about every'),
              items: [
                for (final d in _intervalChoices)
                  DropdownMenuItem(value: d, child: Text('$d days'))
              ],
              onChanged: (v) => set(() => days = v ?? days),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Add')),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    final repo = ref.read(repositoryProvider);
    await repo.createGroup(name.text.trim(), days, sortOrder: (_groups?.length ?? 0));
    await _load();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    for (final g in _groups!) {
      final d = _days[g.id]!;
      if (d != g.defaultIntervalDays) {
        await repo.updateGroup(g.id, GroupsCompanion(defaultIntervalDays: Value(d)));
      }
    }
    await repo.setBlockOrder(['next_time', ..._order]);
    await repo.completeSetup();
    ref.invalidate(groupsProvider);
    ref.invalidate(setupCompleteProvider);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final groups = _groups;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Lately')),
      body: groups == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('How often would you like to talk to each group?', style: t.titleMedium),
                const SizedBox(height: 4),
                Text('You can change any person later. This is just where they start.',
                    style: t.bodySmall),
                const SizedBox(height: 8),
                for (final g in groups)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(g.name),
                    trailing: DropdownButton<int>(
                      value: _days[g.id],
                      items: [
                        for (final d in _choicesFor(_days[g.id]!))
                          DropdownMenuItem(value: d, child: Text('every $d days'))
                      ],
                      onChanged: (v) => setState(() => _days[g.id] = v ?? _days[g.id]!),
                    ),
                  ),
                TextButton.icon(
                    onPressed: _addGroup,
                    icon: const Icon(Icons.add),
                    label: const Text('Add a group')),
                const SizedBox(height: 16),
                Text('What matters most on a profile?', style: t.titleMedium),
                const SizedBox(height: 4),
                Text('Drag to set the order of the blocks. Next time always comes first.',
                    style: t.bodySmall),
                const SizedBox(height: 8),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.lock_outline),
                  title: Text('Next time'),
                ),
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorderItem: (from, to) =>
                      setState(() => _order.insert(to, _order.removeAt(from))),
                  children: [
                    for (final k in _order)
                      ListTile(
                        key: ValueKey(k),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.drag_handle),
                        title: Text(blockNames[k] ?? k),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                    onPressed: _saving ? null : _finish, child: const Text('Continue')),
              ],
            ),
    );
  }
}

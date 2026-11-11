import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/chat_rules.dart';
import '../../ui/theme.dart';

/// Searchable list of people grouped like the People tab, with how long since
/// you last talked. The suggested person is tagged.
class PersonPicker extends ConsumerStatefulWidget {
  const PersonPicker({
    super.key,
    required this.suggestedId,
    required this.onPick,
    required this.onBack,
  });
  final String? suggestedId;
  final ValueChanged<String> onPick;
  final VoidCallback onBack;

  @override
  ConsumerState<PersonPicker> createState() => _PersonPickerState();
}

class _PersonPickerState extends ConsumerState<PersonPicker> {
  String _q = '';
  Map<String, DateTime?> _last = {};

  @override
  void initState() {
    super.initState();
    ref.read(repositoryProvider).lastContactByPerson().then((m) {
      if (mounted) setState(() => _last = m);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    final people = ref.watch(peopleProvider).value ?? const <PersonRow>[];
    final groups = ref.watch(groupsProvider).value ?? const <GroupRow>[];
    final now = ref.read(nowProvider)();
    final q = _q.trim().toLowerCase();
    final shown = people.where((p) => q.isEmpty || p.displayName.toLowerCase().contains(q)).toList();

    double? days(PersonRow p) {
      final d = _last[p.id];
      return d == null ? null : daysSince(d, now);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Row(children: [
          Expanded(
            child: TextField(
              key: const Key('picker-search'),
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Search people'),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          TextButton(onPressed: widget.onBack, child: const Text('Back')),
        ]),
        const SizedBox(height: 12),
        for (final g in groups)
          if (shown.any((p) => p.groupId == g.id)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Text(g.name.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
            ),
            Card(
              child: Column(children: [
                for (final p in (shown.where((x) => x.groupId == g.id).toList()
                  ..sort((a, b) => (days(b) ?? -1).compareTo(days(a) ?? -1))))
                  ListTile(
                    key: Key('pick-${p.id}'),
                    leading: CircleAvatar(
                      backgroundColor: c.accent,
                      foregroundColor: c.onAccent,
                      child: Text(p.displayName.characters.first.toUpperCase()),
                    ),
                    title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(days(p) == null
                        ? 'Not talked yet'
                        : 'Last talked ${agoText(days(p)!)}'),
                    trailing: widget.suggestedId == p.id
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                                color: c.soft, borderRadius: BorderRadius.circular(10)),
                            child: Text('Suggested',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600, color: c.muted)),
                          )
                        : null,
                    onTap: () => widget.onPick(p.id),
                  ),
              ]),
            ),
          ],
        if (shown.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No one matches that search.')),
          ),
      ],
    );
  }
}

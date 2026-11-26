import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/chat_rules.dart';
import '../../ui/card_slice.dart';
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

    // Pinned search on top, and a lazily built list: 200 people stay quick.
    final entries = <Object>[]; // String = a group header, PersonRow = a person
    final lastIndexOfGroup = <int>{};
    for (final g in groups) {
      final members = shown.where((p) => p.groupId == g.id).toList()
        ..sort((a, b) => (days(b) ?? -1).compareTo(days(a) ?? -1));
      if (members.isEmpty) continue;
      entries.add(g.name);
      entries.addAll(members);
      lastIndexOfGroup.add(entries.length - 1);
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
        child: Row(children: [
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
      ),
      Expanded(
        child: entries.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Align(
                    alignment: Alignment.topCenter, child: Text('No one matches that search.')),
              )
            : ListView.builder(
                padding: EdgeInsets.fromLTRB(18, 8, 18, 24 + MediaQuery.paddingOf(context).bottom),
                itemCount: entries.length,
                itemBuilder: (context, i) {
                  final e = entries[i];
                  if (e is String) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: Text(e.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
                    );
                  }
                  final p = e as PersonRow;
                  return CardSlice(
                    first: entries[i - 1] is String,
                    last: lastIndexOfGroup.contains(i),
                    child: ListTile(
                      key: Key('pick-${p.id}'),
                      leading: CircleAvatar(
                        backgroundColor: c.accent,
                        foregroundColor: c.onAccent,
                        child: Text(p.displayName.characters.first.toUpperCase()),
                      ),
                      title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(days(p) == null ? 'Not talked yet' : 'Last talked ${agoText(days(p)!)}'),
                      trailing: widget.suggestedId == p.id
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration:
                                  BoxDecoration(color: c.soft, borderRadius: BorderRadius.circular(10)),
                              child: Text('Suggested',
                                  style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600, color: c.muted)),
                            )
                          : null,
                      onTap: () => widget.onPick(p.id),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

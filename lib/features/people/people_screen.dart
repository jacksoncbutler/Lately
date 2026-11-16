import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../domain/chat_rules.dart';
import '../../domain/ranking.dart';
import '../../domain/timezones.dart';
import '../../ui/add_people_menu.dart';
import '../../ui/card_slice.dart';
import '../../ui/log_fab.dart';
import '../../ui/theme.dart';
import '../home/home_data.dart';
import '../profile/finish_setup_sheet.dart';
import '../profile/profile_screen.dart';

const _statusLabels = {
  PersonStatus.asleep: 'Asleep',
  PersonStatus.today: 'Talked today',
  PersonStatus.notDue: 'Not due',
  PersonStatus.snoozed: 'Paused',
  PersonStatus.retryLater: 'Try again later',
  PersonStatus.skipped: 'Skipped',
};

/// Searchable list of everyone, grouped by group, with how long since you last
/// talked and their local time. Archived people sit in a collapsed section.
class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

// What the list is made of. It is built lazily, so a long list stays quick.
sealed class _Item {}

class _Header extends _Item {
  _Header(this.text);
  final String text;
}

class _PersonItem extends _Item {
  _PersonItem(this.person, {required this.first, required this.last});
  final PersonRow person;
  final bool first, last;
}

class _ArchivedToggle extends _Item {
  _ArchivedToggle(this.count, this.open);
  final int count;
  final bool open;
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  String _query = '';
  bool _archivedOpen = false;

  @override
  Widget build(BuildContext context) {
    final people = ref.watch(peopleProvider).value ?? const <PersonRow>[];
    final archived = ref.watch(archivedPeopleProvider).value ?? const <PersonRow>[];
    final groups = ref.watch(groupsProvider).value ?? const <GroupRow>[];
    final chats = ref.watch(allChatsProvider).value ?? const <ChatRow>[];
    final settings = ref.watch(settingsProvider).value;
    final zone = ref.watch(userZoneProvider).value;
    final nowFn = ref.watch(nowProvider);
    final now = nowFn();
    final c = LatelyColors.of(context);
    final t = Theme.of(context).textTheme;

    final rows = <String, RankRow>{};
    if (settings != null && zone != null) {
      for (final r in rank(buildRankPeople(people: people, chats: chats, groups: groups), now,
          rankSettingsFrom(settings, zone))) {
        rows[r.person.id] = r;
      }
    }

    final q = _query.trim().toLowerCase();
    bool match(PersonRow p) => q.isEmpty || p.displayName.toLowerCase().contains(q);
    final shown = people.where(match).toList();
    final shownArchived = archived.where(match).toList();

    // Longest since you talked first; people still to finish go last.
    int byDays(PersonRow a, PersonRow b) {
      final ra = rows[a.id], rb = rows[b.id];
      if (ra == null && rb == null) return a.displayName.compareTo(b.displayName);
      if (ra == null) return 1;
      if (rb == null) return -1;
      return rb.days.compareTo(ra.days);
    }

    final items = <_Item>[];
    for (final g in groups) {
      final members = shown.where((p) => p.groupId == g.id).toList()..sort(byDays);
      if (members.isEmpty) continue;
      items.add(_Header('${g.name} · every ${g.defaultIntervalDays} days'));
      for (var i = 0; i < members.length; i++) {
        items.add(_PersonItem(members[i], first: i == 0, last: i == members.length - 1));
      }
    }
    if (shownArchived.isNotEmpty) {
      items.add(_ArchivedToggle(shownArchived.length, _archivedOpen));
      if (_archivedOpen) {
        for (var i = 0; i < shownArchived.length; i++) {
          items.add(_PersonItem(shownArchived[i], first: i == 0, last: i == shownArchived.length - 1));
        }
      }
    }

    Widget personTile(PersonRow p) {
      final isArchived = p.archivedAt != null;
      final r = rows[p.id];
      final unfinished = needsFinishing(p) && !isArchived;
      final sub = isArchived
          ? 'Archived'
          : unfinished
              ? 'Finish setup to get suggestions'
              : '${r == null ? '' : 'Last talked ${agoText(r.days)} · '}${clockText(p.timezone, now)} there';
      final status = (r == null || unfinished || isArchived) ? null : _statusLabels[r.status];
      return ListTile(
        key: Key('person-${p.id}'),
        leading: CircleAvatar(
          backgroundColor: isArchived ? c.soft : c.accent,
          foregroundColor: isArchived ? c.muted : c.onAccent,
          child: Text(p.displayName.characters.first.toUpperCase()),
        ),
        title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(sub),
        trailing: unfinished
            ? const Chip(label: Text('Finish setup'), visualDensity: VisualDensity.compact)
            : (status == null ? (isArchived ? null : const Icon(Icons.chevron_right)) : _Tag(status)),
        onTap: () => _open(context, p),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('People',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        actions: const [AddPeopleMenu()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: people.isEmpty ? null : const LogFab(),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
          child: TextField(
            key: const Key('people-search'),
            decoration: const InputDecoration(
              hintText: 'Search people',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(people.isEmpty && archived.isEmpty
                        ? 'No one yet. Tap + to add people.'
                        : 'No one matches that search.'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    switch (it) {
                      case _Header():
                        return Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 6),
                          child: Text(it.text.toUpperCase(),
                              style: t.labelSmall
                                  ?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
                        );
                      case _PersonItem():
                        return CardSlice(first: it.first, last: it.last, child: personTile(it.person));
                      case _ArchivedToggle():
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              key: const Key('archived-section'),
                              style: TextButton.styleFrom(foregroundColor: c.muted),
                              onPressed: () => setState(() => _archivedOpen = !_archivedOpen),
                              icon: Icon(it.open ? Icons.expand_less : Icons.expand_more),
                              label: Text('Archived (${it.count})'),
                              iconAlignment: IconAlignment.end,
                            ),
                          ),
                        );
                    }
                  },
                ),
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
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = LatelyColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(color: c.soft, borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.muted)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../domain/chat_rules.dart';
import '../../domain/ranking.dart';
import '../../domain/timezones.dart';
import '../../ui/add_people_menu.dart';
import '../../ui/log_fab.dart';
import '../../ui/theme.dart';
import '../home/home_data.dart';
import '../profile/finish_setup_sheet.dart';
import '../profile/profile_screen.dart';

const _statusLabels = {
  PersonStatus.asleep: 'Asleep',
  PersonStatus.today: 'Talked today',
  PersonStatus.notDue: 'Not due',
  PersonStatus.snoozed: 'Snoozed',
  PersonStatus.skipped: 'Skipped',
};

/// Searchable list of everyone, grouped by group, with how long since you last
/// talked and their local time. Archived people sit in a collapsed section.
class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  String _query = '';

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

    Widget tile(PersonRow p) {
      final r = rows[p.id];
      final unfinished = needsFinishing(p);
      final sub = unfinished
          ? 'Finish setup to get suggestions'
          : '${r == null ? '' : 'Last talked ${agoText(r.days)} · '}${clockText(p.timezone, now)} there';
      final status = (r == null || unfinished) ? null : _statusLabels[r.status];
      return ListTile(
        key: Key('person-${p.id}'),
        leading: CircleAvatar(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          child: Text(p.displayName.characters.first.toUpperCase()),
        ),
        title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(sub),
        trailing: unfinished
            ? const Chip(label: Text('Finish setup'), visualDensity: VisualDensity.compact)
            : (status == null ? null : _Tag(status)),
        onTap: () => _open(context, p),
      );
    }

    // Longest since you talked first; people still to finish go last.
    int byDays(PersonRow a, PersonRow b) {
      final ra = rows[a.id], rb = rows[b.id];
      if (ra == null && rb == null) return a.displayName.compareTo(b.displayName);
      if (ra == null) return 1;
      if (rb == null) return -1;
      return rb.days.compareTo(ra.days);
    }

    final sections = <Widget>[];
    for (final g in groups) {
      final members = shown.where((p) => p.groupId == g.id).toList()..sort(byDays);
      if (members.isEmpty) continue;
      sections.add(Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text('${g.name} · every ${g.defaultIntervalDays} days'.toUpperCase(),
            style: t.labelSmall?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
      ));
      sections.add(Card(
        child: Column(children: [
          for (var i = 0; i < members.length; i++) ...[
            if (i > 0) const Divider(),
            tile(members[i]),
          ],
        ]),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('People',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        actions: const [AddPeopleMenu()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: people.isEmpty ? null : const LogFab(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 110),
        children: [
          TextField(
            key: const Key('people-search'),
            decoration: const InputDecoration(
              hintText: 'Search people',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          if (people.isEmpty && archived.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: Text('No one yet. Tap + to add people.')),
            )
          else if (shown.isEmpty && shownArchived.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: Text('No one matches that search.')),
            ),
          ...sections,
          if (shownArchived.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: const Key('archived-section'),
                  tilePadding: EdgeInsets.zero,
                  title: Text('Archived (${shownArchived.length})',
                      style: TextStyle(color: c.muted, fontWeight: FontWeight.w600)),
                  children: [
                    Card(
                      child: Column(children: [
                        for (final p in shownArchived)
                          ListTile(
                            key: Key('person-${p.id}'),
                            leading: CircleAvatar(
                              backgroundColor: c.soft,
                              foregroundColor: c.muted,
                              child: Text(p.displayName.characters.first.toUpperCase()),
                            ),
                            title: Text(p.displayName,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Archived'),
                            onTap: () => _open(context, p),
                          ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
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

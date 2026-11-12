import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repository.dart';
import '../../domain/chat_rules.dart';
import '../../domain/constants.dart';
import '../../domain/profile_format.dart';
import '../../domain/ranking.dart';
import '../../domain/timezones.dart';
import '../../ui/log_fab.dart';
import '../../ui/swipe_line.dart';
import '../../ui/theme.dart';
import '../log/log_sheet.dart';
import '../people/add_person_screen.dart';
import '../people/bulk_add_screen.dart';
import '../people/people_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/reach_sheet.dart';
import '../settings/settings_screen.dart';
import '../setup/setup_screen.dart';
import 'home_data.dart';

/// Home: one person to talk to, a time-available preference, and what is
/// coming up. No notifications, no badges, no overdue counters.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  Timer? _timer;
  TimeChip _chip = TimeChip.any;

  // The person shown last time, to tell you when Home moves on by itself.
  String? _shownId;
  bool _acted = false;

  // The contact time of a "Did you get to talk to them?" prompt answered "Not yet".
  DateTime? _dismissedFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Re-evaluate every minute while the app is open.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ...and whenever the app returns to the foreground.
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  Repository get repo => ref.read(repositoryProvider);

  @override
  Widget build(BuildContext context) {
    final setup = ref.watch(setupCompleteProvider);
    if (setup.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (setup.value == false) return const SetupScreen();

    final people = ref.watch(peopleProvider).value;
    final chats = ref.watch(allChatsProvider).value;
    final groups = ref.watch(groupsProvider).value;
    final settings = ref.watch(settingsProvider).value;
    final zone = ref.watch(userZoneProvider).value;
    final rels = ref.watch(allRelationshipsProvider).value ?? const <RelationshipRow>[];
    final dates = ref.watch(allImportantDatesProvider).value ?? const <ImportantDateRow>[];

    final ready = people != null && chats != null && groups != null && settings != null && zone != null;
    final now = ref.read(nowProvider)();

    PersonRow? reached;
    if (ready &&
        recentContactIsFresh(settings.recentContactAt, now) &&
        settings.recentContactAt != _dismissedFor) {
      reached = people.where((p) => p.id == settings.recentContactPersonId).firstOrNull;
    }

    List<RankRow> rows = const [];
    HeroPick hero = const HeroPick();
    RankSettings rs = const RankSettings(userZone: 'UTC');
    if (ready) {
      rs = rankSettingsFrom(settings, zone);
      rows = rank(buildRankPeople(people: people, chats: chats, groups: groups), now, rs);
      hero = pickHero(rows, _chip);
      final newId = hero.row?.person.id;
      final previous = _shownId;
      if (newId != previous) {
        final prevRow = rows.where((r) => r.person.id == previous).firstOrNull;
        final announce = previous != null && newId != null && !_acted;
        final newName = hero.row?.person.name;
        final prevName = prevRow?.person.name ?? '';
        final wasAsleep = prevRow?.status == PersonStatus.asleep;
        _acted = false;
        _shownId = newId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(suggestedPersonProvider.notifier).set(newId);
          if (announce && newName != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(wasAsleep
                  ? '$prevName is outside their awake hours, so Home moved on to $newName.'
                  : 'Home moved on to $newName.'),
            ));
          }
        });
      }
    }

    final unfinished = ready ? people.where(needsFinishing).length : 0;
    final upcomingDates = ready
        ? upcoming(
            buildDateSources(people: people, relationships: rels, importantDates: dates),
            now,
            zone,
            Tune.homeDatesDays,
          )
        : const <UpcomingDate>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Up next',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (people == null || people.isEmpty) ? null : const LogFab(),
      body: !ready
          ? const Center(child: CircularProgressIndicator())
          : people.isEmpty
              ? _welcome(context)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
                  children: [
                    if (reached != null) _reachPrompt(reached, settings.recentContactAt),
                    if (hero.row != null)
                      _HeroCard(
                        key: const Key('hero-card'),
                        row: hero.row!,
                        group: groups
                            .where((g) => g.id == people.firstWhere((p) => p.id == hero.row!.person.id).groupId)
                            .firstOrNull,
                        now: now,
                        onOpen: () => _openProfile(hero.row!.person.id),
                        onContact: () {
                          _acted = true;
                          final p = people.firstWhere((p) => p.id == hero.row!.person.id);
                          showReachSheet(context, p);
                        },
                        onLog: () {
                          _acted = true;
                          showLogSheet(context, personId: hero.row!.person.id);
                        },
                        onSkip: () => _skip(hero.row!.person, zone, now),
                        onSnooze: () => _snooze(hero.row!.person, now),
                      )
                    else
                      _CaughtUpCard(
                        rows: rows,
                        settings: rs,
                        now: now,
                        onBrowse: _browse,
                      ),
                    if (hero.note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(hero.note,
                            key: const Key('hero-note'),
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    if (unfinished > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextButton(
                          key: const Key('unfinished-note'),
                          style: TextButton.styleFrom(
                              foregroundColor: LatelyColors.of(context).muted,
                              alignment: Alignment.centerLeft),
                          onPressed: _browse,
                          child: Text(unfinished == 1
                              ? '1 person still needs their setup finished'
                              : '$unfinished people still need their setup finished'),
                        ),
                      ),
                    _eyebrow(context, 'How much time do you have?'),
                    _TimeSlider(
                      chip: _chip,
                      onChanged: (c) => setState(() {
                        _acted = true;
                        _chip = c;
                                      }),
                    ),
                    _eyebrow(context, 'Coming up'),
                    if (upcomingDates.isEmpty)
                      Text('Nothing in the next two weeks.',
                          style: Theme.of(context).textTheme.bodySmall)
                    else
                      Card(
                        key: const Key('dates-strip'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(children: [
                            for (var i = 0; i < upcomingDates.take(3).length; i++)
                              Container(
                                constraints: const BoxConstraints(minHeight: 48),
                                decoration: i == 0
                                    ? null
                                    : BoxDecoration(
                                        border: Border(
                                            top: BorderSide(color: LatelyColors.of(context).line))),
                                child: Row(children: [
                                  Expanded(child: Text(upcomingDates[i].label)),
                                  Text(
                                    upcomingDates[i].days == 0
                                        ? 'Today'
                                        : weekdayDate(upcomingDates[i].date),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ]),
                              ),
                          ]),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const Key('browse-everyone'),
                        onPressed: _browse,
                        child: const Text('Browse everyone'),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _eyebrow(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 6),
        child: Text(text.toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
      );

  void _browse() => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const PeopleScreen()));

  void _openProfile(String id) => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ProfileScreen(personId: id, backLabel: 'Home')));

  Future<void> _skip(RankPerson p, String zone, DateTime now) async {
    _acted = true;
    await repo.skipUntil(p.id, nextLocalMidnight(zone, now));
    if (mounted) {
      showUndoBar(context, 'Skipped until tomorrow', () => repo.clearSkip(p.id));
    }
  }

  Future<void> _snooze(RankPerson p, DateTime now) async {
    _acted = true;
    await repo.snoozeUntil(p.id, now.add(const Duration(days: Tune.snoozeDays)));
    if (mounted) {
      showUndoBar(context, '${p.name} snoozed for ${Tune.snoozeDays} days',
          () => repo.clearSnooze(p.id));
    }
  }

  Widget _reachPrompt(PersonRow reached, DateTime? contactAt) => Card(
        key: const Key('reach-prompt'),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Did you get to talk to ${reached.displayName}?',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    _acted = true;
                    showLogSheet(context, personId: reached.id);
                  },
                  child: const Text('Log it'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  // The log popup still defaults to them for a few hours.
                  onPressed: () => setState(() => _dismissedFor = contactAt),
                  child: const Text('Not yet'),
                ),
              ),
            ]),
          ]),
        ),
      );

  Widget _welcome(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Who would you like to stay close to?',
                  style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Start with a few people. You can fill in the rest as you go.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AddPersonScreen())),
                child: const Text('Add someone'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const BulkAddScreen())),
                child: const Text('Add from contacts'),
              ),
            ],
          ),
        ),
      );
}

class _HeroCard extends ConsumerWidget {
  const _HeroCard({
    super.key,
    required this.row,
    required this.group,
    required this.now,
    required this.onOpen,
    required this.onContact,
    required this.onLog,
    required this.onSkip,
    required this.onSnooze,
  });
  final RankRow row;
  final GroupRow? group;
  final DateTime now;
  final VoidCallback onOpen, onContact, onLog, onSkip, onSnooze;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = LatelyColors.of(context);
    final t = Theme.of(context).textTheme;
    final p = row.person;
    final lines = (ref.watch(linesProvider(p.id)).value ?? const <LineRow>[])
        .where((l) => l.block == 'next_time' && l.chatId == null && l.deletedAt == null)
        .toList();
    final repo = ref.read(repositoryProvider);
    final muted = TextButton.styleFrom(foregroundColor: c.muted, textStyle: const TextStyle(fontWeight: FontWeight.w500));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: c.accent,
              foregroundColor: c.onAccent,
              child: Text(p.name.characters.first.toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
                  InkWell(
                    key: const Key('hero-name'),
                    onTap: onOpen,
                    child: Text(p.name,
                        style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  if (group != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration:
                          BoxDecoration(color: c.soft, borderRadius: BorderRadius.circular(10)),
                      child: Text(group!.name,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: c.muted)),
                    ),
                ]),
                Text('${clockText(p.zone, now)} there, likely free',
                    key: const Key('hero-clock'), style: t.bodySmall),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Text(whyLine(row), key: const Key('hero-why'), style: const TextStyle(fontWeight: FontWeight.w500)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Text('NEXT TIME',
              style: t.labelSmall?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          if (lines.isEmpty)
            Text('Nothing saved yet. Add things to ask or mention on their profile.',
                style: t.bodySmall)
          else
            for (final l in lines.take(3))
              CheckboxListTile(
                key: Key('hero-line-${l.id}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: l.done,
                onChanged: (_) => repo.setLineDone(l.id, !l.done),
                title: Text(l.lineText,
                    style: TextStyle(
                        decoration: l.done ? TextDecoration.lineThrough : null,
                        color: l.done ? c.muted : null)),
              ),
          if (lines.length > 3)
            Text('+ ${lines.length - 3} more on their profile', style: t.bodySmall),
          const SizedBox(height: 14),
          FilledButton(key: const Key('hero-contact'), onPressed: onContact, child: const Text('Contact')),
          const SizedBox(height: 8),
          OutlinedButton(key: const Key('hero-log'), onPressed: onLog, child: const Text('Log')),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(key: const Key('hero-skip'), style: muted, onPressed: onSkip, child: const Text('Not today')),
            Text('·', style: TextStyle(color: c.muted)),
            TextButton(
                key: const Key('hero-snooze'),
                style: muted,
                onPressed: onSnooze,
                child: Text('Snooze ${Tune.snoozeDays} days')),
          ]),
        ]),
      ),
    );
  }
}

class _CaughtUpCard extends StatelessWidget {
  const _CaughtUpCard({
    required this.rows,
    required this.settings,
    required this.now,
    required this.onBrowse,
  });
  final List<RankRow> rows;
  final RankSettings settings;
  final DateTime now;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final asleep = rows.where((r) => r.status == PersonStatus.asleep).toList()
      ..sort((a, b) => wakeInMinutes(a.person, now, settings)
          .compareTo(wakeInMinutes(b.person, now, settings)));
    final calm = rows.any((r) => r.status == PersonStatus.notDue || r.status == PersonStatus.today);

    final String title;
    final String body;
    if (asleep.isNotEmpty) {
      title = 'Nobody is free right now';
      body =
          '${asleep.first.person.name} wakes in ${aboutDuration(wakeInMinutes(asleep.first.person, now, settings))}.';
    } else if (calm) {
      title = "You're caught up";
      body = 'Nobody is due right now. Enjoy the quiet, or browse everyone.';
    } else {
      title = 'Nobody to suggest';
      body = 'Everyone is snoozed or skipped for today.';
    }
    return Card(
      key: const Key('caught-up-card'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('UP NEXT',
              style: t.labelSmall?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(title, key: const Key('caught-up-title'), style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, key: const Key('caught-up-body'), style: t.bodyMedium),
          TextButton(onPressed: onBrowse, child: const Text('Browse everyone')),
        ]),
      ),
    );
  }
}

class _TimeSlider extends StatelessWidget {
  const _TimeSlider({required this.chip, required this.onChanged});
  final TimeChip chip;
  final ValueChanged<TimeChip> onChanged;

  static const _labels = ['Any', '15', '30', '60+'];
  static const _spoken = [
    'Any amount of time',
    'About 15 minutes',
    'About 30 minutes',
    'An hour or more',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Semantics(
        label: 'Time available',
        value: _spoken[chip.index],
        child: Slider(
          key: const Key('time-slider'),
          min: 0,
          max: 3,
          divisions: 3,
          value: chip.index.toDouble(),
          onChanged: (v) => onChanged(TimeChip.values[v.round()]),
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (var i = 0; i < 4; i++)
          TextButton(
            key: Key('chip-${_labels[i]}'),
            onPressed: () => onChanged(TimeChip.values[i]),
            style: TextButton.styleFrom(
              foregroundColor: chip.index == i
                  ? Theme.of(context).colorScheme.onSurface
                  : LatelyColors.of(context).muted,
              textStyle: TextStyle(
                  fontWeight: chip.index == i ? FontWeight.w700 : FontWeight.w500),
            ),
            child: Text(_labels[i]),
          ),
      ]),
    ]);
  }
}

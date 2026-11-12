import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/chat_rules.dart';
import '../../domain/profile_format.dart';
import '../profile/profile_blocks.dart';
import 'person_picker.dart';

/// Opens the log popup over the current screen. [personId] is whoever's Log
/// button was tapped; without it the popup starts on the person you just
/// tapped Contact for (for a few hours), else the most overdue person.
Future<void> showLogSheet(BuildContext context, {String? personId}) async {
  final container = ProviderScope.containerOf(context);
  final repo = container.read(repositoryProvider);
  final now = container.read(nowProvider)();
  var id = personId;
  if (id == null) {
    final people = await repo.listPeople();
    final last = await repo.lastContactByPerson();
    final s = await repo.getSettings();
    final candidates = <LogCandidate>[];
    for (final p in people) {
      final lc = last[p.id];
      candidates.add(LogCandidate(p.id,
          name: p.displayName,
          daysSinceContact: lc == null ? 180 : daysSince(lc, now),
          intervalDays: await repo.intervalDaysFor(p)));
    }
    id = defaultLogPersonId(
      candidates: candidates,
      recentContactPersonId: s.recentContactPersonId,
      recentContactAt: s.recentContactAt,
      suggestedPersonId: container.read(suggestedPersonProvider),
      now: now,
    );
  }
  if (id == null || !context.mounted) return;
  final suggested = container.read(suggestedPersonProvider) ?? id;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.94,
      child: LogSheet(initialPersonId: id!, suggestedPersonId: suggested),
    ),
  );
}

class LogSheet extends ConsumerStatefulWidget {
  const LogSheet({super.key, required this.initialPersonId, String? suggestedPersonId})
      : suggestedPersonId = suggestedPersonId ?? initialPersonId;
  final String initialPersonId;

  /// Tagged "Suggested" in the person list: who Home is showing.
  final String suggestedPersonId;

  @override
  ConsumerState<LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends ConsumerState<LogSheet> {
  late String _personId = widget.initialPersonId;
  bool _picking = false;
  ChatWhen _when = ChatWhen.now;
  DateTime? _date;
  String? _type;
  String? _depth;
  double _minutes = 30;
  final _feelings = <String>{};
  // null = every offered Next time item is ticked.
  Set<String>? _coveredOverride;
  final _addedLines = <String>[];
  final _addedRels = <String>[];
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _ready => _type != null && _depth != null && (_when != ChatWhen.otherDay || _date != null);

  void _choosePerson(String id) => setState(() {
        _personId = id;
        _coveredOverride = null;
        _addedLines.clear();
        _addedRels.clear();
        _picking = false;
      });

  Future<void> _pickDate() async {
    final now = ref.read(nowProvider)();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year, now.month, now.day), // never in the future
      // Pick from the calendar; no typing dates with slashes.
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Which day?',
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save(PersonRow person, List<LineRow> offers) async {
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    final now = ref.read(nowProvider)();
    final when = chatTime(_when, now, date: _date);
    final covered = (_coveredOverride ?? {for (final l in offers) l.id})
        .where((id) => offers.any((l) => l.id == id))
        .toList();
    await repo.logChat(
      personId: person.id,
      occurredAt: when.occurredAt,
      timeApproximate: when.approximate,
      type: _type!,
      depth: _depth!,
      durationMinutes: _minutes.round(),
      feelings: _feelings.toList(),
      note: _note.text,
      coveredLineIds: covered,
      addedLineIds: _addedLines,
      addedRelationshipIds: _addedRels,
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
        SnackBar(content: Text("Logged. ${person.displayName}'s clock is reset.")));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final person = ref.watch(personProvider(_personId)).value;
    if (person == null) return const Center(child: CircularProgressIndicator());

    if (_picking) {
      return Column(children: [
        _header(context, 'Who did you talk to?'),
        Expanded(
          child: PersonPicker(
            suggestedId: widget.suggestedPersonId,
            onPick: _choosePerson,
            onBack: () => setState(() => _picking = false),
          ),
        ),
      ]);
    }

    final now = ref.read(nowProvider)();
    final lines = ref.watch(linesProvider(person.id)).value ?? const <LineRow>[];
    final offers = [
      for (final l in lines)
        if (l.block == 'next_time' && l.done && l.chatId == null) l,
    ];
    final covered = _coveredOverride ?? {for (final l in offers) l.id};

    String? stampNote() {
      if (_when == ChatWhen.now || !_ready) return null;
      final w = chatTime(_when, now, date: _date);
      return 'Saved as ${shortDate(w.occurredAt, now)}';
    }

    Widget label(String s) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(s.toUpperCase(),
              style: t.labelSmall?.copyWith(letterSpacing: 0.9, fontWeight: FontWeight.w600)),
        );

    return Column(children: [
      _header(context, 'Log a chat'),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          children: [
            _personRow(person, context),
            label('When'),
            SegmentedButton<ChatWhen>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ChatWhen.now, label: Text('Just now')),
                ButtonSegment(value: ChatWhen.yesterday, label: Text('Yesterday')),
                ButtonSegment(value: ChatWhen.otherDay, label: Text('Other day')),
              ],
              selected: {_when},
              onSelectionChanged: (s) => setState(() => _when = s.first),
            ),
            if (_when == ChatWhen.otherDay)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  key: const Key('log-pick-date'),
                  onPressed: _pickDate,
                  child: Text(_date == null ? 'Pick the day' : shortDate(_date!, now)),
                ),
              ),
            if (stampNote() != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(stampNote()!, style: t.bodySmall),
              ),
            label('Type'),
            SegmentedButton<String>(
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'person', label: Text('In person')),
                ButtonSegment(value: 'call', label: Text('Call')),
                ButtonSegment(value: 'text', label: Text('Text')),
              ],
              selected: {?_type},
              onSelectionChanged: (s) => setState(() => _type = s.isEmpty ? null : s.first),
            ),
            label('How long'),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('1 min', style: t.bodySmall),
              Text(_minutes.round() >= 60 ? '60+ min' : '${_minutes.round()} min',
                  key: const Key('log-minutes'),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('60+', style: t.bodySmall),
            ]),
            Slider(
              key: const Key('log-slider'),
              min: 1,
              max: 60,
              divisions: 59,
              value: _minutes,
              onChanged: (v) => setState(() => _minutes = v),
            ),
            label('How deep'),
            SegmentedButton<String>(
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'shallow', label: Text('Shallow')),
                ButtonSegment(value: 'varied', label: Text('Varied')),
                ButtonSegment(value: 'deep', label: Text('Deep')),
              ],
              selected: {?_depth},
              onSelectionChanged: (s) => setState(() => _depth = s.isEmpty ? null : s.first),
            ),
            label('How they were feeling (optional)'),
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final f in feelingOptions)
                FilterChip(
                  label: Text(f),
                  selected: _feelings.contains(f),
                  showCheckmark: false,
                  onSelected: (v) => setState(() => v ? _feelings.add(f) : _feelings.remove(f)),
                ),
            ]),
            if (offers.isNotEmpty) ...[
              label('Covered from Next time'),
              for (final l in offers)
                CheckboxListTile(
                  key: Key('cover-${l.id}'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l.lineText),
                  value: covered.contains(l.id),
                  onChanged: (v) => setState(() {
                    final next = {...covered};
                    v == true ? next.add(l.id) : next.remove(l.id);
                    _coveredOverride = next;
                  }),
                ),
            ],
            label('What was it about? (optional)'),
            TextField(
              key: const Key('log-note'),
              controller: _note,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'What you talked about or did'),
            ),
            label('Their profile'),
            Text('Add, edit or remove anything you learned. Changes save right away.',
                style: t.bodySmall),
            const SizedBox(height: 8),
            ProfileBlocks(
              key: ValueKey('blocks-${person.id}'),
              personId: person.id,
              allowAddSection: false,
              onLineAdded: _addedLines.add,
              onRelationshipAdded: _addedRels.add,
            ),
          ],
        ),
      ),
      const Divider(),
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              _ready
                  ? "Saving resets ${person.displayName}'s contact clock"
                  : (_when == ChatWhen.otherDay && _date == null
                      ? 'Pick the day, a type and a depth to save'
                      : 'Pick a type and a depth to save'),
              style: t.bodySmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('log-save'),
                onPressed: _ready && !_saving ? () => _save(person, offers) : null,
                child: const Text('Save chat'),
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  Widget _header(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 8, 4),
        child: Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close)),
        ]),
      );

  Widget _personRow(PersonRow person, BuildContext context) {
    final repo = ref.read(repositoryProvider);
    final now = ref.read(nowProvider)();
    return FutureBuilder<DateTime?>(
      future: repo.lastContactOf(person),
      builder: (context, snap) {
        final lc = snap.data;
        return Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: Text(person.displayName.characters.first.toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(person.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(lc == null ? '' : 'Last talked ${agoText(daysSince(lc, now))}',
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
          TextButton(
            key: const Key('log-change'),
            onPressed: () => setState(() => _picking = true),
            child: const Text('Change'),
          ),
        ]);
      },
    );
  }
}

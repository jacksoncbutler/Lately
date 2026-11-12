import 'dart:convert';

import '../../data/database.dart';
import '../../data/repository.dart';
import '../../domain/constants.dart';
import '../../domain/ranking.dart';

/// Turns stored rows into the pure inputs the ranking rules use. People who
/// have not finished setup (bulk-added, timezone and last talked not yet
/// confirmed) are left out of suggestions: their awake window would be a guess.
List<RankPerson> buildRankPeople({
  required List<PersonRow> people,
  required List<ChatRow> chats,
  required List<GroupRow> groups,
}) {
  final groupDays = {for (final g in groups) g.id: g.defaultIntervalDays};
  final byPerson = <String, List<RankChat>>{};
  for (final c in chats) {
    byPerson.putIfAbsent(c.personId, () => []).add(RankChat(
          at: c.occurredAt,
          minutes: c.durationMinutes,
          length: c.length,
        ));
  }
  return [
    for (final p in people)
      if (!needsFinishing(p))
        RankPerson(
          id: p.id,
          name: p.displayName,
          zone: p.timezone,
          intervalDays: p.intervalOverrideDays ?? groupDays[p.groupId] ?? 30,
          weight: Tune.defaultGroupWeight,
          archived: p.archivedAt != null,
          snoozedUntil: p.snoozedUntil,
          skippedUntil: p.skippedUntil,
          lastTalkedEstimate: p.lastTalkedEstimate,
          chats: byPerson[p.id] ?? const [],
        ),
  ];
}

List<DateSource> buildDateSources({
  required List<PersonRow> people,
  required List<RelationshipRow> relationships,
  required List<ImportantDateRow> importantDates,
}) {
  return [
    for (final p in people)
      DateSource(
        personId: p.id,
        name: p.displayName,
        birthday: p.birthday,
        archived: p.archivedAt != null,
        relationships: [
          for (final r in relationships)
            if (r.personId == p.id) (name: r.name, relation: r.relation, birthday: r.birthday),
        ],
        importantDates: [
          for (final d in importantDates)
            if (d.personId == p.id) (label: d.label, date: d.date, repeatsYearly: d.repeatsYearly),
        ],
      ),
  ];
}

/// "08:00" to minutes since midnight; falls back to [fallback] if malformed.
int parseClockMinutes(String s, int fallback) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s);
  if (m == null) return fallback;
  final h = int.parse(m.group(1)!);
  final min = int.parse(m.group(2)!);
  if (h > 24 || min > 59) return fallback;
  return h * 60 + min;
}

RankSettings rankSettingsFrom(AppSettings s, String userZone) => RankSettings(
      userZone: userZone,
      awakeStartMinutes: parseClockMinutes(s.awakeStart, Tune.awakeStartHour * 60),
      awakeEndMinutes: parseClockMinutes(s.awakeEnd, Tune.awakeEndHour * 60),
    );

List<String> decodeFeelings(String? json) =>
    json == null ? const [] : (jsonDecode(json) as List).cast<String>();

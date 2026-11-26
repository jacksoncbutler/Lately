import 'constants.dart';
import 'ranking.dart';
import 'timezones.dart';

/// What the People list shows first. Priority only orders the list; the group
/// is a true filter. All in memory, nothing is saved.
class PeopleFilter {
  const PeopleFilter({this.awakeFirst = false, this.dueFirst = false, this.groupId});
  final bool awakeFirst;
  final bool dueFirst;
  final String? groupId;

  bool get isActive => awakeFirst || dueFirst || groupId != null;
  bool get prioritised => awakeFirst || dueFirst;

  PeopleFilter copyWith({bool? awakeFirst, bool? dueFirst, String? groupId, bool clearGroup = false}) =>
      PeopleFilter(
        awakeFirst: awakeFirst ?? this.awakeFirst,
        dueFirst: dueFirst ?? this.dueFirst,
        groupId: clearGroup ? null : (groupId ?? this.groupId),
      );
}

/// Awake in their own timezone, computed from the clock rather than the status
/// (a person who is paused or skipped can still be awake).
bool isAwakeNow(String zone, DateTime now, RankSettings s) {
  final m = minutesOfDay(zone, now);
  return m >= s.awakeStartMinutes && m < s.awakeEndMinutes;
}

/// Past the due floor, or someone you tried and want to reach.
bool isDue(RankRow r) => r.ratio >= Tune.dueFloor || r.boosted;

/// The heading for a person under the given priorities, or null when no
/// priority is on. With both on, awake comes before due.
String? prioritySection(PeopleFilter f, {required bool awake, required bool due}) {
  if (f.awakeFirst && f.dueFirst) {
    return awake ? (due ? 'Awake and due' : 'Awake, not due') : (due ? 'Asleep and due' : 'Asleep, not due');
  }
  if (f.awakeFirst) return awake ? 'Awake now' : 'Asleep';
  if (f.dueFirst) return due ? 'Due' : 'Not due';
  return null;
}

/// Section order for a filter, matching [prioritySection].
List<String> prioritySections(PeopleFilter f) {
  if (f.awakeFirst && f.dueFirst) {
    return const ['Awake and due', 'Awake, not due', 'Asleep and due', 'Asleep, not due'];
  }
  if (f.awakeFirst) return const ['Awake now', 'Asleep'];
  if (f.dueFirst) return const ['Due', 'Not due'];
  return const [];
}

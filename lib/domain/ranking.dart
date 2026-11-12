import 'constants.dart';
import 'timezones.dart';

/// Who to talk to next. Ported from reference/logic.js; keep the tests.
/// Pure Dart: no Flutter, no storage. All tunable numbers are in constants.dart.

const _dayMs = 86400000;

class RankChat {
  const RankChat({required this.at, this.minutes, required this.length});
  final DateTime at;

  /// The duration entered when logging, if any.
  final int? minutes;

  /// quick | catchup | long (used when no duration was entered).
  final String length;
}

class RankPerson {
  const RankPerson({
    required this.id,
    required this.name,
    required this.zone,
    required this.intervalDays,
    this.weight = Tune.defaultGroupWeight,
    this.archived = false,
    this.snoozedUntil,
    this.skippedUntil,
    this.lastTalkedEstimate,
    this.chats = const [],
  });
  final String id;
  final String name;
  final String zone;
  final int intervalDays;
  final double weight;
  final bool archived;
  final DateTime? snoozedUntil;
  final DateTime? skippedUntil;
  final DateTime? lastTalkedEstimate;
  final List<RankChat> chats;
}

enum PersonStatus { ok, asleep, today, notDue, skipped, snoozed, archived }

class RankSettings {
  const RankSettings({
    required this.userZone,
    this.awakeStartMinutes = Tune.awakeStartHour * 60,
    this.awakeEndMinutes = Tune.awakeEndHour * 60,
  });

  /// The zone "today" and "midnight" are measured in: this phone's.
  final String userZone;
  final int awakeStartMinutes;
  final int awakeEndMinutes;
}

class RankRow {
  const RankRow({
    required this.person,
    required this.days,
    required this.ratio,
    required this.score,
    required this.status,
    required this.expectedMinutes,
    required this.sure,
    required this.hasHistory,
    required this.skipEligible,
  });
  final RankPerson person;

  /// Days since last contact (newest chat, else the estimate).
  final double days;
  final double ratio;

  /// ratio times the group weight.
  final double score;
  final PersonStatus status;
  final int expectedMinutes;
  final bool sure;
  final bool hasHistory;

  /// Skipped today but otherwise someone who could be shown.
  final bool skipEligible;

  int get interval => person.intervalDays;
}

DateTime? lastChatAt(RankPerson p) {
  DateTime? m;
  for (final c in p.chats) {
    if (m == null || c.at.isAfter(m)) m = c.at;
  }
  return m;
}

DateTime lastContact(RankPerson p, DateTime now) =>
    lastChatAt(p) ??
    p.lastTalkedEstimate ??
    now.subtract(const Duration(days: Tune.defaultLastTalkedDays));

int chatMinutes(RankChat c) {
  if (c.minutes != null && c.minutes! > 0) return c.minutes!;
  return Tune.lengthMinutes[c.length] ?? 30;
}

/// Expected length of a chat in minutes. The average of the last five chats
/// (30 with none), scaled up smoothly when you are well past the interval, with
/// less scaling when there is more history to trust.
({int minutes, bool sure}) expectedInfo(List<RankChat> chats, double? ratio) {
  final n = chats.length;
  double base = 30;
  if (n > 0) {
    final last = [...chats]..sort((a, b) => b.at.compareTo(a.at));
    final take = last.take(Tune.lastN).toList();
    base = take.fold<double>(0, (s, c) => s + chatMinutes(c)) / take.length;
  }
  final r = ratio ?? 1;
  double boost = 1;
  if (r > 1) {
    final span = (Tune.gapRatio - 1) < 0.5 ? 0.5 : (Tune.gapRatio - 1);
    boost = 1 + (Tune.gapBoost - 1) * ((r - 1) / span).clamp(0.0, 1.0);
  }
  final trust = (n / (Tune.trustChats < 1 ? 1 : Tune.trustChats)).clamp(0.0, 1.0);
  final f = 1 + (boost - 1) * (1 - Tune.historyDamp * trust);
  final rounded = ((base * f) / 5).round() * 5;
  final m = rounded.clamp(5, Tune.expCap);
  return (minutes: m, sure: n >= 3 && f < 1.15);
}

PersonStatus _status(RankPerson p, DateTime now, RankSettings s, {required bool ignoreSkip}) {
  if (p.archived) return PersonStatus.archived;
  if (p.snoozedUntil != null && p.snoozedUntil!.isAfter(now)) return PersonStatus.snoozed;
  if (!ignoreSkip && p.skippedUntil != null && p.skippedUntil!.isAfter(now)) {
    return PersonStatus.skipped;
  }
  final lc = lastChatAt(p);
  if (lc != null && calendarDate(s.userZone, lc) == calendarDate(s.userZone, now)) {
    return PersonStatus.today; // same calendar day in your timezone, not 24 hours
  }
  final mins = minutesOfDay(p.zone, now);
  if (mins < s.awakeStartMinutes || mins >= s.awakeEndMinutes) return PersonStatus.asleep;
  return PersonStatus.ok;
}

/// Every active person with their status, best first. Order: eligible people
/// before everyone else, then the highest score (overdue ratio times group
/// weight), then the longest since contact, then A to Z.
List<RankRow> rank(List<RankPerson> people, DateTime now, RankSettings s) {
  final rows = <RankRow>[];
  for (final p in people.where((p) => !p.archived)) {
    final last = lastContact(p, now);
    final days = (now.difference(last).inMilliseconds / _dayMs).clamp(0.0, double.infinity);
    final iv = p.intervalDays <= 0 ? 1 : p.intervalDays;
    final ratio = days / iv;
    var st = _status(p, now, s, ignoreSkip: false);
    var base = _status(p, now, s, ignoreSkip: true);
    if ((st == PersonStatus.ok || st == PersonStatus.asleep) && ratio < Tune.dueFloor) {
      st = PersonStatus.notDue;
    }
    if ((base == PersonStatus.ok || base == PersonStatus.asleep) && ratio < Tune.dueFloor) {
      base = PersonStatus.notDue;
    }
    final info = expectedInfo(p.chats, ratio);
    rows.add(RankRow(
      person: p,
      days: days,
      ratio: ratio,
      score: ratio * p.weight,
      status: st,
      expectedMinutes: info.minutes,
      sure: info.sure,
      hasHistory: p.chats.isNotEmpty,
      skipEligible: st == PersonStatus.skipped && base == PersonStatus.ok,
    ));
  }
  rows.sort((a, b) {
    final ao = a.status == PersonStatus.ok ? 0 : 1;
    final bo = b.status == PersonStatus.ok ? 0 : 1;
    if (ao != bo) return ao - bo;
    if (b.score != a.score) return b.score.compareTo(a.score);
    if (b.days != a.days) return b.days.compareTo(a.days);
    return a.person.name.toLowerCase().compareTo(b.person.name.toLowerCase());
  });
  return rows;
}

/// The "how much time do you have" setting: Any, 15, 30, 60+.
enum TimeChip { any, m15, m30, long }

bool chipFits(TimeChip chip, int expectedMinutes) {
  switch (chip) {
    case TimeChip.any:
      return true;
    case TimeChip.m15:
      return expectedMinutes <= Tune.chip15Max;
    case TimeChip.m30:
      return expectedMinutes >= Tune.chip30Min;
    case TimeChip.long:
      return expectedMinutes >= Tune.chipLongMin;
  }
}

class HeroPick {
  const HeroPick({this.row, this.note = '', this.fromSkipped = false});
  final RankRow? row;
  final String note;

  /// Nobody else could be shown, so a person skipped today came back sooner.
  final bool fromSkipped;
}

/// The one person to show. The time chip is a soft preference: someone who
/// does not fit has their score multiplied by the chip penalty, so a very
/// overdue person can still win. A person skipped today comes back sooner
/// than tomorrow only once everyone else who could be shown has already been
/// talked to today (so "Not today" always visibly does something).
HeroPick pickHero(List<RankRow> rows, TimeChip chip) {
  var pool = rows.where((r) => r.status == PersonStatus.ok).toList();
  var fromSkipped = false;
  if (pool.isEmpty && rows.any((r) => r.status == PersonStatus.today)) {
    pool = rows.where((r) => r.skipEligible).toList();
    fromSkipped = pool.isNotEmpty;
  }
  if (pool.isEmpty) return const HeroPick();
  RankRow? best;
  var bestScore = -1.0;
  var bestFits = true;
  for (final r in pool) {
    final fits = chip == TimeChip.any || chipFits(chip, r.expectedMinutes);
    final sc = r.score * (fits ? 1 : Tune.chipPenalty);
    if (sc > bestScore) {
      bestScore = sc;
      best = r;
      bestFits = fits;
    }
  }
  var note = '';
  if (chip != TimeChip.any && !bestFits) {
    note = chip == TimeChip.m15
        ? 'A quick hello still counts.'
        : 'Not a perfect fit for that, but they are the most due.';
  }
  return HeroPick(row: best, note: note, fromSkipped: fromSkipped);
}

/// Minutes until [r] next wakes up (start of the awake window in their zone).
int wakeInMinutes(RankPerson p, DateTime now, RankSettings s) {
  final cur = minutesOfDay(p.zone, now);
  final start = s.awakeStartMinutes;
  return cur < start ? start - cur : 1440 - cur + start;
}

/// "Overdue by 3 weeks · usually a 30 minute catch-up". With no chat history
/// the second half is dropped.
String whyLine(RankRow r) {
  final over = r.days - r.interval;
  String a;
  if (over >= 90) {
    a = 'Overdue by ${(over / 30).floor()} months';
  } else if (over >= 14) {
    a = 'Overdue by ${(over / 7).floor()} weeks';
  } else if (over >= 1) {
    final d = over.floor();
    a = 'Overdue by $d ${d == 1 ? 'day' : 'days'}';
  } else if (over > -1) {
    a = 'Due today';
  } else {
    final d = (-over).ceil();
    a = 'Due in $d ${d == 1 ? 'day' : 'days'}';
  }
  if (!r.hasHistory) return a;
  final m = r.expectedMinutes;
  final kind = m <= 20 ? 'check-in' : (m <= 45 ? 'catch-up' : 'long chat');
  return '$a · ${r.sure ? 'usually' : 'probably'} a $m minute $kind';
}

// ---------------------------------------------------------------- dates

class UpcomingDate {
  const UpcomingDate({
    required this.label,
    required this.sub,
    required this.days,
    required this.year,
    required this.month,
    required this.day,
    required this.personId,
  });
  final String label;
  final String sub;

  /// 0 = today.
  final int days;
  final int year;
  final int month;
  final int day;
  final String personId;

  DateTime get date => DateTime.utc(year, month, day);
}

class DateSource {
  const DateSource({
    required this.personId,
    required this.name,
    this.birthday,
    this.archived = false,
    this.relationships = const [],
    this.importantDates = const [],
  });
  final String personId;
  final String name;
  final String? birthday;
  final bool archived;
  final List<({String name, String? relation, String? birthday})> relationships;
  final List<({String label, String date, bool repeatsYearly})> importantDates;
}

bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

({int month, int day})? _monthDay(String? s) {
  if (s == null) return null;
  final m = RegExp(r'^(?:\d{4}|-)-(\d{2})-(\d{2})$').firstMatch(s);
  if (m == null) return null;
  final month = int.parse(m.group(1)!);
  final day = int.parse(m.group(2)!);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return (month: month, day: day);
}

/// Birthdays (people and their people) and important dates within
/// [limitDays] of today in [zone], soonest first. Feb 29 shows on Feb 28 in
/// years that are not leap years.
List<UpcomingDate> upcoming(List<DateSource> sources, DateTime now, String zone, int limitDays) {
  final t = calendarDate(zone, now);
  final today = DateTime.utc(t.year, t.month, t.day);
  final out = <UpcomingDate>[];

  DateTime occurrence(int month, int day, int year) {
    final d = (month == 2 && day == 29 && !_isLeap(year)) ? 28 : day;
    return DateTime.utc(year, month, d);
  }

  void addYearly(String label, String sub, String? date, String personId) {
    final md = _monthDay(date);
    if (md == null) return;
    var c = occurrence(md.month, md.day, t.year);
    if (c.isBefore(today)) c = occurrence(md.month, md.day, t.year + 1);
    final days = c.difference(today).inDays;
    if (days <= limitDays) {
      out.add(UpcomingDate(
          label: label, sub: sub, days: days, year: c.year, month: c.month, day: c.day, personId: personId));
    }
  }

  for (final p in sources) {
    if (p.archived) continue;
    addYearly("${p.name}'s birthday", '', p.birthday, p.personId);
    for (final r in p.relationships) {
      addYearly("${r.name}'s birthday", "${p.name}'s ${r.relation ?? 'person'}", r.birthday, p.personId);
    }
    for (final d in p.importantDates) {
      final full = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(d.date);
      if (full == null) continue;
      final label = '${p.name}: ${d.label}';
      if (d.repeatsYearly) {
        addYearly(label, '', d.date, p.personId);
      } else {
        final c = DateTime.utc(int.parse(full.group(1)!), int.parse(full.group(2)!), int.parse(full.group(3)!));
        final days = c.difference(today).inDays;
        if (days >= 0 && days <= limitDays) {
          out.add(UpcomingDate(
              label: label, sub: '', days: days, year: c.year, month: c.month, day: c.day, personId: p.personId));
        }
      }
    }
  }
  out.sort((a, b) => a.days.compareTo(b.days));
  return out;
}

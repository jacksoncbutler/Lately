import 'constants.dart';

/// Rules for logging a conversation. Pure Dart: no Flutter or storage.

/// quick (up to 20 minutes), catchup (up to 45), long (more).
String lengthForMinutes(int minutes) => minutes <= Tune.quickMaxMinutes
    ? 'quick'
    : (minutes <= Tune.catchupMaxMinutes ? 'catchup' : 'long');

enum ChatWhen { now, yesterday, otherDay }

/// When a chat happened, as stored.
class ChatTime {
  const ChatTime(this.occurredAt, {required this.approximate});
  final DateTime occurredAt; // UTC
  final bool approximate;
}

/// Just now is the current time; yesterday is the current time minus one day;
/// another day is date only, stored as 12:00 local, marked approximate, and
/// never in the future. [date] is required for [ChatWhen.otherDay].
ChatTime chatTime(ChatWhen when, DateTime now, {DateTime? date}) {
  switch (when) {
    case ChatWhen.now:
      return ChatTime(now.toUtc(), approximate: false);
    case ChatWhen.yesterday:
      return ChatTime(now.subtract(const Duration(days: 1)).toUtc(), approximate: false);
    case ChatWhen.otherDay:
      if (date == null) throw ArgumentError('A date is needed for another day');
      final noon = DateTime(date.year, date.month, date.day, 12);
      final t = noon.isAfter(now) ? now : noon;
      return ChatTime(t.toUtc(), approximate: true);
  }
}

const feelingOptions = ['Happy', 'Excited', 'Calm', 'Tired', 'Stressed', 'Sad'];

/// "today", "3 days ago", "5 weeks ago", "4 months ago".
String agoText(double days) {
  if (days < 1) return 'today';
  if (days < 14) {
    final d = days.floor();
    return d == 1 ? '1 day ago' : '$d days ago';
  }
  if (days < 60) return '${(days / 7).floor()} weeks ago';
  return '${(days / 30).floor()} months ago';
}

/// Whole days between [from] and [now] (fractional), never negative.
double daysSince(DateTime from, DateTime now) {
  final d = now.difference(from).inMinutes / 1440;
  return d < 0 ? 0 : d;
}

class LogCandidate {
  const LogCandidate(this.id, {required this.daysSinceContact, required this.intervalDays, required this.name});
  final String id;
  final double daysSinceContact;
  final int intervalDays;
  final String name;
  double get ratio => daysSinceContact / (intervalDays <= 0 ? 1 : intervalDays);
}

/// Who the log popup starts on when nobody was chosen: the person you just
/// tapped Contact for (within [Tune.recentContactHours]), else the most
/// overdue person. (Home's real hero card replaces the fallback in step 7.)
String? defaultLogPersonId({
  required List<LogCandidate> candidates,
  String? recentContactPersonId,
  DateTime? recentContactAt,
  required DateTime now,
}) {
  if (candidates.isEmpty) return null;
  if (recentContactPersonId != null &&
      recentContactAt != null &&
      now.difference(recentContactAt) < const Duration(hours: Tune.recentContactHours) &&
      candidates.any((c) => c.id == recentContactPersonId)) {
    return recentContactPersonId;
  }
  final sorted = [...candidates]..sort((a, b) {
      final r = b.ratio.compareTo(a.ratio);
      return r != 0 ? r : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  return sorted.first.id;
}

/// True when the recent contact is still fresh enough to prompt about.
bool recentContactIsFresh(DateTime? at, DateTime now) =>
    at != null && now.difference(at) < const Duration(hours: Tune.recentContactHours);

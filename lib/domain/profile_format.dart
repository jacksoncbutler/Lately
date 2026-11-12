// Plain text formatting for profile screens. No Flutter here.

const monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// A birthday as stored: "--MM-DD" when the year is unknown, else "YYYY-MM-DD".
typedef Birthday = ({int month, int day, int? year});

int daysInMonth(int month, {int? year}) {
  if (month == 2) {
    // Without a year, allow Feb 29 (someone born on a leap day).
    if (year == null) return 29;
    final leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
    return leap ? 29 : 28;
  }
  return const [4, 6, 9, 11].contains(month) ? 30 : 31;
}

/// Parses a stored birthday; null if it is missing or not a real date.
Birthday? parseBirthday(String? b) {
  if (b == null) return null;
  final m = RegExp(r'^(?:(\d{4})|-)-(\d{2})-(\d{2})$').firstMatch(b);
  if (m == null) return null;
  final year = m.group(1) == null ? null : int.parse(m.group(1)!);
  final month = int.parse(m.group(2)!);
  final day = int.parse(m.group(3)!);
  if (month < 1 || month > 12 || day < 1 || day > daysInMonth(month, year: year)) {
    return null;
  }
  return (month: month, day: day, year: year);
}

/// The stored form, or null if the date does not exist.
String? formatBirthday(int month, int day, {int? year}) {
  if (month < 1 || month > 12 || day < 1 || day > daysInMonth(month, year: year)) {
    return null;
  }
  if (year != null && (year < 1900 || year > 2100)) return null;
  final mm = month.toString().padLeft(2, '0');
  final dd = day.toString().padLeft(2, '0');
  return year == null ? '--$mm-$dd' : '${year.toString().padLeft(4, '0')}-$mm-$dd';
}

/// "Mar 14", or "Mar 14, 1990" when the year is known; null if invalid.
String? birthdayLabel(String? b) {
  final p = parseBirthday(b);
  if (p == null) return null;
  final base = '${monthNames[p.month - 1]} ${p.day}';
  return p.year == null ? base : '$base, ${p.year}';
}

/// "Sep 21", or "Sep 21, 2025" when the year differs from [now]'s.
String shortDate(DateTime d, DateTime now) {
  final l = d.toLocal();
  final base = '${monthNames[l.month - 1]} ${l.day}';
  return l.year == now.toLocal().year ? base : '$base, ${l.year}';
}

const typeLabels = {'person': 'In person', 'call': 'Call', 'text': 'Text'};
const lengthLabels = {'quick': 'Quick', 'catchup': 'Catch-up', 'long': 'Long'};
const depthLabels = {'shallow': 'Shallow', 'varied': 'Varied', 'deep': 'Deep'};

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// "Call · Catch-up · Varied · 30 min · happy" (unknown values shown as is).
String chatSummary({
  required String type,
  required String length,
  required String depth,
  int? minutes,
  List<String> feelings = const [],
}) {
  final parts = [
    typeLabels[type] ?? _cap(type),
    lengthLabels[length] ?? _cap(length),
    depthLabels[depth] ?? _cap(depth),
    if (minutes != null && minutes > 0) '${minutes >= 60 ? '60+' : minutes} min',
    if (feelings.isNotEmpty) feelings.join(', ').toLowerCase(),
  ];
  return parts.join(' · ');
}

/// "Rosa, grandmother" or just "Rosa".
String relationshipLine(String name, String? relation) =>
    relation == null || relation.trim().isEmpty ? name : '$name, ${relation.trim()}';

/// The phone number to dial, or null when the value is a handle, not a number.
String? dialableNumber(String? value) {
  if (value == null) return null;
  final v = value.trim();
  final digits = v.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 5) return null;
  if (RegExp(r'[A-Za-z@]').hasMatch(v)) return null;
  return (v.startsWith('+') ? '+' : '') + digits;
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "Sat, Nov 14" for a calendar date.
String weekdayDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${monthNames[d.month - 1]} ${d.day}';

/// "about 3 hours" or "about 40 minutes".
String aboutDuration(int minutes) => minutes >= 60
    ? 'about ${(minutes / 60).round()} ${(minutes / 60).round() == 1 ? 'hour' : 'hours'}'
    : 'about $minutes ${minutes == 1 ? 'minute' : 'minutes'}';

/// "8:00 am" for minutes since midnight.
String clockLabel(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'am' : 'pm'}';
}

/// "08:00" as stored.
String clockStored(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

// Plain text formatting for profile screens. No Flutter here.

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Mar 14" for '--03-14' (year unknown) or '1990-03-14'; null if invalid.
String? birthdayLabel(String? b) {
  if (b == null) return null;
  final m = RegExp(r'^(?:\d{4}|-)-(\d{2})-(\d{2})$').firstMatch(b);
  if (m == null) return null;
  final month = int.parse(m.group(1)!);
  final day = int.parse(m.group(2)!);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return '${_months[month - 1]} $day';
}

/// "Sep 21", or "Sep 21, 2025" when the year differs from [now]'s.
String shortDate(DateTime d, DateTime now) {
  final l = d.toLocal();
  final base = '${_months[l.month - 1]} ${l.day}';
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

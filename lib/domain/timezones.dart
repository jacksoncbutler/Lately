// latest_all includes link names (Europe/Amsterdam, Asia/Kuwait, ...) that
// phones still report, which the smaller latest.dart leaves out.
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'cities.dart';

/// Offline timezone helpers on top of the bundled IANA database. Daylight
/// saving is handled by the database at runtime, never by stored offsets.

bool _loaded = false;

void ensureTimezonesLoaded() {
  if (_loaded) return;
  tzdata.initializeTimeZones();
  _loaded = true;
}

bool isValidZone(String name) {
  ensureTimezonesLoaded();
  try {
    tz.getLocation(name);
    return true;
  } catch (_) {
    return false;
  }
}

/// "2:10 pm" in [zone] at [now]. Falls back to UTC for an unknown zone.
String clockText(String zone, DateTime now) {
  ensureTimezonesLoaded();
  final loc = isValidZone(zone) ? tz.getLocation(zone) : tz.UTC;
  final t = tz.TZDateTime.from(now, loc);
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour < 12 ? 'am' : 'pm'}';
}

/// Hour and minute in [zone] (for the awake window).
({int hour, int minute}) hourMinute(String zone, DateTime now) {
  ensureTimezonesLoaded();
  final t = tz.TZDateTime.from(now, tz.getLocation(zone));
  return (hour: t.hour, minute: t.minute);
}

/// "Europe/Lisbon" -> "Lisbon", "America/Argentina/Buenos_Aires" -> "Buenos Aires".
String cityOfZone(String zone) => zone.split('/').last.replaceAll('_', ' ');

/// Best display name for a zone: a listed city on that zone if the zone's own
/// city is not listed, else the zone's city.
String zoneLabel(String zone) {
  final own = cityOfZone(zone);
  for (final c in cityList) {
    if (c.zone == zone && c.name == own) return own;
  }
  for (final c in cityList) {
    if (c.zone == zone) return c.name;
  }
  return own;
}

class CityMatch {
  const CityMatch(this.name, this.country, this.zone);
  final String name;
  final String country;
  final String zone;
}

const _folds = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ø': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n', 'ß': 'ss',
};

String fold(String s) {
  final b = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final ch = String.fromCharCode(r);
    b.write(_folds[ch] ?? ch);
  }
  return b.toString().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

List<CityMatch>? _all;

List<CityMatch> _allCities() {
  ensureTimezonesLoaded();
  return _all ??= () {
    final out = <CityMatch>[
      for (final c in cityList) CityMatch(c.name, c.country, c.zone),
    ];
    final have = {for (final c in out) fold(c.name)};
    for (final z in tz.timeZoneDatabase.locations.keys) {
      if (!z.contains('/') || z.startsWith('Etc/') || z.startsWith('US/')) continue;
      final name = cityOfZone(z);
      if (have.add(fold(name))) out.add(CityMatch(name, '', z));
    }
    return out;
  }();
}

/// Cities matching [query] (name, country, or zone city), best first.
List<CityMatch> searchCities(String query, {int limit = 6}) {
  final q = fold(query);
  if (q.isEmpty) return const [];
  final scored = <(int, CityMatch)>[];
  for (final c in _allCities()) {
    final n = fold(c.name);
    final country = fold(c.country);
    int? s;
    if (n == q) {
      s = 0;
    } else if (n.startsWith(q)) {
      s = 1;
    } else if (n.split(' ').any((w) => w.startsWith(q))) {
      s = 2;
    } else if (country.startsWith(q)) {
      s = 3;
    } else if (n.contains(q)) {
      s = 4;
    } else if (fold(cityOfZone(c.zone)).contains(q)) {
      s = 5;
    }
    if (s != null) scored.add((s, c));
  }
  scored.sort((a, b) {
    final d = a.$1.compareTo(b.$1);
    if (d != 0) return d;
    // Listed cities (which have a country) before zone-only ones.
    final listed = (a.$2.country.isEmpty ? 1 : 0).compareTo(b.$2.country.isEmpty ? 1 : 0);
    return listed != 0 ? listed : a.$2.name.compareTo(b.$2.name);
  });
  return [for (final e in scored.take(limit)) e.$2];
}

/// Calendar date (year, month, day) in [zone] at [instant].
({int year, int month, int day}) calendarDate(String zone, DateTime instant) {
  ensureTimezonesLoaded();
  final loc = isValidZone(zone) ? tz.getLocation(zone) : tz.UTC;
  final t = tz.TZDateTime.from(instant, loc);
  return (year: t.year, month: t.month, day: t.day);
}

/// Minutes since midnight in [zone] at [instant].
int minutesOfDay(String zone, DateTime instant) {
  ensureTimezonesLoaded();
  final loc = isValidZone(zone) ? tz.getLocation(zone) : tz.UTC;
  final t = tz.TZDateTime.from(instant, loc);
  return t.hour * 60 + t.minute;
}

/// The next midnight in [zone] after [now], as a UTC instant. Daylight saving
/// comes from the database, so the gap is 23 or 25 hours on those days.
DateTime nextLocalMidnight(String zone, DateTime now) {
  ensureTimezonesLoaded();
  final loc = isValidZone(zone) ? tz.getLocation(zone) : tz.UTC;
  final t = tz.TZDateTime.from(now, loc);
  return tz.TZDateTime(loc, t.year, t.month, t.day + 1).toUtc();
}

import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'countries.dart';
import 'zone_countries.dart';

/// Phone numbers: parsing what you type into international form (which
/// WhatsApp needs), and the country-code choices. Offline; pure Dart.

/// The default country for the country-code box before anything else is known.
const defaultCountryIso = 'US';

/// ISO country a timezone belongs to (null for a zone this table does not know).
String? countryOfZone(String? zone) => zone == null ? null : zoneCountries[zone];

CountryInfo? countryByIso(String? iso) {
  if (iso == null) return null;
  for (final c in countries) {
    if (c.iso == iso) return c;
  }
  return null;
}

/// 🇵🇹 for PT.
String flagEmoji(String iso) => String.fromCharCodes(
    iso.toUpperCase().codeUnits.map((c) => 0x1F1E6 + (c - 0x41)));

/// Countries matching [query]: a name ("port"), a dial code ("+44", "44"), or
/// an ISO code ("pt"). Best matches first; [first] (e.g. the person's country
/// and the US) are listed first when the query is empty.
List<CountryInfo> searchCountries(String query, {List<String> first = const []}) {
  final q = query.trim().toLowerCase().replaceAll('+', '');
  if (q.isEmpty) {
    final head = [for (final iso in first) ?countryByIso(iso)];
    final seen = {for (final c in head) c.iso};
    return [...head, for (final c in countries) if (!seen.contains(c.iso)) c];
  }
  final scored = <(int, CountryInfo)>[];
  for (final c in countries) {
    final n = c.name.toLowerCase();
    int? s;
    if (c.iso.toLowerCase() == q) {
      s = 0;
    } else if (c.dial == q) {
      s = 1;
    } else if (n.startsWith(q)) {
      s = 2;
    } else if (n.split(RegExp(r'[ (&]')).any((w) => w.startsWith(q))) {
      s = 3;
    } else if (RegExp(r'^\d+$').hasMatch(q) && c.dial.startsWith(q)) {
      s = 4;
    } else if (n.contains(q)) {
      s = 5;
    }
    if (s != null) scored.add((s, c));
  }
  scored.sort((a, b) {
    final d = a.$1.compareTo(b.$1);
    return d != 0 ? d : a.$2.name.compareTo(b.$2.name);
  });
  return [for (final e in scored) e.$2];
}

class PhoneParse {
  const PhoneParse({
    required this.raw,
    this.e164,
    this.iso,
    this.national = '',
    this.valid = false,
  });

  /// What was typed.
  final String raw;

  /// "+3515550142", or null if it could not be read as a number.
  final String? e164;

  /// The country the number belongs to, when known.
  final String? iso;

  /// The number without the country code, formatted the way that country does.
  final String national;

  /// Whether it looks like a real number for that country.
  final bool valid;

  /// What to store: the international form, else what was typed.
  String? get stored => raw.trim().isEmpty ? null : (e164 ?? raw.trim());
}

IsoCode? _iso(String? s) {
  if (s == null) return null;
  for (final c in IsoCode.values) {
    if (c.name == s) return c;
  }
  return null;
}

/// Reads [input] as a phone number.
/// - `+...` or `00...` is already international.
/// - A leading single `0` is the national trunk prefix: it means the person's
///   home country ([homeIso]) unless you chose the box's country yourself
///   ([boxChosen]), and the 0 is dropped.
/// - Anything else is a national number in the box's country ([boxIso]).
PhoneParse parsePhone(
  String input, {
  String? boxIso,
  String? homeIso,
  bool boxChosen = false,
}) {
  final raw = input.trim();
  if (raw.isEmpty) return PhoneParse(raw: raw);
  // Letters or too few digits: not a number (a handle, a note...).
  if (RegExp(r'[A-Za-z@]').hasMatch(raw) || raw.replaceAll(RegExp(r'\D'), '').length < 4) {
    return PhoneParse(raw: raw);
  }
  try {
    var s = raw;
    if (s.startsWith('00')) s = '+${s.substring(2)}';
    PhoneNumber p;
    if (s.startsWith('+')) {
      p = PhoneNumber.parse(s);
    } else {
      final region = (s.startsWith('0') && !boxChosen && homeIso != null)
          ? homeIso
          : (boxIso ?? homeIso ?? defaultCountryIso);
      final caller = _iso(region) ?? IsoCode.US;
      p = PhoneNumber.parse(s, callerCountry: caller);
      // The library drops a leading 0 only where it recognises the number. A
      // single 0 is the national trunk prefix, so if it is still there, try
      // the number without it and keep that if it reads better.
      if (s.startsWith('0') && p.nsn.startsWith('0')) {
        final stripped = PhoneNumber.parse(s.substring(1), callerCountry: caller);
        if (stripped.isValid() || !p.isValid()) p = stripped;
      }
    }
    return PhoneParse(
      raw: raw,
      e164: p.international,
      iso: p.isoCode.name,
      national: p.formatNsn(),
      valid: p.isValid(),
    );
  } catch (_) {
    return PhoneParse(raw: raw);
  }
}

/// The digits WhatsApp needs ("3515550142"), from a stored number. A stored
/// number without a country code is read in [homeIso]'s country, else the US.
String? whatsappDigits(String? stored, {String? homeIso}) {
  if (stored == null || stored.trim().isEmpty) return null;
  final p = parsePhone(stored, boxIso: homeIso, homeIso: homeIso);
  final e = p.e164;
  if (e == null) return null;
  return e.substring(1);
}

/// What to give the phone or messages app: the international form when the
/// number can be read, else the digits as stored.
String? dialNumber(String? stored, {String? homeIso}) {
  if (stored == null || stored.trim().isEmpty) return null;
  final p = parsePhone(stored, boxIso: homeIso, homeIso: homeIso);
  if (p.e164 != null) return p.e164;
  final digits = stored.replaceAll(RegExp(r'[^0-9+]'), '');
  return digits.replaceAll(RegExp(r'\D'), '').length >= 5 ? digits : null;
}

/// "sam.r" from "@sam.r" or "https://www.instagram.com/sam.r/?hl=en"; null if
/// it does not look like a username.
String? instagramUsername(String? input) {
  if (input == null) return null;
  var s = input.trim();
  if (s.isEmpty) return null;
  final url = RegExp(r'instagram\.com/([A-Za-z0-9._]+)', caseSensitive: false).firstMatch(s);
  if (url != null) s = url.group(1)!;
  s = s.replaceFirst(RegExp(r'^@'), '');
  return RegExp(r'^[A-Za-z0-9._]{1,30}$').hasMatch(s) ? s : null;
}

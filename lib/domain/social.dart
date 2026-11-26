import 'dart:convert';

import 'phone.dart';

/// Facebook: a username (or numeric id) is all that is needed to open their
/// profile or a Messenger chat. Pure Dart.

const _reserved = {
  'profile.php', 'people', 'groups', 'pages', 'watch', 'marketplace', 'events', 'login', 'sharer', 'sharer.php', 'share',
};

/// "sam.r" or "100012345678901" from a username, an @name or a link
/// (facebook.com/sam.r, fb.com/sam.r, m.me/sam.r, profile.php?id=123...).
/// Null if it does not look like one.
String? facebookToken(String? input) {
  if (input == null) return null;
  var s = input.trim();
  if (s.isEmpty) return null;
  final idParam = RegExp(r'[?&]id=(\d{5,20})').firstMatch(s);
  if (RegExp(r'profile\.php', caseSensitive: false).hasMatch(s) && idParam != null) {
    return idParam.group(1);
  }
  final url = RegExp(r'(?:facebook\.com|fb\.com|fb\.me|m\.me|messenger\.com/t)/([^/?#\s]+)', caseSensitive: false)
      .firstMatch(s);
  if (url != null) s = url.group(1)!;
  s = s.replaceFirst(RegExp(r'^@'), '');
  if (_reserved.contains(s.toLowerCase())) return null;
  if (RegExp(r'^\d{5,20}$').hasMatch(s)) return s; // a numeric id
  // Facebook usernames: letters, digits and dots, at least 5 characters.
  return RegExp(r'^[A-Za-z0-9.]{5,50}$').hasMatch(s) ? s : null;
}

bool _numeric(String t) => RegExp(r'^\d+$').hasMatch(t);

/// The page that opens their Facebook profile.
String facebookProfileUrl(String token) => _numeric(token)
    ? 'https://www.facebook.com/profile.php?id=$token'
    : 'https://www.facebook.com/$token';

/// The link that opens a Messenger chat with them.
String messengerUrl(String token) => 'https://m.me/$token';

/// Older versions kept one free-text "socials" field. Pulls an Instagram
/// username and a Facebook username out of it where they can be recognised
/// (an @name or an instagram.com link is Instagram; a facebook.com, fb.com or
/// m.me link is Facebook). [json] is the stored list, or plain text.
({String? instagram, String? facebook}) migrateSocials(String? json) {
  if (json == null || json.trim().isEmpty) return (instagram: null, facebook: null);
  var text = json;
  try {
    final decoded = jsonDecode(json);
    if (decoded is List) text = decoded.whereType<String>().join(' ');
  } catch (_) {}
  String? ig, fb;
  for (final t in text.split(RegExp(r'[,;\s]+'))) {
    if (t.isEmpty) continue;
    final lower = t.toLowerCase();
    if (lower.contains('facebook.com') || lower.contains('fb.com') || lower.contains('m.me/') || lower.contains('fb.me')) {
      fb ??= facebookToken(t);
    } else if (lower.contains('instagram.com') || t.startsWith('@')) {
      ig ??= instagramUsername(t);
    }
  }
  return (instagram: ig, facebook: fb);
}

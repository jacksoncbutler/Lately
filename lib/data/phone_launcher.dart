import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/social.dart';

/// Opens other apps. Behind an interface so iPhone support (and tests) only
/// swap this class. Each returns false when nothing could handle it.
abstract class PhoneLauncher {
  Future<bool> call(String number);
  Future<bool> message(String number);

  /// [digits] is the international number without the plus.
  Future<bool> whatsapp(String digits);
  Future<bool> instagramDm(String username);
  Future<bool> instagramProfile(String username);

  /// A Messenger chat; [token] is a Facebook username or numeric id.
  Future<bool> messenger(String token);
  Future<bool> facebookProfile(String token);
}

/// The two ways of opening something, so the order of steps can be tested.
abstract class AppOpener {
  /// Opens [url] in the app [package] only (Android). False if it is not there.
  Future<bool> intent(String url, String package);

  /// Opens [url] with whatever handles it (the app, or the browser).
  Future<bool> url(String url, {bool platformDefault = false});
}

class DeviceAppOpener implements AppOpener {
  @override
  Future<bool> intent(String url, String package) async {
    if (!Platform.isAndroid) return false;
    try {
      final i = AndroidIntent(
        action: 'action_view',
        data: url,
        package: package,
        flags: const [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      if (await i.canResolveActivity() != true) return false;
      await i.launch();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> url(String url, {bool platformDefault = false}) async {
    try {
      return await launchUrl(Uri.parse(url),
          mode: platformDefault ? LaunchMode.platformDefault : LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

const instagramPackage = 'com.instagram.android';
const messengerPackage = 'com.facebook.orca';
const facebookPackage = 'com.facebook.katana';

class DevicePhoneLauncher implements PhoneLauncher {
  DevicePhoneLauncher({
    AppOpener? opener,
    Future<void> Function(Duration)? wait,
    this.instagramWarmup = const Duration(milliseconds: 1500),
  })  : _o = opener ?? DeviceAppOpener(),
        _wait = wait ?? Future<void>.delayed;

  final AppOpener _o;
  final Future<void> Function(Duration) _wait;

  /// How long Instagram gets to start before the DM link is sent to it.
  final Duration instagramWarmup;

  @override
  Future<bool> call(String number) => _o.url(Uri(scheme: 'tel', path: number).toString(), platformDefault: true);

  @override
  Future<bool> message(String number) => _o.url(Uri(scheme: 'sms', path: number).toString(), platformDefault: true);

  // The app's own link: if WhatsApp is not installed this fails instead of
  // opening a web page.
  @override
  Future<bool> whatsapp(String digits) => _o.url('whatsapp://send?phone=$digits');

  @override
  Future<bool> instagramProfile(String username) async {
    if (await _o.intent('https://instagram.com/_u/$username', instagramPackage)) return true;
    if (await _o.url('instagram://user?username=$username')) return true;
    return _o.url('https://www.instagram.com/$username/');
  }

  // Instagram drops a deep link that arrives while it is still starting up, so
  // the DM only opened if the app was already running. Start it first (on the
  // profile), give it a moment, then send the DM link to the running app.
  @override
  Future<bool> instagramDm(String username) async {
    final dm = 'https://ig.me/m/$username';
    if (await _o.intent('https://instagram.com/_u/$username', instagramPackage)) {
      await _wait(instagramWarmup);
      if (await _o.intent(dm, instagramPackage)) return true;
    }
    return _o.url(dm);
  }

  @override
  Future<bool> messenger(String token) async {
    final u = messengerUrl(token);
    if (await _o.intent(u, messengerPackage)) return true;
    return _o.url(u);
  }

  @override
  Future<bool> facebookProfile(String token) async {
    final u = facebookProfileUrl(token);
    if (await _o.intent(u, facebookPackage)) return true;
    return _o.url(u);
  }
}

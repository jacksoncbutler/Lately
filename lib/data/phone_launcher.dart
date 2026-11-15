import 'package:url_launcher/url_launcher.dart';

/// Opens other apps. Behind an interface so iPhone support (and tests) only
/// swap this class. Each returns false when nothing could handle it.
abstract class PhoneLauncher {
  Future<bool> call(String number);
  Future<bool> message(String number);

  /// [digits] is the international number without the plus.
  Future<bool> whatsapp(String digits);
  Future<bool> instagramDm(String username);
  Future<bool> instagramProfile(String username);
}

class DevicePhoneLauncher implements PhoneLauncher {
  Future<bool> _open(Uri uri, {LaunchMode mode = LaunchMode.externalApplication}) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> call(String number) => _open(Uri(scheme: 'tel', path: number), mode: LaunchMode.platformDefault);

  @override
  Future<bool> message(String number) => _open(Uri(scheme: 'sms', path: number), mode: LaunchMode.platformDefault);

  // The app's own link: if WhatsApp is not installed this fails instead of
  // opening a web page.
  @override
  Future<bool> whatsapp(String digits) => _open(Uri.parse('whatsapp://send?phone=$digits'));

  // No stable app-only link exists for a DM, so this is the ig.me link, which
  // the Instagram app opens when it is installed.
  @override
  Future<bool> instagramDm(String username) => _open(Uri.parse('https://ig.me/m/$username'));

  @override
  Future<bool> instagramProfile(String username) async {
    if (await _open(Uri.parse('instagram://user?username=$username'))) return true;
    return _open(Uri.parse('https://www.instagram.com/$username/'));
  }
}

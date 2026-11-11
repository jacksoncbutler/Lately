import 'package:url_launcher/url_launcher.dart';

/// Opens the phone or messages app. Behind an interface so iPhone support
/// (and tests) only swap this class.
abstract class PhoneLauncher {
  Future<bool> call(String number);
  Future<bool> message(String number);
}

class DevicePhoneLauncher implements PhoneLauncher {
  @override
  Future<bool> call(String number) =>
      launchUrl(Uri(scheme: 'tel', path: number));

  @override
  Future<bool> message(String number) =>
      launchUrl(Uri(scheme: 'sms', path: number));
}

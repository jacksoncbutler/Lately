import 'package:lately/data/phone_launcher.dart';

/// Records what would have been opened, and whether it "worked".
class FakeLauncher implements PhoneLauncher {
  FakeLauncher({this.works = true});
  final bool works;
  final calls = <String>[];

  Future<bool> _rec(String s) async {
    calls.add(s);
    return works;
  }

  @override
  Future<bool> call(String number) => _rec('call:$number');
  @override
  Future<bool> message(String number) => _rec('sms:$number');
  @override
  Future<bool> whatsapp(String digits) => _rec('whatsapp:$digits');
  @override
  Future<bool> instagramDm(String username) => _rec('ig-dm:$username');
  @override
  Future<bool> instagramProfile(String username) => _rec('ig-profile:$username');
}

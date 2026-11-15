import 'package:flutter_test/flutter_test.dart';
import 'package:lately/data/phone_launcher.dart';

/// Records every step so the order can be checked.
class _Opener implements AppOpener {
  _Opener({this.installed = const {}, this.urlWorks = true});
  final Set<String> installed; // packages that are "installed"
  final bool urlWorks;
  final steps = <String>[];

  @override
  Future<bool> intent(String url, String package) async {
    steps.add('intent:$package:$url');
    return installed.contains(package);
  }

  @override
  Future<bool> url(String url, {bool platformDefault = false}) async {
    steps.add('url:$url');
    return urlWorks;
  }
}

void main() {
  late _Opener opener;
  late List<Duration> waits;
  DevicePhoneLauncher make(_Opener o) {
    waits = [];
    opener = o;
    return DevicePhoneLauncher(opener: o, wait: (d) async => waits.add(d), instagramWarmup: const Duration(milliseconds: 1500));
  }

  group('Instagram DM', () {
    test('starts Instagram first, waits, then sends the DM to the running app', () async {
      final l = make(_Opener(installed: {instagramPackage}));
      expect(await l.instagramDm('sam.r'), isTrue);
      expect(opener.steps, [
        'intent:$instagramPackage:https://instagram.com/_u/sam.r',
        'intent:$instagramPackage:https://ig.me/m/sam.r',
      ]);
      expect(waits, [const Duration(milliseconds: 1500)]); // the wait happens between the two
    });

    test('with no Instagram app it falls back to the web link, with no waiting', () async {
      final l = make(_Opener());
      expect(await l.instagramDm('sam.r'), isTrue);
      expect(opener.steps, [
        'intent:$instagramPackage:https://instagram.com/_u/sam.r',
        'url:https://ig.me/m/sam.r',
      ]);
      expect(waits, isEmpty);
    });

    test('says false when nothing could open it', () async {
      final l = make(_Opener(urlWorks: false));
      expect(await l.instagramDm('sam.r'), isFalse);
    });
  });

  group('profiles', () {
    test('Instagram profile goes to the app first, then its link, then the web page', () async {
      var l = make(_Opener(installed: {instagramPackage}));
      expect(await l.instagramProfile('sam.r'), isTrue);
      expect(opener.steps, ['intent:$instagramPackage:https://instagram.com/_u/sam.r']);

      l = make(_Opener(urlWorks: false));
      expect(await l.instagramProfile('sam.r'), isFalse);
      expect(opener.steps, [
        'intent:$instagramPackage:https://instagram.com/_u/sam.r',
        'url:instagram://user?username=sam.r',
        'url:https://www.instagram.com/sam.r/',
      ]);
    });

    test('Facebook profile uses the Facebook app, else the web', () async {
      var l = make(_Opener(installed: {facebookPackage}));
      expect(await l.facebookProfile('sam.rodrigues'), isTrue);
      expect(opener.steps, ['intent:$facebookPackage:https://www.facebook.com/sam.rodrigues']);
      l = make(_Opener());
      await l.facebookProfile('100012345678901');
      expect(opener.steps, [
        'intent:$facebookPackage:https://www.facebook.com/profile.php?id=100012345678901',
        'url:https://www.facebook.com/profile.php?id=100012345678901',
      ]);
    });
  });

  group('Messenger, WhatsApp, calls and texts', () {
    test('Messenger opens a chat in the Messenger app, else the m.me link', () async {
      var l = make(_Opener(installed: {messengerPackage}));
      expect(await l.messenger('sam.rodrigues'), isTrue);
      expect(opener.steps, ['intent:$messengerPackage:https://m.me/sam.rodrigues']);
      expect(waits, isEmpty);
      l = make(_Opener());
      await l.messenger('sam.rodrigues');
      expect(opener.steps.last, 'url:https://m.me/sam.rodrigues');
    });

    test('WhatsApp uses its own app link (it never opens a web page)', () async {
      final l = make(_Opener());
      await l.whatsapp('351912345678');
      expect(opener.steps, ['url:whatsapp://send?phone=351912345678']);
    });

    test('calls and texts go through the phone and messages apps', () async {
      final l = make(_Opener());
      await l.call('+351912345678');
      await l.message('+351912345678');
      expect(opener.steps, ['url:tel:+351912345678', 'url:sms:+351912345678']);
    });
  });
}

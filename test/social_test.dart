import 'package:flutter_test/flutter_test.dart';
import 'package:lately/domain/social.dart';

void main() {
  group('Facebook usernames and links', () {
    test('from a username, an @name or a link', () {
      expect(facebookToken('sam.rodrigues'), 'sam.rodrigues');
      expect(facebookToken('@sam.rodrigues'), 'sam.rodrigues');
      expect(facebookToken('https://www.facebook.com/sam.rodrigues'), 'sam.rodrigues');
      expect(facebookToken('https://facebook.com/sam.rodrigues/?ref=bookmarks'), 'sam.rodrigues');
      expect(facebookToken('https://m.facebook.com/sam.rodrigues'), 'sam.rodrigues');
      expect(facebookToken('fb.com/sam.rodrigues'), 'sam.rodrigues');
      expect(facebookToken('https://m.me/sam.rodrigues'), 'sam.rodrigues');
      expect(facebookToken('https://www.messenger.com/t/sam.rodrigues'), 'sam.rodrigues');
    });

    test('a numeric id, bare or from profile.php', () {
      expect(facebookToken('100012345678901'), '100012345678901');
      expect(facebookToken('https://www.facebook.com/profile.php?id=100012345678901'), '100012345678901');
      expect(facebookToken('https://www.facebook.com/profile.php?id=100012345678901&ref=x'), '100012345678901');
    });

    test('not a profile', () {
      expect(facebookToken(null), isNull);
      expect(facebookToken(''), isNull);
      expect(facebookToken('  '), isNull);
      expect(facebookToken('no'), isNull); // too short
      expect(facebookToken('has spaces'), isNull);
      expect(facebookToken('#nope'), isNull);
      expect(facebookToken('https://www.facebook.com/groups'), isNull);
      expect(facebookToken('https://www.facebook.com/profile.php'), isNull);
    });

    test('the links that open it', () {
      expect(facebookProfileUrl('sam.rodrigues'), 'https://www.facebook.com/sam.rodrigues');
      expect(facebookProfileUrl('100012345678901'), 'https://www.facebook.com/profile.php?id=100012345678901');
      expect(messengerUrl('sam.rodrigues'), 'https://m.me/sam.rodrigues');
      expect(messengerUrl('100012345678901'), 'https://m.me/100012345678901');
    });
  });

  group('the old free-text socials', () {
    test('an @name is Instagram', () {
      expect(migrateSocials('["@sam.r"]'), (instagram: 'sam.r', facebook: null));
    });

    test('links are told apart', () {
      final r = migrateSocials('["https://instagram.com/sam.r https://facebook.com/sam.rodrigues"]');
      expect(r, (instagram: 'sam.r', facebook: 'sam.rodrigues'));
    });

    test('several entries, commas, and plain text', () {
      expect(migrateSocials('@sam.r, fb.com/sam.rodrigues'), (instagram: 'sam.r', facebook: 'sam.rodrigues'));
      expect(migrateSocials('["@first", "@second"]'), (instagram: 'first', facebook: null)); // first wins
    });

    test('what cannot be recognised is not guessed', () {
      expect(migrateSocials('["tiktok: samr"]'), (instagram: null, facebook: null));
      expect(migrateSocials('["samr"]'), (instagram: null, facebook: null)); // no @, no link: ambiguous
      expect(migrateSocials(null), (instagram: null, facebook: null));
      expect(migrateSocials(''), (instagram: null, facebook: null));
      expect(migrateSocials('[]'), (instagram: null, facebook: null));
    });
  });
}

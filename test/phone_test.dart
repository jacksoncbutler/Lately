import 'package:flutter_test/flutter_test.dart';
import 'package:lately/domain/phone.dart';

void main() {
  group('country data', () {
    test('zones know their country', () {
      expect(countryOfZone('Europe/Lisbon'), 'PT');
      expect(countryOfZone('America/Chicago'), 'US');
      expect(countryOfZone('Europe/Amsterdam'), 'NL'); // a link name phones report
      expect(countryOfZone('Asia/Kolkata'), 'IN');
      expect(countryOfZone('Nowhere/Land'), isNull);
      expect(countryOfZone(null), isNull);
    });

    test('names, dial codes and flags', () {
      expect(countryByIso('PT')!.name, 'Portugal');
      expect(countryByIso('PT')!.dial, '351');
      expect(countryByIso('US')!.dial, '1');
      expect(countryByIso('ZZ'), isNull);
      expect(flagEmoji('PT'), '🇵🇹');
    });

    test('search by name, dial code or ISO', () {
      expect(searchCountries('portu').first.iso, 'PT');
      expect(searchCountries('+44').first.iso, 'GB');
      expect(searchCountries('44').first.iso, 'GB');
      expect(searchCountries('351').first.iso, 'PT');
      expect(searchCountries('pt').first.iso, 'PT');
      expect(searchCountries('united').map((c) => c.iso), containsAll(['US', 'AE']));
      expect(searchCountries('uk').map((c) => c.iso), contains('GB'));
      expect(searchCountries('britain').first.iso, 'GB');
      expect(searchCountries('zzzz'), isEmpty);
    });

    test('an empty search lists the likely countries first', () {
      final r = searchCountries('', first: ['PT', 'US']);
      expect(r[0].iso, 'PT');
      expect(r[1].iso, 'US');
      expect(r.where((c) => c.iso == 'PT'), hasLength(1)); // no duplicates
      expect(r.length, greaterThan(200));
    });

    test('every country has a usable dial code', () {
      for (final c in searchCountries('')) {
        expect(RegExp(r'^\d{1,4}$').hasMatch(c.dial), isTrue, reason: c.name);
      }
    });
  });

  group('reading what you type', () {
    test('a number with + is already international, whatever the box says', () {
      final p = parsePhone('+351 912 345 678', boxIso: 'US');
      expect(p.e164, '+351912345678');
      expect(p.iso, 'PT');
      expect(p.valid, isTrue);
      expect(p.stored, '+351912345678');
    });

    test('00 means the same as +', () {
      expect(parsePhone('00351912345678').e164, '+351912345678');
    });

    test('the box country is used for a plain national number (the US by default)', () {
      final p = parsePhone('(415) 555-2671');
      expect(p.e164, '+14155552671');
      expect(p.iso, 'US');
      expect(p.valid, isTrue);
      expect(parsePhone('912345678', boxIso: 'PT').e164, '+351912345678');
    });

    test("a leading 0 means the person's own country, and the 0 goes", () {
      final p = parsePhone('0912345678', boxIso: 'US', homeIso: 'PT');
      expect(p.e164, '+351912345678');
      expect(p.iso, 'PT');
      expect(parsePhone('07400 123456', boxIso: 'US', homeIso: 'GB').e164, '+447400123456');
    });

    test('a leading 0 uses the box only if you chose the country yourself', () {
      final p = parsePhone('07400 123456', boxIso: 'GB', homeIso: 'PT', boxChosen: true);
      expect(p.e164, '+447400123456');
    });

    test('a leading 0 with no home country falls back to the box', () {
      expect(parsePhone('07400 123456', boxIso: 'GB').e164, '+447400123456');
      // Italian numbers keep their leading 0, so it is only dropped when that reads better.
      expect(parsePhone('06 1234 5678', boxIso: 'IT').e164, '+390612345678');
    });

    test('the national form drops the country code', () {
      expect(parsePhone('+351912345678').national, '912 345 678');
      expect(parsePhone('+14155552671').national, '(415) 555-2671');
    });

    test('numbers that are not valid are still kept, and marked', () {
      final p = parsePhone('+351 555 0142');
      expect(p.e164, '+3515550142');
      expect(p.valid, isFalse);
    });

    test('garbage is not turned into a number, but what was typed is kept', () {
      final p = parsePhone('call me');
      expect(p.e164, isNull);
      expect(p.stored, 'call me');
    });

    test('blank is nothing', () {
      expect(parsePhone('  ').stored, isNull);
      expect(parsePhone('').e164, isNull);
    });
  });

  group('launching', () {
    test('WhatsApp wants digits only, with the country code', () {
      expect(whatsappDigits('+351 912 345 678'), '351912345678');
      expect(whatsappDigits('+351912345678'), '351912345678');
    });

    test('a number saved without a country code is read in the person\'s country', () {
      expect(whatsappDigits('912345678', homeIso: 'PT'), '351912345678');
      expect(whatsappDigits('0912345678', homeIso: 'PT'), '351912345678');
      expect(whatsappDigits('(415) 555-2671'), '14155552671'); // US when nothing is known
    });

    test('nothing to open when there is no number', () {
      expect(whatsappDigits(null), isNull);
      expect(whatsappDigits('  '), isNull);
      expect(whatsappDigits('@sam.r'), isNull);
    });

    test('the dialer gets the international form when it can be read', () {
      expect(dialNumber('+351 912 345 678'), '+351912345678');
      expect(dialNumber('0912345678', homeIso: 'PT'), '+351912345678');
      expect(dialNumber('call me'), isNull);
      expect(dialNumber(null), isNull);
    });
  });

  group('instagram usernames', () {
    test('from a handle or a link', () {
      expect(instagramUsername('@sam.r'), 'sam.r');
      expect(instagramUsername('sam_r'), 'sam_r');
      expect(instagramUsername(' https://www.instagram.com/sam.r/?hl=en '), 'sam.r');
      expect(instagramUsername('instagram.com/Sam_R'), 'Sam_R');
    });

    test('not a username', () {
      expect(instagramUsername(''), isNull);
      expect(instagramUsername(null), isNull);
      expect(instagramUsername('has spaces'), isNull);
      expect(instagramUsername('a' * 31), isNull);
      expect(instagramUsername('#nope'), isNull);
    });
  });
}

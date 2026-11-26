import 'package:flutter_test/flutter_test.dart';
import 'package:lately/domain/reach.dart';

void main() {
  test('the preferred channel from what is stored; anything unknown is Text', () {
    expect(channelOf('text'), Channel.text);
    expect(channelOf('call'), Channel.call);
    expect(channelOf('whatsapp'), Channel.whatsapp);
    expect(channelOf('instagram'), Channel.instagram);
    expect(channelOf('facebook'), Channel.facebook);
    expect(channelOf(null), Channel.text);
    expect(channelOf('signal'), Channel.text); // a newer app's value falls back
    for (final c in Channel.values) {
      expect(channelOf(channelType(c)), c);
    }
  });

  test('labels', () {
    expect([for (final c in Channel.values) channelLabel(c)], ['Text', 'Call', 'WhatsApp', 'Instagram', 'Facebook']);
  });

  group('what each channel needs', () {
    test('text and call need a number', () {
      expect(canReach(Channel.text, phone: '+351912345678'), isTrue);
      expect(canReach(Channel.call, phone: '+351912345678'), isTrue);
      expect(canReach(Channel.text), isFalse);
      expect(canReach(Channel.call, phone: '@sam.r'), isFalse);
      expect(canReach(Channel.text, instagram: 'sam.r'), isFalse);
    });

    test('WhatsApp needs a number it can read as international', () {
      expect(canReach(Channel.whatsapp, phone: '+351912345678'), isTrue);
      expect(canReach(Channel.whatsapp, phone: '912345678', homeIso: 'PT'), isTrue);
      expect(canReach(Channel.whatsapp, phone: 'call me'), isFalse);
      expect(canReach(Channel.whatsapp), isFalse);
    });

    test('Instagram needs a username (a link works too)', () {
      expect(canReach(Channel.instagram, instagram: 'sam.r'), isTrue);
      expect(canReach(Channel.instagram, instagram: 'https://instagram.com/sam.r'), isTrue);
      expect(canReach(Channel.instagram, instagram: '  '), isFalse);
      expect(canReach(Channel.instagram, phone: '+351912345678'), isFalse);
    });

    test('Facebook needs a username, id or link', () {
      expect(canReach(Channel.facebook, facebook: 'sam.rodrigues'), isTrue);
      expect(canReach(Channel.facebook, facebook: 'https://facebook.com/sam.rodrigues'), isTrue);
      expect(canReach(Channel.facebook, facebook: '100012345678901'), isTrue);
      expect(canReach(Channel.facebook, facebook: 'no'), isFalse);
      expect(canReach(Channel.facebook, instagram: 'sam.r'), isFalse);
    });

    test('what Contact opens', () {
      expect(channelTarget(Channel.facebook), 'Facebook Messenger');
      expect(channelTarget(Channel.instagram), 'their Instagram profile');
      expect(channelTarget(Channel.whatsapp), 'WhatsApp');
    });

    test('what is missing, in words', () {
      expect(missingFor(Channel.facebook), 'Add their Facebook profile to reach them.');
      expect(missingFor(Channel.instagram), 'Add their Instagram username to reach them.');
      expect(missingFor(Channel.whatsapp), 'Add a number to reach them.');
      expect(missingFor(Channel.text), 'Add a number to reach them.');
    });
  });
}

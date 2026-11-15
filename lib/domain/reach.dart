import 'phone.dart';

/// How to reach someone. The preferred channel is where Contact opens
/// straight to; the others are one tap away on their profile.
enum Channel { text, call, whatsapp, instagram }

Channel channelOf(String? type) {
  switch (type) {
    case 'call':
      return Channel.call;
    case 'whatsapp':
      return Channel.whatsapp;
    case 'instagram':
      return Channel.instagram;
    default:
      return Channel.text; // also anything newer apps may have stored
  }
}

String channelType(Channel c) => c.name;

String channelLabel(Channel c) {
  switch (c) {
    case Channel.text:
      return 'Text';
    case Channel.call:
      return 'Call';
    case Channel.whatsapp:
      return 'WhatsApp';
    case Channel.instagram:
      return 'Instagram';
  }
}

/// Whether [c] can be used with what is saved. A phone number is needed for
/// text, call and WhatsApp (WhatsApp also needs it readable as an international
/// number); an Instagram username for Instagram.
bool canReach(Channel c, {String? phone, String? instagram, String? homeIso}) {
  switch (c) {
    case Channel.text:
    case Channel.call:
      return dialNumber(phone, homeIso: homeIso) != null;
    case Channel.whatsapp:
      return whatsappDigits(phone, homeIso: homeIso) != null;
    case Channel.instagram:
      return instagramUsername(instagram) != null;
  }
}

/// What is missing, in words, when [c] cannot be used.
String missingFor(Channel c) =>
    c == Channel.instagram ? 'Add their Instagram username to reach them.' : 'Add a number to reach them.';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/phone.dart';
import '../../domain/reach.dart';

/// What a person has saved for reaching them.
class Reach {
  Reach(PersonRow p)
      : person = p,
        channel = channelOf(p.contactMethodType),
        phone = p.phone ?? (channelOf(p.contactMethodType) == Channel.instagram ? null : p.contactMethodValue),
        instagram = p.instagram ??
            (channelOf(p.contactMethodType) == Channel.instagram ? p.contactMethodValue : null),
        // Only a confirmed city says where they really are.
        homeIso = p.timezoneConfirmed ? countryOfZone(p.timezone) : null;

  final PersonRow person;
  final Channel channel;
  final String? phone;
  final String? instagram;
  final String? homeIso;

  bool can(Channel c) => canReach(c, phone: phone, instagram: instagram, homeIso: homeIso);
  bool get canContact => can(channel);
}

/// Opens [c] for [person]. Returns false when it could not be opened.
Future<bool> launchChannel(WidgetRef ref, PersonRow person, Channel c, {bool dm = true}) async {
  final r = Reach(person);
  final launcher = ref.read(phoneLauncherProvider);
  switch (c) {
    case Channel.call:
      final n = dialNumber(r.phone, homeIso: r.homeIso);
      return n != null && await launcher.call(n);
    case Channel.text:
      final n = dialNumber(r.phone, homeIso: r.homeIso);
      return n != null && await launcher.message(n);
    case Channel.whatsapp:
      final d = whatsappDigits(r.phone, homeIso: r.homeIso);
      return d != null && await launcher.whatsapp(d);
    case Channel.instagram:
      final u = instagramUsername(r.instagram);
      if (u == null) return false;
      return dm ? launcher.instagramDm(u) : launcher.instagramProfile(u);
  }
}

void _say(BuildContext context, String m) => ScaffoldMessenger.of(context)
  ..clearSnackBars()
  ..showSnackBar(SnackBar(content: Text(m)));

/// Contact: opens straight to their preferred app, and remembers who you
/// tried (the "Did you get to talk to them?" prompt and the log popup use it).
Future<void> contactPerson(BuildContext context, WidgetRef ref, PersonRow person) async {
  final c = Reach(person).channel;
  await ref.read(repositoryProvider).setRecentContact(person.id);
  final ok = await launchChannel(ref, person, c);
  if (!ok && context.mounted) {
    _say(context, "Could not open ${channelLabel(c)}. Is it installed?");
  }
}

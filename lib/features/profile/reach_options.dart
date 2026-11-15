import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/reach.dart';
import 'contact_action.dart';

/// Tap their number: Call, Text or WhatsApp, whatever their preferred app is.
Future<void> showNumberOptions(BuildContext context, PersonRow person) =>
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _OptionsSheet(
        person: person,
        title: 'Reach ${person.displayName}',
        subtitle: Reach(person).phone ?? '',
        options: const [Channel.call, Channel.text, Channel.whatsapp],
      ),
    );

class _OptionsSheet extends ConsumerWidget {
  const _OptionsSheet({
    required this.person,
    required this.title,
    required this.subtitle,
    required this.options,
  });
  final PersonRow person;
  final String title;
  final String subtitle;
  final List<Channel> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final r = Reach(person);

    Future<void> go(Channel c, {bool dm = true, bool counts = true}) async {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      // Opening a DM or a chat is an attempt to talk; looking at a profile is not.
      if (counts) await ref.read(repositoryProvider).setRecentContact(person.id);
      final ok = await launchChannel(ref, person, c, dm: dm);
      if (!ok) {
        messenger
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text('Could not open ${channelLabel(c)}. Is it installed?')));
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: t.titleLarge),
          if (subtitle.isNotEmpty) Text(subtitle, style: t.bodyMedium),
          const SizedBox(height: 16),
          ...[
            Row(children: [
              for (final c in options) ...[
                Expanded(
                  child: (r.channel == c ? FilledButton.new : OutlinedButton.new)(
                    key: Key('reach-${c.name}'),
                    onPressed: r.can(c) ? () => go(c) : null,
                    child: Text(channelLabel(c)),
                  ),
                ),
                if (c != options.last) const SizedBox(width: 8),
              ],
            ]),
            if (!r.can(Channel.whatsapp) && r.phone != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                    'WhatsApp needs a full number with its country code. Edit them to fix it.',
                    style: t.bodySmall),
              ),
          ],
        ]),
      ),
    );
  }
}

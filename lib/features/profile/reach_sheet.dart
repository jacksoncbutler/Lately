import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/profile_format.dart';

/// Contact: choose call or message, then the phone or messages app opens.
Future<void> showReachSheet(BuildContext context, PersonRow person) =>
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => ReachSheet(person: person),
    );

class ReachSheet extends ConsumerWidget {
  const ReachSheet({super.key, required this.person});
  final PersonRow person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = person.contactMethodValue ?? person.phone;
    final number = dialableNumber(value);
    final prefersCall = person.contactMethodType == 'call';
    final t = Theme.of(context).textTheme;

    Future<void> go(Future<bool> Function(String) launch) async {
      await ref.read(repositoryProvider).setRecentContact(person.id);
      await launch(number!);
      if (context.mounted) Navigator.pop(context);
    }

    final launcher = ref.read(phoneLauncherProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reach ${person.displayName}', style: t.titleLarge),
            const SizedBox(height: 4),
            Text(
              value == null || value.trim().isEmpty ? 'No number saved yet' : value,
              style: t.bodyMedium,
            ),
            if (value != null && number == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('That looks like a handle, so open the app you use for it.',
                    style: t.bodySmall),
              ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: (prefersCall ? FilledButton.new : OutlinedButton.new)(
                  onPressed: number == null ? null : () => go(launcher.call),
                  child: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: (prefersCall ? OutlinedButton.new : FilledButton.new)(
                  onPressed: number == null ? null : () => go(launcher.message),
                  child: const Text('Message'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text('This opens your phone or messages. Come back and log it when you have talked.',
                style: t.bodySmall),
          ],
        ),
      ),
    );
  }
}

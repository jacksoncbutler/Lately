import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_config.dart';
import '../../data/providers.dart';
import '../people/add_person_screen.dart';
import '../people/bulk_add_screen.dart';
import '../people/people_screen.dart';
import '../settings/settings_screen.dart';
import '../setup/setup_screen.dart';

/// Temporary Home: the real hero card arrives in build step 7. Until then it
/// shows the welcome for an empty app, or a count and a way into People.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(setupCompleteProvider);
    if (setup.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (setup.value == false) return const SetupScreen();

    final people = ref.watch(peopleProvider).value;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Center(
        child: people == null
            ? const CircularProgressIndicator()
            : people.isEmpty
                ? _welcome(context)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(AppConfig.appName),
                      const SizedBox(height: 8),
                      Text('${people.length} ${people.length == 1 ? 'person' : 'people'}',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const PeopleScreen())),
                        child: const Text('People'),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _welcome(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Who would you like to stay close to?',
                style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Start with a few people. You can fill in the rest as you go.',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AddPersonScreen())),
              child: const Text('Add someone'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const BulkAddScreen())),
              child: const Text('Add from contacts'),
            ),
          ],
        ),
      );
}

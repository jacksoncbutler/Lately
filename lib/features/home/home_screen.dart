import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_config.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../domain/chat_rules.dart';
import '../../ui/log_fab.dart';
import '../log/log_sheet.dart';
import '../people/add_person_screen.dart';
import '../people/bulk_add_screen.dart';
import '../people/people_screen.dart';
import '../settings/settings_screen.dart';
import '../setup/setup_screen.dart';

/// Temporary Home: the real hero card arrives in build step 7. Until then it
/// shows the welcome for an empty app, or a count and a way into People, plus
/// the "Did you get to talk to them?" prompt after Contact.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  // The contact time of a prompt the user answered "Not yet" to.
  DateTime? _dismissedFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning to the app re-checks whether the prompt is still fresh.
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final setup = ref.watch(setupCompleteProvider);
    if (setup.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (setup.value == false) return const SetupScreen();

    final people = ref.watch(peopleProvider).value;
    final settings = ref.watch(settingsProvider).value;
    final now = ref.read(nowProvider)();

    PersonRow? reached;
    if (settings != null &&
        people != null &&
        recentContactIsFresh(settings.recentContactAt, now) &&
        settings.recentContactAt != _dismissedFor) {
      reached = people.where((p) => p.id == settings.recentContactPersonId).firstOrNull;
    }

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (people == null || people.isEmpty) ? null : const LogFab(),
      body: Column(children: [
        if (reached != null)
          Card(
            key: const Key('reach-prompt'),
            margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Did you get to talk to ${reached.displayName}?',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => showLogSheet(context, personId: reached!.id),
                      child: const Text('Log it'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      // The log popup still defaults to them for a few hours.
                      onPressed: () => setState(() => _dismissedFor = settings!.recentContactAt),
                      child: const Text('Not yet'),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        Expanded(
          child: Center(
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
        ),
      ]),
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

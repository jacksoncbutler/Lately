import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../dates/dates_screen.dart';
import '../home/home_screen.dart';
import '../people/people_screen.dart';
import '../setup/setup_screen.dart';

/// First-run setup, then the three tabs: Home, People, Dates. Settings sits
/// behind the gear on Home.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(setupCompleteProvider);
    if (setup.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (setup.value == false) return const SetupScreen();

    final tab = ref.watch(tabIndexProvider);
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: const [HomeScreen(), PeopleScreen(), DatesScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => ref.read(tabIndexProvider.notifier).set(i),
        destinations: const [
          NavigationDestination(
              key: Key('tab-home'),
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              key: Key('tab-people'),
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'People'),
          NavigationDestination(
              key: Key('tab-dates'),
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today),
              label: 'Dates'),
        ],
      ),
    );
  }
}

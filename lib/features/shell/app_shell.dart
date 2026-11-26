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
      body: _LazyTabs(
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

/// Like an IndexedStack, but a tab is only built the first time you open it
/// (so the app starts without building a long People list nobody asked for),
/// and then it is kept, so it holds its place.
class _LazyTabs extends StatefulWidget {
  const _LazyTabs({required this.index, required this.children});
  final int index;
  final List<Widget> children;

  @override
  State<_LazyTabs> createState() => _LazyTabsState();
}

class _LazyTabsState extends State<_LazyTabs> {
  late final Set<int> _built = {widget.index};

  @override
  Widget build(BuildContext context) {
    _built.add(widget.index);
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _built.contains(i) ? widget.children[i] : const SizedBox.shrink(),
      ],
    );
  }
}

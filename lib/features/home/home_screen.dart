import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_config.dart';
import '../../data/providers.dart';
import '../settings/settings_screen.dart';

/// Temporary Home: the real hero card arrives in build step 7. The database
/// line is a check that storage opens on the phone and is removed then.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupCountProvider);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppConfig.appName),
            const SizedBox(height: 8),
            Text(
              groups.when(
                data: (n) => 'Database ready · $n groups',
                loading: () => 'Opening database…',
                error: (e, _) => 'Database error: $e',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

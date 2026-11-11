import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import 'data/providers.dart';

void main() => runApp(const ProviderScope(child: LatelyApp()));

class LatelyApp extends StatelessWidget {
  const LatelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F8A8A),
        useMaterial3: true,
      ),
      home: const _Placeholder(),
    );
  }
}

/// Temporary step 2 screen. The database line is a check that storage opens on
/// the phone; it is removed when Home arrives.
class _Placeholder extends ConsumerWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupCountProvider);
    return Scaffold(
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

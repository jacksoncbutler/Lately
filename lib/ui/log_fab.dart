import 'package:flutter/material.dart';

import '../features/log/log_sheet.dart';

/// The floating circle at the bottom centre of Home and People that opens the
/// log popup over the current screen.
class LogFab extends StatelessWidget {
  const LogFab({super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        key: const Key('log-fab'),
        tooltip: 'Log a chat',
        // Home and People each have one, and both stay in the tree.
        heroTag: null,
        shape: const CircleBorder(),
        onPressed: () => showLogSheet(context),
        child: const Icon(Icons.add_comment, size: 26),
      );
}

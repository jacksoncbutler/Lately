import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_config.dart';
import 'data/providers.dart';
import 'data/safe_open.dart';
import 'domain/timezones.dart';
import 'features/home/home_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ensureTimezonesLoaded();
  final docs = await getApplicationDocumentsDirectory();
  final support = await getApplicationSupportDirectory();
  final snapshots = Directory(p.join(support.path, 'snapshots'));
  try {
    final db = await openDatabaseSafely(
      // Same file drift_flutter used in the earlier builds.
      dbFile: File(p.join(docs.path, 'lately.sqlite')),
      snapshotDir: snapshots,
      connect: (f) => driftDatabase(
          name: 'lately',
          native: DriftNativeOptions(databasePath: () async => f.path)),
    );
    runApp(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        snapshotDirProvider.overrideWithValue(snapshots),
      ],
      child: const LatelyApp(),
    ));
  } on DatabaseOpenFailed catch (e) {
    runApp(_OpenFailedApp(e.message));
  }
}

class LatelyApp extends StatelessWidget {
  const LatelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: latelyThemeFor(Brightness.light),
      darkTheme: latelyThemeFor(Brightness.dark),
      home: const HomeScreen(),
    );
  }
}

class _OpenFailedApp extends StatelessWidget {
  const _OpenFailedApp(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: latelyThemeFor(Brightness.light),
      darkTheme: latelyThemeFor(Brightness.dark),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(message, textAlign: TextAlign.center)),
        ),
      ),
    );
  }
}

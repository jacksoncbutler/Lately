import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_config.dart';
import 'app_orientation.dart';
import 'data/providers.dart';
import 'data/safe_open.dart';
import 'domain/timezones.dart';
import 'features/shell/app_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockToPortrait();
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

/// Status and navigation bar icons that stay readable on the app's paper
/// colour in light and dark (the app draws behind the bars on newer Android).
SystemUiOverlayStyle systemUiStyleFor(Brightness b) {
  final dark = b == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: dark ? Brightness.dark : Brightness.light,
    systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );
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
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemUiStyleFor(Theme.of(context).brightness),
        child: child ?? const SizedBox.shrink(),
      ),
      home: const AppShell(),
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

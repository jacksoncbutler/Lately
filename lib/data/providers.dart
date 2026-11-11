import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backup/backup_service.dart';
import 'backup_platform.dart';
import 'database.dart';
import 'repository.dart';

/// Set in main() after the database has been opened safely (see safe_open.dart).
/// Tests override it with an in-memory database.
final databaseProvider = Provider<LatelyDatabase>(
    (ref) => throw UnimplementedError('databaseProvider must be overridden'));

/// Where automatic snapshots (before imports) are kept.
final snapshotDirProvider = Provider<Directory>(
    (ref) => throw UnimplementedError('snapshotDirProvider must be overridden'));

final backupPlatformProvider =
    Provider<BackupPlatform>((ref) => DeviceBackupPlatform());

final repositoryProvider =
    Provider<Repository>((ref) => Repository(ref.watch(databaseProvider)));

final backupServiceProvider = Provider<BackupService>((ref) => BackupService(
    ref.watch(databaseProvider),
    snapshotDir: ref.watch(snapshotDirProvider)));

/// Step 2 proof-of-life: group count read from the real database.
final groupCountProvider = FutureProvider<int>((ref) async =>
    (await ref.watch(repositoryProvider).listGroups()).length);

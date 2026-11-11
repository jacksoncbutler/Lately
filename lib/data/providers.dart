import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'repository.dart';

/// The one database for the app. Tests override this with an in-memory one.
final databaseProvider = Provider<LatelyDatabase>((ref) {
  final db = LatelyDatabase(driftDatabase(name: 'lately'));
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider =
    Provider<Repository>((ref) => Repository(ref.watch(databaseProvider)));

/// Step 2 proof-of-life: group count read from the real database.
final groupCountProvider = FutureProvider<int>((ref) async =>
    (await ref.watch(repositoryProvider).listGroups()).length);


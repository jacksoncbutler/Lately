/// Why a backup file was refused. Nothing is changed when one is thrown.
enum BackupProblem { notABackup, newerVersion, corrupted, invalid }

class BackupException implements Exception {
  BackupException(this.problem, this.message);
  final BackupProblem problem;
  final String message;
  @override
  String toString() => message;
}

enum ImportMode { replace, merge }

/// A fully validated backup, not yet written anywhere.
class ParsedBackup {
  ParsedBackup({
    required this.formatVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.data,
    required this.dataExtra,
  });
  final String formatVersion;
  final String? appVersion;
  final DateTime? exportedAt;

  /// Known collections, already migrated to the current major version.
  final Map<String, dynamic> data;

  /// Collections this app does not know (from a newer minor version).
  final Map<String, dynamic> dataExtra;

  int count(String collection) {
    final v = data[collection];
    return v is List ? v.length : 0;
  }
}

class ImportResult {
  ImportResult({required this.inserted, required this.updated});
  final int inserted;
  final int updated;
}

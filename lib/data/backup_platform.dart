import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Everything platform-specific about backups, behind one small interface so
/// iPhone support (and tests) only swap this class.
abstract class BackupPlatform {
  /// A private folder where the export file is written before sharing.
  Future<Directory> exportDirectory();

  /// Opens the system share sheet for [file].
  Future<void> shareFile(File file);

  /// Lets the user pick a backup file; null if they cancel.
  Future<String?> pickBackupText();
}

class DeviceBackupPlatform implements BackupPlatform {
  @override
  Future<Directory> exportDirectory() async {
    final t = await getTemporaryDirectory();
    return Directory('${t.path}/exports');
  }

  @override
  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  @override
  Future<String?> pickBackupText() async {
    final f = await FilePicker.pickFile();
    if (f == null) return null;
    final bytes = await f.readAsBytes();
    if (bytes.length > 100 * 1024 * 1024) {
      throw const FormatException('File is too large to be a backup');
    }
    return utf8.decode(bytes);
  }
}

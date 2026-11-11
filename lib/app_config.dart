/// Temporary identity values. The name and icon are placeholders, so they live
/// in one place. (The Android package id is net.butler.lately in
/// android/app/build.gradle.kts and the manifest label.)
class AppConfig {
  static const appName = 'Lately';

  /// Keep equal to the version in pubspec.yaml (a test checks this).
  static const appVersion = '0.5.1';
  static const backupFormat = 'lately-backup';

  /// Backup file format. Major changes need a migration; minor only add
  /// optional fields. See "Backup format" in docs/technical-plan.md.
  static const backupMajor = 1;
  static const backupMinor = 0;
  static const backupFormatVersion = '$backupMajor.$backupMinor';
}

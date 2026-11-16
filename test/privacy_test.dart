import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// "Data stays on the device." These guard the promises in CLAUDE.md so a
/// later change cannot quietly break them.
String read(String path) => File(path).readAsStringSync();

List<String> permissions(String manifest) => [
      for (final m in RegExp(r'<uses-permission[^>]*android:name="([^"]+)"').allMatches(manifest)) m.group(1)!,
    ];

void main() {
  final main = read('android/app/src/main/AndroidManifest.xml');

  test('the release app has no INTERNET permission', () {
    expect(permissions(main), isNot(contains('android.permission.INTERNET')));
  });

  test('the only permission it asks for is reading contacts (and only when you start a bulk add)', () {
    expect(permissions(main), ['android.permission.READ_CONTACTS']);
  });

  test('INTERNET exists only in the debug and profile manifests, which the build tools need', () {
    expect(permissions(read('android/app/src/debug/AndroidManifest.xml')), contains('android.permission.INTERNET'));
    expect(permissions(read('android/app/src/profile/AndroidManifest.xml')), contains('android.permission.INTERNET'));
  });

  test('cloud backup and device transfer of the data are off', () {
    expect(main, contains('android:allowBackup="false"'));
    expect(main, contains('android:fullBackupContent="false"'));
    expect(main, contains('@xml/data_extraction_rules'));
    final rules = read('android/app/src/main/res/xml/data_extraction_rules.xml');
    expect(rules, contains('<cloud-backup>'));
    expect(rules, contains('<device-transfer>'));
    for (final d in ['database', 'file', 'sharedpref', 'root']) {
      expect(RegExp('<exclude domain="$d"').allMatches(rules).length, 2, reason: d); // in both
    }
  });

  test('no analytics, crash reporting, ads or networking packages are used', () {
    final pubspec = read('pubspec.yaml');
    final deps = pubspec.substring(pubspec.indexOf('dependencies:'));
    for (final bad in [
      'firebase', 'sentry', 'crashlytics', 'analytics', 'mixpanel', 'amplitude', 'segment',
      'appsflyer', 'adjust', 'google_mobile_ads', 'facebook_app_events', 'http:', 'dio:', 'web_socket',
      'socket_io', 'connectivity', 'package_info_plus', 'device_info', 'sentry_flutter',
    ]) {
      expect(RegExp('^\\s*$bad', multiLine: true).hasMatch(deps), isFalse, reason: bad);
    }
  });

  test('the app code opens no network connections of its own', () {
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final text = f.readAsStringSync();
      for (final bad in ['HttpClient(', 'package:http/', 'Socket.connect', 'WebSocket.connect', 'package:dio/']) {
        expect(text.contains(bad), isFalse, reason: '${f.path} uses $bad');
      }
    }
  });

  test('the app is portrait only and keeps its name in one place', () {
    expect(main, contains('android:screenOrientation="portrait"'));
    expect(main, contains('android:label="Lately"'));
    expect(read('lib/app_config.dart'), contains("appName = 'Lately'"));
  });

  test('releases are signed with the one keystore, never a debug key', () {
    final gradle = read('android/app/build.gradle.kts');
    expect(gradle, contains('signingConfigs.findByName("release")'));
    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    expect(read('.gitignore'), contains('key.properties'));
    expect(read('.gitignore'), contains('*.jks'));
  });

  test('the launcher icon is the orbit icon, in every size and adaptive form', () {
    for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      for (final n in ['ic_launcher.png', 'ic_launcher_foreground.png']) {
        final f = File('android/app/src/main/res/mipmap-$d/$n');
        expect(f.existsSync(), isTrue, reason: '$d/$n');
        final bytes = f.readAsBytesSync();
        expect(bytes.sublist(1, 4), [0x50, 0x4E, 0x47]); // a PNG
      }
    }
    final adaptive = read('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml');
    expect(adaptive, contains('<monochrome'));
    expect(adaptive, contains('ic_launcher_background'));
    expect(read('android/app/src/main/res/values/ic_launcher_background.xml'), contains('#2E6F5E'));
  });
}

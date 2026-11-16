import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lately/app_orientation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the app asks for portrait only', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await lockToPortrait();
    final c = calls.singleWhere((c) => c.method == 'SystemChrome.setPreferredOrientations');
    expect(c.arguments, ['DeviceOrientation.portraitUp']);
  });

  test('and Android is locked to portrait from the first frame', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:screenOrientation="portrait"'));
  });
}

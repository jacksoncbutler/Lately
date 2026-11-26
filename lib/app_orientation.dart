import 'package:flutter/services.dart';

/// The app is portrait only for now (other devices and shapes come later). The
/// Android manifest locks it from the first frame; this keeps it locked from
/// Flutter's side too, and is where iPhone support will hook in.
Future<void> lockToPortrait() =>
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);

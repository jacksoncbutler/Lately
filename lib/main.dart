import 'package:flutter/material.dart';

import 'app_config.dart';

void main() => runApp(const LatelyApp());

class LatelyApp extends StatelessWidget {
  const LatelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F8A8A),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: Text(AppConfig.appName))),
    );
  }
}

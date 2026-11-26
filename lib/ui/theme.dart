import 'package:flutter/material.dart';

/// Colours from the prototype (warm paper, teal accent), light and dark.
class LatelyColors {
  const LatelyColors({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.soft,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.danger,
    required this.dangerSoft,
  });
  final Color paper, surface, ink, muted, line, soft, accent, onAccent, accentSoft, danger, dangerSoft;

  static const light = LatelyColors(
    paper: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF23201C),
    muted: Color(0xFF6A645C),
    line: Color(0xFFE6DFD3),
    soft: Color(0xFFEFE9DF),
    accent: Color(0xFF2E6F5E),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFDDEBE5),
    danger: Color(0xFFB3402A),
    dangerSoft: Color(0xFFF6E1DB),
  );

  static const dark = LatelyColors(
    paper: Color(0xFF171614),
    surface: Color(0xFF1F1E1B),
    ink: Color(0xFFF1EDE6),
    muted: Color(0xFFA79F94),
    line: Color(0xFF35322D),
    soft: Color(0xFF2A2824),
    accent: Color(0xFF63B89E),
    onAccent: Color(0xFF0E1D18),
    accentSoft: Color(0xFF1F3A31),
    danger: Color(0xFFE5826C),
    dangerSoft: Color(0xFF3C231D),
  );

  static LatelyColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

ThemeData latelyThemeFor(Brightness b) {
  final c = b == Brightness.dark ? LatelyColors.dark : LatelyColors.light;
  final scheme = ColorScheme.fromSeed(seedColor: c.accent, brightness: b).copyWith(
    primary: c.accent,
    onPrimary: c.onAccent,
    primaryContainer: c.accentSoft,
    onPrimaryContainer: c.ink,
    surface: c.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.muted,
    outline: c.line,
    outlineVariant: c.line,
    surfaceContainerHighest: c.soft,
    error: c.danger,
    errorContainer: c.dangerSoft,
  );
  final shape15 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15));
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.paper,
    appBarTheme: AppBarTheme(
      backgroundColor: c.paper,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: c.line),
      ),
    ),
    dividerTheme: DividerThemeData(color: c.line, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: shape15,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: shape15,
        side: BorderSide(color: c.line),
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.accent,
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.soft,
      selectedColor: c.accentSoft,
      side: const BorderSide(color: Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      labelStyle: TextStyle(color: c.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.line),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

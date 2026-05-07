import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'Inter',
    );
  }

  static ThemeData customSeedTheme(Color seedColor, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
        background: brightness == Brightness.dark ? const Color(0xFF121212) : null,
        surface: brightness == Brightness.dark ? const Color(0xFF1E1E1E) : null,
      ),
      scaffoldBackgroundColor: brightness == Brightness.dark ? const Color(0xFF121212) : null,
      fontFamily: 'Inter',
    );
  }
}

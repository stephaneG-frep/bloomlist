import 'package:flutter/material.dart';

class BloomPalette {
  static const List<Color> seeds = <Color>[
    Color(0xFF3A7D6D),
    Color(0xFF2563EB),
    Color(0xFFEA580C),
    Color(0xFFDC2626),
    Color(0xFF0E7490),
  ];
}

class BloomTheme {
  static ThemeData light(Color seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
        backgroundColor: scheme.surface,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  static ThemeData dark(Color seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0C111B),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: scheme.primaryContainer,
        backgroundColor: scheme.surface,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: scheme.surfaceContainerHighest,
      ),
    );
  }
}

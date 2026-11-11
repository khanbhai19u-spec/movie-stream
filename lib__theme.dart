import 'package:flutter/material.dart';

class FX {
  FX._();

  static const bg = Color(0xFF070B14);
  static const surface = Color(0xFF0F1626);
  static const surfaceHi = Color(0xFF172036);
  static const blue = Color(0xFF2F7BFF);
  static const cyan = Color(0xFF22D3EE);
  static const text = Color(0xFFEAF0FF);
  static const textDim = Color(0xFF8D98B3);
  static const star = Color(0xFFFFC857);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, cyan],
  );

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: blue,
        secondary: cyan,
        surface: surface,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: text, displayColor: text),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.96),
        indicatorColor: blue.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

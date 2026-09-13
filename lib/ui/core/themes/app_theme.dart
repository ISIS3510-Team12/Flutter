import "package:flutter/material.dart";
import "package:team12_flutter_juggle/ui/core/themes/app_color_scheme.dart";
import "package:team12_flutter_juggle/ui/core/themes/app_typography.dart";

class AppTheme {

  static ThemeData get light => _build(AppColorScheme.lightScheme);
  static ThemeData get dark => _build(AppColorScheme.darkScheme);

  static ThemeData _build(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: AppTypography.textTheme,
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );
}
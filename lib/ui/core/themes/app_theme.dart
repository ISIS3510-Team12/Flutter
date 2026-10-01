import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
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
    appBarTheme: AppBarTheme(
      titleTextStyle: AppTypography.textTheme.titleSmall?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      headerHeadlineStyle: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: AppFontWeight.bold,
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      hourMinuteTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 54,
        fontWeight: AppFontWeight.bold,
      ),
      dayPeriodColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colorScheme.secondary
            : Colors.transparent,
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colorScheme.onSecondary
            : colorScheme.onSurface,
      ),
    ),
  );
}

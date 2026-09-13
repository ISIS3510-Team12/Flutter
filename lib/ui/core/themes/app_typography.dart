import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

abstract final class AppFontWeight {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
}

abstract final class AppDisplayTypography {
  static final large = GoogleFonts.spaceGrotesk(
    fontSize: 96,
    fontWeight: AppFontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  static final medium = GoogleFonts.spaceGrotesk(
    fontSize: 80,
    fontWeight: AppFontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );
}

abstract final class AppHeadingTypography {
  static final h1 = GoogleFonts.spaceGrotesk(
    fontSize: 64,
    fontWeight: AppFontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  static final h2 = GoogleFonts.spaceGrotesk(
    fontSize: 48,
    fontWeight: AppFontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  static final h3 = GoogleFonts.spaceGrotesk(
    fontSize: 40,
    fontWeight: AppFontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  static final h4 = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: AppFontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  static final h5 = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: AppFontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  static final h6 = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: AppFontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );
}

abstract final class AppBodyTypography {
  static final large = GoogleFonts.rubik(
    fontSize: 20,
    fontWeight: AppFontWeight.regular,
    height: 1.4,
    letterSpacing: 0,
  );

  static final medium = GoogleFonts.rubik(
    fontSize: 16,
    fontWeight: AppFontWeight.regular,
    height: 1.4,
    letterSpacing: 0,
  );

  static final small = GoogleFonts.rubik(
    fontSize: 14,
    fontWeight: AppFontWeight.regular,
    height: 1.4,
    letterSpacing: 0,
  );
}

abstract final class AppLabelTypography {
  static final large = GoogleFonts.rubik(
    fontSize: 16,
    fontWeight: AppFontWeight.medium,
    height: 1.4,
    letterSpacing: 0,
  );

  static final medium = GoogleFonts.rubik(
    fontSize: 14,
    fontWeight: AppFontWeight.medium,
    height: 1.4,
    letterSpacing: 0,
  );

  static final small = GoogleFonts.rubik(
    fontSize: 12,
    fontWeight: AppFontWeight.medium,
    height: 1.4,
    letterSpacing: 0,
  );
}

abstract final class AppTypography {
  static final textTheme = TextTheme(
    displayLarge: AppDisplayTypography.large,
    displayMedium: AppDisplayTypography.medium,
    headlineLarge: AppHeadingTypography.h1,
    headlineMedium: AppHeadingTypography.h2,
    headlineSmall: AppHeadingTypography.h3,
    titleLarge: AppHeadingTypography.h4,
    titleMedium: AppHeadingTypography.h5,
    titleSmall: AppHeadingTypography.h6,
    bodyLarge: AppBodyTypography.large,
    bodyMedium: AppBodyTypography.medium,
    bodySmall: AppBodyTypography.small,
    labelLarge: AppLabelTypography.large,
    labelMedium: AppLabelTypography.medium,
    labelSmall: AppLabelTypography.small,
  );
}

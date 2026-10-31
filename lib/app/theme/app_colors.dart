import 'package:flutter/material.dart';

/// LocalJobs light palette. Keep feature colors here rather than in screens.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryContainer = primaryLight;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF3730A3);

  static const Color background = Color(0xFFF1FAF9);
  static const Color scaffoldBackground = background;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF171717);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color outline = border;
  static const Color outlineVariant = border;
  static const Color surfaceContainerLow = Color(0xFFFBFAF8);
  static const Color surfaceContainerHighest = primaryLight;

  static const Color success = Color(0xFF16A34A);
  static const Color tertiary = success;
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFDCFCE7);
  static const Color onTertiaryContainer = Color(0xFF166534);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // Secondary keeps the palette restrained while remaining available to M3.
  static const Color secondary = Color(0xFF6B7280);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF3F4F6);
  static const Color onSecondaryContainer = Color(0xFF374151);
  static const Color shadow = Color(0x0A171717);

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryLight,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
  );
}

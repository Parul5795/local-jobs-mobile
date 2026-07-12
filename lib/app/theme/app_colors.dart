import 'package:flutter/material.dart';

/// Class containing the color system definition for the LocalJobs application.
/// Maintains design system values in one place for consistency and easy updates.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Modern Blue/Indigo Palette (Trusted, professional, clean)
  static const Color primary = Color(0xFF2563EB); // Vibrant Blue (Tailwind Blue 600)
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFDBEAFE); // Soft Light Blue (Tailwind Blue 100)
  static const Color onPrimaryContainer = Color(0xFF1E40AF); // Dark Blue (Tailwind Blue 800)

  static const Color secondary = Color(0xFF0EA5E9); // Sky Blue (Tailwind Sky 500)
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE0F2FE);
  static const Color onSecondaryContainer = Color(0xFF0369A1);

  static const Color tertiary = Color(0xFF10B981); // Emerald Green for success states (Tailwind Emerald 500)
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFD1FAE5);
  static const Color onTertiaryContainer = Color(0xFF065F46);

  static const Color error = Color(0xFFEF4444); // Vibrant Red (Tailwind Red 500)
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  // Background and surfaces
  static const Color scaffoldBackground = Color(0xFFF8FAFC); // Very Light Gray/Blue (Tailwind Slate 50)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0F172A); // Almost Black (Tailwind Slate 900)

  // Surface container variants (modern replacement for surfaceVariant)
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainerHighest = Color(0xFFF1F5F9); // Light Gray border/background (Tailwind Slate 100)
  static const Color onSurfaceVariant = Color(0xFF64748B); // Cool Gray (Tailwind Slate 500)

  static const Color outline = Color(0xFFCBD5E1); // Border Gray (Tailwind Slate 300)
  static const Color outlineVariant = Color(0xFFE2E8F0); // Subtle Border Gray (Tailwind Slate 200)

  static const Color shadow = Color(0x0A000000); // 4% Opacity Black for soft modern shadows

  /// Light ColorScheme representing a professional Jobs Marketplace
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
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

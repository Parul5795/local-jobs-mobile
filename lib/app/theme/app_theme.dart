import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData.from(
      colorScheme: AppColors.lightColorScheme,
      useMaterial3: true,
    );
    final text = _textTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        actionsIconTheme: const IconThemeData(color: AppColors.onSurface),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _primaryButtonStyle),
      filledButtonTheme: FilledButtonThemeData(style: _primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        labelStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        errorStyle: const TextStyle(color: AppColors.error),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.7),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.7),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        disabledColor: AppColors.surfaceContainerHighest,
        labelStyle: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.onPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: AppColors.surface,
        elevation: 8,
        shadowColor: AppColors.shadow,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.onSurfaceVariant,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      ),
    );
  }

  static ButtonStyle get _primaryButtonStyle => FilledButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    disabledBackgroundColor: AppColors.border,
    disabledForegroundColor: AppColors.onSurfaceVariant,
    elevation: 0,
    minimumSize: const Size(48, 48),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );

  static TextTheme _textTheme(TextTheme base) => base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontSize: 42,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.2,
      color: AppColors.onSurface,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      color: AppColors.onSurface,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      color: AppColors.onSurface,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: AppColors.onSurface,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 27,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      color: AppColors.onSurface,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
      color: AppColors.onSurface,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.onSurface,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.onSurface,
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: AppColors.onSurfaceVariant,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
    ),
    labelSmall: base.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurfaceVariant,
    ),
  );
}

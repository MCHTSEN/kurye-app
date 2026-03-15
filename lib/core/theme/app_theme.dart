import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static final ThemeData light = _theme(Brightness.light);
  static final ThemeData dark = _theme(Brightness.dark);

  static TextStyle _ts({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0,
    Color? color,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );

  static ThemeData _theme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
    );

    final textColor = isLight ? AppColors.textPrimary : Colors.white;
    final textColorSoft = isLight ? AppColors.textPrimary : Colors.white70;

    final textTheme = TextTheme(
      headlineLarge: _ts(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: textColor),
      headlineMedium: _ts(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: textColor),
      headlineSmall: _ts(fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      titleLarge: _ts(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: _ts(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: _ts(fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: _ts(fontSize: 16, color: textColorSoft),
      bodyMedium: _ts(color: textColorSoft),
      bodySmall: _ts(fontSize: 12, color: AppColors.textMuted),
      labelLarge: _ts(fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: _ts(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: _ts(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.textMuted),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.surfaceHigh : colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: isLight ? Colors.white : colorScheme.surface,
        foregroundColor: isLight ? AppColors.textPrimary : Colors.white,
        titleTextStyle: _ts(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
        surfaceTintColor: Colors.transparent,
        shadowColor: isLight ? Colors.black12 : Colors.black26,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isLight ? Colors.white : colorScheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(
            color: isLight ? AppColors.border : colorScheme.outlineVariant,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.lg,
          ),
          textStyle: _ts(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          side: BorderSide(
            color: isLight ? AppColors.border : colorScheme.outline,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.lg,
          ),
          textStyle: _ts(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          textStyle: _ts(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(
            color: isLight ? AppColors.border : colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: _ts(color: AppColors.textMuted),
        hintStyle: _ts(color: AppColors.textMuted),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        side: BorderSide.none,
        labelStyle: _ts(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isLight ? Colors.white : colorScheme.surface,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        selectedLabelTextStyle: _ts(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
        unselectedLabelTextStyle: _ts(fontSize: 12, color: AppColors.textMuted),
      ),
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.border : colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: isLight ? Colors.white : colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
      ),
    );
  }
}

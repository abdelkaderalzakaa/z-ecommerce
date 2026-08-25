import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';

class AppTheme {
  static ThemeData getThemeFromAdmin(ThemeAdmin? admin, bool isDark) {
    if (admin == null) {
      return isDark ? getDarkTheme() : getLightTheme();
    }

    if (isDark) {
      return getDarkTheme(
        primaryColor: admin.getPrimaryColor(true),
        secondaryColor: admin.getSecondaryColor(true),
        backgroundColor: admin.getBackgroundColor(true),
        surfaceColor: admin.getSurfaceColor(true),
        textColor: admin.getTextColor(true),
        fontFamily: admin.fontFamily,
        buttonRadius: admin.buttonRadius,
        cardRadius: admin.cardRadius,
        inputRadius: admin.inputRadius,
      );
    } else {
      return getLightTheme(
        primaryColor: admin.getPrimaryColor(false),
        secondaryColor: admin.getSecondaryColor(false),
        backgroundColor: admin.getBackgroundColor(false),
        surfaceColor: admin.getSurfaceColor(false),
        textColor: admin.getTextColor(false),
        fontFamily: admin.fontFamily,
        buttonRadius: admin.buttonRadius,
        cardRadius: admin.cardRadius,
        inputRadius: admin.inputRadius,
      );
    }
  }

  static ThemeData getLightTheme({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    String? fontFamily,
    double? buttonRadius,
    double? cardRadius,
    double? inputRadius,
  }) {
    final effectiveFontFamily = fontFamily ?? 'Cairo';
    final effectiveButtonRadius = buttonRadius ?? 12.0;
    final effectiveInputRadius = inputRadius ?? 10.0;
    final effectiveCardRadius = cardRadius ?? 16.0;

    return ThemeData(
      brightness: Brightness.light,
      fontFamily: effectiveFontFamily,
      primaryColor: primaryColor ?? const Color(0xFF4F46E5),
      scaffoldBackgroundColor: backgroundColor ?? const Color(0xFFF9FAFB),
      cardColor: surfaceColor ?? const Color(0xFFFFFFFF),
      dividerColor: primaryColor != null ? primaryColor.withValues(alpha: 0.12) : const Color(0xFFE5E7EB),
      colorScheme: ColorScheme.light(
        primary: primaryColor ?? const Color(0xFF4F46E5),
        secondary: secondaryColor ?? const Color(0xFF10B981),
        surface: surfaceColor ?? const Color(0xFFFFFFFF),
        surfaceContainerHighest: primaryColor != null ? primaryColor.withValues(alpha: 0.08) : const Color(0xFFF3F4F6),
        onSurface: const Color(0xFF111827),
        onSurfaceVariant: const Color(0xFF4B5563),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontFamily: effectiveFontFamily, color: const Color(0xFF111827)),
        bodyMedium: TextStyle(fontFamily: effectiveFontFamily, color: const Color(0xFF4B5563)),
        bodySmall: TextStyle(fontFamily: effectiveFontFamily, color: const Color(0xFF6B7280)),
        titleLarge: TextStyle(fontFamily: effectiveFontFamily, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontFamily: effectiveFontFamily, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: (primaryColor ?? const Color(0xFF4F46E5)).computeLuminance() > 0.5 ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveButtonRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontFamily: effectiveFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            final baseColor = primaryColor ?? const Color(0xFF4F46E5);
            if (states.contains(WidgetState.pressed)) return baseColor.withValues(alpha: 0.85);
            if (states.contains(WidgetState.hovered)) return baseColor.withValues(alpha: 0.9);
            return baseColor;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryColor ?? const Color(0xFF4F46E5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveButtonRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontFamily: effectiveFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return primaryColor ?? const Color(0xFF4F46E5);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return Colors.white;
            }
            return primaryColor ?? const Color(0xFF4F46E5);
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor ?? const Color(0xFF4F46E5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveButtonRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: TextStyle(
            fontFamily: effectiveFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor ?? const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 14),
        labelStyle: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveInputRadius),
          borderSide: BorderSide(color: (primaryColor ?? const Color(0xFF4F46E5)).withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveInputRadius),
          borderSide: BorderSide(color: (primaryColor ?? const Color(0xFF4F46E5)).withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveInputRadius),
          borderSide: BorderSide(color: primaryColor ?? const Color(0xFF4F46E5), width: 1.8),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor ?? const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveCardRadius),
          side: BorderSide(color: (primaryColor ?? const Color(0xFF4F46E5)).withValues(alpha: 0.1), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor ?? const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveCardRadius)),
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveButtonRadius)),
        backgroundColor: const Color(0xFF222222),
        contentTextStyle: TextStyle(fontFamily: effectiveFontFamily, color: Colors.white, fontSize: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor ?? const Color(0xFFFFFFFF),
        selectedItemColor: primaryColor ?? const Color(0xFF4F46E5),
        unselectedItemColor: const Color(0xFF999999),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor ?? const Color(0xFF4F46E5);
          return Colors.transparent;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor ?? const Color(0xFF4F46E5);
          return const Color(0xFF999999);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor ?? const Color(0xFF4F46E5);
          return const Color(0xFFE0E0E0);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  static ThemeData getDarkTheme({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    String? fontFamily,
    double? buttonRadius,
    double? cardRadius,
    double? inputRadius,
  }) {
    final effectiveFontFamily = fontFamily ?? 'Cairo';
    final effectiveButtonRadius = buttonRadius ?? 12.0;
    final effectiveInputRadius = inputRadius ?? 10.0;
    final effectiveCardRadius = cardRadius ?? 16.0;

    final effectivePrimary = primaryColor ?? const Color(0xFF4F46E5);
    final effectiveSecondary = secondaryColor ?? const Color(0xFF10B981);
    final adjustedBackground = backgroundColor ?? const Color(0xFF121212);
    final adjustedSurface = surfaceColor ?? const Color(0xFF1E293B);
    final adjustedText = textColor ?? const Color(0xFFFFFFFF);

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: effectiveFontFamily,
      primaryColor: effectivePrimary,
      scaffoldBackgroundColor: adjustedBackground,
      cardColor: adjustedSurface,
      dividerColor: effectivePrimary.withValues(alpha: 0.2),
      colorScheme: ColorScheme.dark(
        primary: effectivePrimary,
        secondary: effectiveSecondary,
        surface: adjustedSurface,
        surfaceContainerHighest: effectivePrimary.withValues(alpha: 0.2),
        onSurface: adjustedText,
        onSurfaceVariant: const Color(0xFFA0A0A0),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontFamily: effectiveFontFamily, color: adjustedText),
        bodyMedium: TextStyle(fontFamily: effectiveFontFamily, color: const Color(0xFFA0A0A0)),
        bodySmall: TextStyle(color: Color(0xFF707070)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: effectivePrimary.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveButtonRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: TextStyle(
            fontFamily: effectiveFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) return effectivePrimary.withValues(alpha: 0.8);
            if (states.contains(WidgetState.hovered)) return effectivePrimary.withValues(alpha: 0.9);
            return effectivePrimary;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF333333), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveButtonRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: TextStyle(
            fontFamily: effectiveFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return effectivePrimary;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return const Color(0xFF000000);
            }
            return const Color(0xFFFFFFFF);
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: effectivePrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveButtonRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontFamily: effectiveFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            final baseColor = effectivePrimary;
            if (states.contains(WidgetState.pressed)) return baseColor.withValues(alpha: 0.12);
            if (states.contains(WidgetState.hovered)) return baseColor.withValues(alpha: 0.08);
            return Colors.transparent;
          }),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.all(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: effectivePrimary.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveInputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveInputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveInputRadius),
          borderSide: BorderSide(color: effectivePrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveInputRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveInputRadius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF707070), fontSize: 14),
        labelStyle: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveCardRadius),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveCardRadius)),
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFFE5E5E5),
        contentTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: effectivePrimary,
        unselectedItemColor: const Color(0xFF707070),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return effectivePrimary;
          return Colors.transparent;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return effectivePrimary;
          return const Color(0xFF707070);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFFB0B0B0);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return effectivePrimary;
          return const Color(0xFF333333);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      useMaterial3: true,
    );
  }
}

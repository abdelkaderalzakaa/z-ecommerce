import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getLightTheme({
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor ?? const Color(0xFF000000),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      cardColor: primaryColor != null ? primaryColor.withValues(alpha: 0.06) : const Color(0xFFF0F0F0),
      dividerColor: primaryColor != null ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFE5E5E5),
      colorScheme: ColorScheme.light(
        primary: primaryColor ?? const Color(0xFF000000),
        secondary: secondaryColor ?? const Color(0xFFFF3333),
        surface: primaryColor != null ? primaryColor.withValues(alpha: 0.06) : const Color(0xFFF0F0F0),
        surfaceContainerHighest: primaryColor != null ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFF2F0F1),
        onSurface: const Color(0xFF000000),
        onSurfaceVariant: const Color(0xFF6B6B6B),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF000000)),
        bodyMedium: TextStyle(color: Color(0xFF6B6B6B)),
        bodySmall: TextStyle(color: Color(0xFF999999)),
      ),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            final baseColor = primaryColor ?? const Color(0xFF000000);
            if (states.contains(WidgetState.pressed)) return baseColor.withValues(alpha: 0.8);
            if (states.contains(WidgetState.hovered)) return baseColor.withValues(alpha: 0.9);
            return baseColor;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return primaryColor ?? const Color(0xFF000000);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return Colors.white;
            }
            return const Color(0xFF000000);
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor ?? const Color(0xFF000000),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            final baseColor = primaryColor ?? const Color(0xFF000000);
            if (states.contains(WidgetState.pressed)) return baseColor.withValues(alpha: 0.12);
            if (states.contains(WidgetState.hovered)) return baseColor.withValues(alpha: 0.08);
            return Colors.transparent;
          }),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFF000000),
          padding: const EdgeInsets.all(8),
        ),
      ),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryColor != null ? primaryColor.withValues(alpha: 0.03) : const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor ?? const Color(0xFF000000), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 14),
        labelStyle: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF222222),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: primaryColor ?? const Color(0xFF000000),
        unselectedItemColor: const Color(0xFF999999),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor ?? const Color(0xFF000000);
          return Colors.transparent;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor ?? const Color(0xFF000000);
          return const Color(0xFF999999);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFF999999);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primaryColor ?? const Color(0xFF000000);
          return const Color(0xFFE5E5E5);
        }),
      ),
    );
  }

  static Color _adjustForDarkMode(Color color) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < 0.5) {
      return hsl.withLightness(0.6).toColor();
    }
    return color;
  }

  static ThemeData getDarkTheme({
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    final adjustedPrimary = primaryColor != null ? _adjustForDarkMode(primaryColor) : const Color(0xFFFFFFFF);
    final adjustedSecondary = secondaryColor != null ? _adjustForDarkMode(secondaryColor) : const Color(0xFFFF3333);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: adjustedPrimary,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: adjustedPrimary.withValues(alpha: 0.15),
      dividerColor: adjustedPrimary.withValues(alpha: 0.2),
      colorScheme: ColorScheme.dark(
        primary: adjustedPrimary,
        secondary: adjustedSecondary,
        surface: adjustedPrimary.withValues(alpha: 0.15),
        surfaceContainerHighest: adjustedPrimary.withValues(alpha: 0.2),
        onSurface: const Color(0xFFFFFFFF),
        onSurfaceVariant: const Color(0xFFA0A0A0),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
        bodyMedium: TextStyle(color: Color(0xFFA0A0A0)),
        bodySmall: TextStyle(color: Color(0xFF707070)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) return adjustedPrimary.withValues(alpha: 0.8);
            if (states.contains(WidgetState.hovered)) return adjustedPrimary.withValues(alpha: 0.9);
            return adjustedPrimary;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF333333), width: 1.5),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return adjustedPrimary;
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
          foregroundColor: adjustedPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            final baseColor = adjustedPrimary;
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
        fillColor: adjustedPrimary.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: adjustedPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF707070), fontSize: 14),
        labelStyle: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        selectedItemColor: adjustedPrimary,
        unselectedItemColor: const Color(0xFF707070),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return adjustedPrimary;
          return Colors.transparent;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return adjustedPrimary;
          return const Color(0xFF707070);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return const Color(0xFF121212);
          return const Color(0xFF707070);
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return adjustedPrimary;
          return const Color(0xFF333333);
        }),
      ),
      useMaterial3: true,
    );
  }
}

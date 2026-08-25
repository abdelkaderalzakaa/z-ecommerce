import 'package:flutter/material.dart';

class ThemeAdmin {
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String surfaceColor;
  final String textColor;

  final String darkPrimaryColor;
  final String darkSecondaryColor;
  final String darkBackgroundColor;
  final String darkSurfaceColor;
  final String darkTextColor;

  final String fontFamily;
  final double fontScale;

  final double buttonRadius;
  final double cardRadius;
  final double inputRadius;

  final String? logoUrl;
  final String? coverBannerUrl;

  const ThemeAdmin({
    required this.primaryColor,
    required this.secondaryColor,
    this.backgroundColor = '#F9FAFB',
    this.surfaceColor = '#FFFFFF',
    this.textColor = '#111827',
    this.darkPrimaryColor = '#4F46E5',
    this.darkSecondaryColor = '#10B981',
    this.darkBackgroundColor = '#111827',
    this.darkSurfaceColor = '#1F2937',
    this.darkTextColor = '#F9FAFB',
    this.fontFamily = 'Cairo',
    this.fontScale = 1.0,
    this.buttonRadius = 12.0,
    this.cardRadius = 16.0,
    this.inputRadius = 10.0,
    this.logoUrl,
    this.coverBannerUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'surfaceColor': surfaceColor,
      'textColor': textColor,
      'darkPrimaryColor': darkPrimaryColor,
      'darkSecondaryColor': darkSecondaryColor,
      'darkBackgroundColor': darkBackgroundColor,
      'darkSurfaceColor': darkSurfaceColor,
      'darkTextColor': darkTextColor,
      'fontFamily': fontFamily,
      'fontScale': fontScale,
      'buttonRadius': buttonRadius,
      'cardRadius': cardRadius,
      'inputRadius': inputRadius,
      'logoUrl': logoUrl,
      'coverBannerUrl': coverBannerUrl,
    };
  }

  factory ThemeAdmin.fromJson(Map<String, dynamic> json) {
    return ThemeAdmin(
      primaryColor: json['primaryColor'] ?? '#4F46E5',
      secondaryColor: json['secondaryColor'] ?? '#10B981',
      backgroundColor: json['backgroundColor'] ?? '#F9FAFB',
      surfaceColor: json['surfaceColor'] ?? '#FFFFFF',
      textColor: json['textColor'] ?? '#111827',
      darkPrimaryColor: json['darkPrimaryColor'] ?? json['primaryColor'] ?? '',
      darkSecondaryColor: json['darkSecondaryColor'] ?? json['secondaryColor'] ?? '',
      darkBackgroundColor: json['darkBackgroundColor'] ?? '#111827',
      darkSurfaceColor: json['darkSurfaceColor'] ?? '#1F2937',
      darkTextColor: json['darkTextColor'] ?? '#F9FAFB',
      fontFamily: json['fontFamily'] ?? 'Cairo',
      fontScale: (json['fontScale'] ?? 1.0).toDouble(),
      buttonRadius: (json['buttonRadius'] ?? 12.0).toDouble(),
      cardRadius: (json['cardRadius'] ?? 16.0).toDouble(),
      inputRadius: (json['inputRadius'] ?? 10.0).toDouble(),
      logoUrl: json['logoUrl'],
      coverBannerUrl: json['coverBannerUrl'],
    );
  }

  // Backward compatibility getters
  double get raduisButton => buttonRadius;
  double get raduisCard => cardRadius;

  // Flutter Helper Getters (Light)
  Color get primaryColorValue =>
      _parseColor(primaryColor, const Color(0xFF4F46E5));
  Color get secondaryColorValue =>
      _parseColor(secondaryColor, const Color(0xFF10B981));
  Color get backgroundColorValue =>
      _parseColor(backgroundColor, const Color(0xFFF9FAFB));
  Color get surfaceColorValue =>
      _parseColor(surfaceColor, const Color(0xFFFFFFFF));
  Color get textColorValue => _parseColor(textColor, const Color(0xFF111827));

  // Flutter Helper Getters (Dark)
  Color get darkPrimaryColorValue {
    if (darkPrimaryColor.isNotEmpty &&
        darkPrimaryColor != '#4F46E5' &&
        darkPrimaryColor != '4F46E5') {
      return _parseColor(darkPrimaryColor, primaryColorValue);
    }
    return primaryColorValue;
  }

  Color get darkSecondaryColorValue {
    if (darkSecondaryColor.isNotEmpty &&
        darkSecondaryColor != '#10B981' &&
        darkSecondaryColor != '10B981') {
      return _parseColor(darkSecondaryColor, secondaryColorValue);
    }
    return secondaryColorValue;
  }

  Color get darkBackgroundColorValue =>
      _parseColor(darkBackgroundColor, const Color(0xFF111827));
  Color get darkSurfaceColorValue =>
      _parseColor(darkSurfaceColor, const Color(0xFF1F2937));
  Color get darkTextColorValue => _parseColor(darkTextColor, const Color(0xFFF9FAFB));

  // Dynamic Theme Getters
  Color getPrimaryColor(bool isDark) => isDark ? darkPrimaryColorValue : primaryColorValue;
  Color getSecondaryColor(bool isDark) => isDark ? darkSecondaryColorValue : secondaryColorValue;
  Color getBackgroundColor(bool isDark) => isDark ? darkBackgroundColorValue : backgroundColorValue;
  Color getSurfaceColor(bool isDark) => isDark ? darkSurfaceColorValue : surfaceColorValue;
  Color getTextColor(bool isDark) => isDark ? darkTextColorValue : textColorValue;

  BorderRadius get buttonBorderRadius => BorderRadius.circular(buttonRadius);
  BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);
  BorderRadius get inputBorderRadius => BorderRadius.circular(inputRadius);

  static Color _parseColor(String hex, Color fallback) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  factory ThemeAdmin.fromMap(Map<String, dynamic> map) =>
      ThemeAdmin.fromJson(map);

  ThemeAdmin copyWith({
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    String? surfaceColor,
    String? textColor,
    String? darkPrimaryColor,
    String? darkSecondaryColor,
    String? darkBackgroundColor,
    String? darkSurfaceColor,
    String? darkTextColor,
    String? fontFamily,
    double? fontScale,
    double? buttonRadius,
    double? cardRadius,
    double? inputRadius,
    String? logoUrl,
    String? coverBannerUrl,
  }) {
    return ThemeAdmin(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      darkPrimaryColor: darkPrimaryColor ?? this.darkPrimaryColor,
      darkSecondaryColor: darkSecondaryColor ?? this.darkSecondaryColor,
      darkBackgroundColor: darkBackgroundColor ?? this.darkBackgroundColor,
      darkSurfaceColor: darkSurfaceColor ?? this.darkSurfaceColor,
      darkTextColor: darkTextColor ?? this.darkTextColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontScale: fontScale ?? this.fontScale,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      cardRadius: cardRadius ?? this.cardRadius,
      inputRadius: inputRadius ?? this.inputRadius,
      logoUrl: logoUrl ?? this.logoUrl,
      coverBannerUrl: coverBannerUrl ?? this.coverBannerUrl,
    );
  }

  Map<String, dynamic> toMap() => toJson();

  /// إنشاء كائن ThemeAdmin فارغ بقيم افتراضية
  factory ThemeAdmin.empty() {
    return const ThemeAdmin(
      primaryColor: '',
      secondaryColor: '',
      backgroundColor: '',
      surfaceColor: '',
      textColor: '',
      darkPrimaryColor: '',
      darkSecondaryColor: '',
      darkBackgroundColor: '',
      darkSurfaceColor: '',
      darkTextColor: '',
      fontFamily: '',
      fontScale: 0,
      buttonRadius: 0,
      cardRadius: 0,
      inputRadius: 0,
      logoUrl: '',
      coverBannerUrl: '',
    );
  }
}

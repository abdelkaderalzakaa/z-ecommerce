import 'package:flutter/material.dart';
//// هذا المودل الذي يستقبل معلومات الثيم من الداتا بيز
/// وتاثر على جميع واجهات السوبر ادمن وايضا على واجهة الرئيسية وايضا واجهات المصادقة 
/// هذا المودل يجب ان يكون موجود في جميع التطبيقات التي تعمل في النظام
/// ويكون موجود في الداتا بيز
/// ويكون موجود في العرض
/// ويكون موجود في المعالجة
class ThemeSuperAdmin {
  final String primaryColor;
  final String secondaryColor;
  final String backgroundColor;
  final String surfaceColor;
  final String textColor;

  final String fontFamily;
  final double fontScale;

  final double buttonRadius;
  final double cardRadius;
  final double inputRadius;

  final String? logoUrl;
  final String? coverBannerUrl;
  final bool isDarkModeEnabled;


  const ThemeSuperAdmin({
    required this.primaryColor,
    required this.secondaryColor,
    this.backgroundColor = '#F9FAFB',
    this.surfaceColor = '#FFFFFF',
    this.textColor = '#111827',
    this.fontFamily = 'Cairo',
    this.fontScale = 1.0,
    this.buttonRadius = 12.0,
    this.cardRadius = 16.0,
    this.inputRadius = 10.0,
    this.logoUrl,
    this.coverBannerUrl,
    this.isDarkModeEnabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'surfaceColor': surfaceColor,
      'textColor': textColor,
      'fontFamily': fontFamily,
      'fontScale': fontScale,
      'buttonRadius': buttonRadius,
      'cardRadius': cardRadius,
      'inputRadius': inputRadius,
      'logoUrl': logoUrl,
      'coverBannerUrl': coverBannerUrl,
      'isDarkModeEnabled': isDarkModeEnabled,
    };
  }

  factory ThemeSuperAdmin.fromJson(Map<String, dynamic> json) {
    return ThemeSuperAdmin(
      primaryColor: json['primaryColor'] ?? '#4F46E5',
      secondaryColor: json['secondaryColor'] ?? '#10B981',
      backgroundColor: json['backgroundColor'] ?? '#F9FAFB',
      surfaceColor: json['surfaceColor'] ?? '#FFFFFF',
      textColor: json['textColor'] ?? '#111827',
      fontFamily: json['fontFamily'] ?? 'Cairo',
      fontScale: (json['fontScale'] ?? 1.0).toDouble(),
      buttonRadius: (json['buttonRadius'] ?? 12.0).toDouble(),
      cardRadius: (json['cardRadius'] ?? 16.0).toDouble(),
      inputRadius: (json['inputRadius'] ?? 10.0).toDouble(),
      logoUrl: json['logoUrl'],
      coverBannerUrl: json['coverBannerUrl'],
      isDarkModeEnabled: json['isDarkModeEnabled'] ?? false,
    );
  }

  // Backward compatibility getters
  double get raduisButton => buttonRadius;
  double get raduisCard => cardRadius;

  // Flutter Helper Getters
  Color get primaryColorValue => _parseColor(primaryColor, const Color(0xFF4F46E5));
  Color get secondaryColorValue => _parseColor(secondaryColor, const Color(0xFF10B981));
  Color get backgroundColorValue => _parseColor(backgroundColor, const Color(0xFFF9FAFB));
  Color get surfaceColorValue => _parseColor(surfaceColor, const Color(0xFFFFFFFF));
  Color get textColorValue => _parseColor(textColor, const Color(0xFF111827));

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

  factory ThemeSuperAdmin.fromMap(Map<String, dynamic> map) => ThemeSuperAdmin.fromJson(map);

  Map<String, dynamic> toMap() => toJson();
}

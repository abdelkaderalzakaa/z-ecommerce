import 'package:flutter/material.dart';

class StoreTheme {
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

  // Restaurant Digital Menu Branding Fields
  final bool isRestaurantMenuEnabled;
  final String restaurantMenuLayout;
  final String restaurantMenuThemeStyle; // 'modern', 'chalkboard', 'italiano'
  final bool showCaloriesBadges;
  final bool showAllergensBadges;
  final bool enableTableOrderQR;

  // Restaurant Menu Front Cover Page Fields
  final String menuCoverTitle;
  final String menuCoverSubtitle;
  final String menuOfferBadgeText;
  final String menuContactPhone;

  const StoreTheme({
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
    this.isRestaurantMenuEnabled = false,
    this.restaurantMenuLayout = 'grid',
    this.restaurantMenuThemeStyle = 'chalkboard',
    this.showCaloriesBadges = true,
    this.showAllergensBadges = true,
    this.enableTableOrderQR = true,
    this.menuCoverTitle = 'THE FOOD RESTO MENU',
    this.menuCoverSubtitle = 'استمتع بأشهى وأجود الوجبات والمأكولات الطازجة اليوم',
    this.menuOfferBadgeText = '🔥 خصم 20% لفترة محدودة',
    this.menuContactPhone = '+966 50 123 4567',
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
      'isRestaurantMenuEnabled': isRestaurantMenuEnabled,
      'restaurantMenuLayout': restaurantMenuLayout,
      'restaurantMenuThemeStyle': restaurantMenuThemeStyle,
      'showCaloriesBadges': showCaloriesBadges,
      'showAllergensBadges': showAllergensBadges,
      'enableTableOrderQR': enableTableOrderQR,
      'menuCoverTitle': menuCoverTitle,
      'menuCoverSubtitle': menuCoverSubtitle,
      'menuOfferBadgeText': menuOfferBadgeText,
      'menuContactPhone': menuContactPhone,
    };
  }

  factory StoreTheme.fromJson(Map<String, dynamic> json) {
    return StoreTheme(
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
      isRestaurantMenuEnabled: json['isRestaurantMenuEnabled'] ?? false,
      restaurantMenuLayout: json['restaurantMenuLayout'] ?? 'grid',
      restaurantMenuThemeStyle: json['restaurantMenuThemeStyle'] ?? 'chalkboard',
      showCaloriesBadges: json['showCaloriesBadges'] ?? true,
      showAllergensBadges: json['showAllergensBadges'] ?? true,
      enableTableOrderQR: json['enableTableOrderQR'] ?? true,
      menuCoverTitle: json['menuCoverTitle'] ?? 'THE FOOD RESTO MENU',
      menuCoverSubtitle: json['menuCoverSubtitle'] ?? 'استمتع بأشهى وأجود الوجبات والمأكولات الطازجة اليوم',
      menuOfferBadgeText: json['menuOfferBadgeText'] ?? '🔥 خصم 20% لفترة محدودة',
      menuContactPhone: json['menuContactPhone'] ?? '+966 50 123 4567',
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

  factory StoreTheme.fromMap(Map<String, dynamic> map) => StoreTheme.fromJson(map);

  Map<String, dynamic> toMap() => toJson();
}

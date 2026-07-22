import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF000000);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF0F0F0);
  static const Color surfaceLight = Color(0xFFF2F0F1);
  static const Color accent = Color(0xFFFF3333);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textMuted = Color(0xFF999999);
  static const Color star = Color(0xFFFFC633);
  static const Color priceStrike = Color(0xFF999999);
  static const Color discountBadge = Color(0xFFFFE7E7);
  static const Color discountText = Color(0xFFFF3333);
  static const Color divider = Color(0xFFE5E5E5);
  static const Color cardBorder = Color(0xFFE5E5E5);
  static const Color newsletterBg = Color(0xFF000000);
  static const Color inputBg = Color(0xFFFFFFFF);
  static const Color footerBg = Color(0xFFFFFFFF);
  static const Color iconBg = Color(0xFFF5F5F5);
  static const Color green = Color(0xFF01AB31);
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

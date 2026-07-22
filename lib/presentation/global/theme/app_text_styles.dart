import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Satoshi';

  static TextStyle heroTitle(BuildContext context, bool isMobile) => TextStyle(
    fontSize: isMobile ? 32 : 64,
    fontWeight: FontWeight.w900,
    color: Theme.of(context).primaryColor,
    height: 1.1,
    letterSpacing: -1,
  );

  static TextStyle sectionTitle(BuildContext context, bool isMobile) => TextStyle(
    fontSize: isMobile ? 28 : 48,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).textTheme.bodyLarge?.color,
    letterSpacing: -0.5,
  );

  static TextStyle productName(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );

  static TextStyle priceStyle(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );

  static TextStyle priceStrike(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.priceStrike,
    decoration: TextDecoration.lineThrough,
  );

  static TextStyle discountBadge(BuildContext context) => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.discountText,
  );

  static TextStyle bodyText(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
    height: 1.6,
  );

  static TextStyle buttonText(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).scaffoldBackgroundColor,
    letterSpacing: 0.2,
  );

  static TextStyle statNumber(BuildContext context) => TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: Theme.of(context).textTheme.bodyLarge?.color,
  );

  static TextStyle statLabel(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary,
  );
}

import 'package:flutter/material.dart';

enum BusinessType {
  retailStore(
    icon: Icons.storefront,
    en: 'Retail Stores',
    ar: 'متاجر تجزئة',
  ),
  restaurant(
    icon: Icons.restaurant,
    en: 'Restaurants & Cafes',
    ar: 'مطاعم وكافيهات',
  ),
  service(
    icon: Icons.design_services,
    en: 'Services',
    ar: 'خدمات',
  ),
  other(
    icon: Icons.more_horiz,
    en: 'Other',
    ar: 'غير ذلك',
  );

  final IconData icon;
  final String en;
  final String ar;

  const BusinessType({
    required this.icon,
    required this.en,
    required this.ar,
  });

  static BusinessType fromString(String? value) {
    return BusinessType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BusinessType.retailStore,
    );
  }
}
enum UserRole {
  superAdmin,
  businessOwner,
  customer,
}
enum SocialPlatform {
  instagram,
  facebook,
  whatsapp,
  twitter,
  tiktok,
  linkedin,
  youtube,
  website,
  contactPhoneFirst,
  contactPhoneSecond,
  contactEmail,
}

enum CartItemType {
  product,
  offer,
}
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  shipped,
  delivered,
  cancelled;
}
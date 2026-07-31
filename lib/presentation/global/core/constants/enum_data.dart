enum BusinessType {
  retailStore, // متجر تجزئة
  restaurant,  // مطعم / كافيه
  service,     // تقديم خدمات
  other;       // غير ذلك

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
  contactPhoneFirst,
  contactPhoneSecond,
  contactEmail,
}

enum CartItemType {
  product,
  offer,
}
import '../../../presentation/global/translate/localized_string.dart';

class OfferModel {
  final String id;
  final String businessId;
  final LocalizedString name;
  final LocalizedString? description;
  final String
  type; // 'product_gift', 'bundle', 'discount', 'percentage_discount', 'fixed_discount', 'free_shipping', 'coupon', 'buy_x_get_y', 'clearance', 'loyalty_points'
  final String? productId;
  final List<String>? productIds;
  final double? price; // bundle price
  final String? giftProductId;
  final String? giftName;
  final String? giftImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? imageUrl;

  // الحقول الجديدة المتنوعة للعروض
  final double? discountPercent;
  final double? discountAmount;
  final double? minOrderAmount;
  final String? couponCode;
  final int? buyQuantity;
  final int? getQuantity;
  final double? pointsMultiplier;
  final String? categoryId;
  final String? brandId;

  const OfferModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.type,
    this.productId,
    this.productIds,
    this.price,
    this.giftProductId,
    this.giftName,
    this.giftImageUrl,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.description,
    this.imageUrl,
    this.discountPercent,
    this.discountAmount,
    this.minOrderAmount,
    this.couponCode,
    this.buyQuantity,
    this.getQuantity,
    this.pointsMultiplier,
    this.categoryId,
    this.brandId,
  });

  // ==========================================
  // 🧮 Dynamic Getters & Helpers
  // ==========================================

  /// التحقق مما إذا كان العرض سارياً ومفعلاً في الوقت الحالي
  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// هل ينتهي العرض قريباً (خلال 24 ساعة)؟
  bool get isExpiringSoon {
    if (!isValid) return false;
    final remainingHours = endDate.difference(DateTime.now()).inHours;
    return remainingHours >= 0 && remainingHours <= 24;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name.toMap(),
      'description': description?.toMap(),
      'type': type,
      'productId': productId,
      'productIds': productIds,
      'price': price,
      'giftProductId': giftProductId,
      'giftName': giftName,
      'giftImageUrl': giftImageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'imageUrl': imageUrl,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'minOrderAmount': minOrderAmount,
      'couponCode': couponCode,
      'buyQuantity': buyQuantity,
      'getQuantity': getQuantity,
      'pointsMultiplier': pointsMultiplier,
      'categoryId': categoryId,
      'brandId': brandId,
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      name: LocalizedString.fromMap(map['name'] ?? {}),
      description: map['description'] != null
          ? LocalizedString.fromMap(map['description'])
          : null,
      type: map['type'] ?? 'discount',
      productId: map['productId'],
      productIds: (map['productIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      price: (map['price'] ?? 0.0)?.toDouble(),
      giftProductId: map['giftProductId'],
      giftName: map['giftName'],
      giftImageUrl: map['giftImageUrl'],
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
      imageUrl: map['imageUrl'],
      discountPercent: (map['discountPercent'] ?? 0.0)?.toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0)?.toDouble(),
      minOrderAmount: (map['minOrderAmount'] ?? 0.0)?.toDouble(),
      couponCode: map['couponCode'],
      buyQuantity: map['buyQuantity'],
      getQuantity: map['getQuantity'],
      pointsMultiplier: (map['pointsMultiplier'] ?? 0.0)?.toDouble(),
      categoryId: map['categoryId'],
      brandId: map['brandId'],
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory OfferModel.fromJson(Map<String, dynamic> map) => OfferModel.fromMap(map);

  /// إنشاء كائن OfferModel فارغ بقيم افتراضية
  factory OfferModel.empty() {
    final now = DateTime.now();
    return OfferModel(
      id: '',
      businessId: '',
      name: const LocalizedString(ar: '', en: ''),
      type: 'discount',
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
    );
  }
}

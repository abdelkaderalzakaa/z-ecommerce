import 'localized_string.dart';

class OfferModel {
  final String id;
  final String companyId;
  final LocalizedString name;
  final String type; // 'product_gift', 'bundle', 'discount', 'percentage_discount', 'fixed_discount', 'free_shipping', 'coupon', 'buy_x_get_y', 'clearance', 'loyalty_points'
  final String? productId;
  final List<String>? productIds;
  final double? price; // bundle price
  final String? giftProductId;
  final String? giftName;
  final String? giftImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final LocalizedString? description;
  final String? imageUrl;
  
  // New diverse fields
  final double? discountPercent;
  final double? discountAmount;
  final double? minOrderAmount;
  final String? couponCode;
  final int? buyQuantity;
  final int? getQuantity;
  final double? pointsMultiplier;

  const OfferModel({
    required this.id,
    this.companyId = 'cmp_001',
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
  });

  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}

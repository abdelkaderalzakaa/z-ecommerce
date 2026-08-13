class ProductOfferModel {
  final String id;
  final String name;
  final String type; // 'buy_x_get_y', 'gift', 'free_shipping', 'bundle_discount'
  final String? couponCode;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? description;
  final double? minOrderAmount;
  final int? buyQuantity;
  final int? getQuantity;
  final String? giftProductId;
  final String? giftName;

  const ProductOfferModel({
    required this.id,
    required this.name,
    required this.type,
    this.couponCode,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.description,
    this.minOrderAmount,
    this.buyQuantity,
    this.getQuantity,
    this.giftProductId,
    this.giftName,
  });

  /// Checks if the offer is currently valid and active
  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  factory ProductOfferModel.fromMap(Map<String, dynamic> map) {
    return ProductOfferModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'bundle_discount',
      couponCode: map['couponCode'],
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      isActive: map['isActive'] ?? true,
      description: map['description'],
      minOrderAmount: map['minOrderAmount'] != null ? (map['minOrderAmount'] as num).toDouble() : null,
      buyQuantity: map['buyQuantity'] as int?,
      getQuantity: map['getQuantity'] as int?,
      giftProductId: map['giftProductId'],
      giftName: map['giftName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'couponCode': couponCode,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'description': description,
      'minOrderAmount': minOrderAmount,
      'buyQuantity': buyQuantity,
      'getQuantity': getQuantity,
      'giftProductId': giftProductId,
      'giftName': giftName,
    };
  }

  ProductOfferModel copyWith({
    String? id,
    String? name,
    String? type,
    String? couponCode,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? description,
    double? minOrderAmount,
    int? buyQuantity,
    int? getQuantity,
    String? giftProductId,
    String? giftName,
  }) {
    return ProductOfferModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      couponCode: couponCode ?? this.couponCode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      buyQuantity: buyQuantity ?? this.buyQuantity,
      getQuantity: getQuantity ?? this.getQuantity,
      giftProductId: giftProductId ?? this.giftProductId,
      giftName: giftName ?? this.giftName,
    );
  }
}

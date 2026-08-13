class DiscountModel {
  final String id;
  final String name;
  final String type; // 'invoice', 'product', 'category', 'stock', 'customer'
  final double value;
  final bool isPercentage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? productId;
  final bool isActive;
  final String? description;

  const DiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.isPercentage = true,
    this.startDate,
    this.endDate,
    this.productId,
    this.isActive = true,
    this.description,
  });

  /// Checks if the discount is currently valid and active
  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  factory DiscountModel.fromMap(Map<String, dynamic> map) {
    return DiscountModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'product',
      value: (map['value'] as num? ?? 0.0).toDouble(),
      isPercentage: map['isPercentage'] ?? true,
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      productId: map['productId'],
      isActive: map['isActive'] ?? true,
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'isPercentage': isPercentage,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'productId': productId,
      'isActive': isActive,
      'description': description,
    };
  }

  DiscountModel copyWith({
    String? id,
    String? name,
    String? type,
    double? value,
    bool? isPercentage,
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
    bool? isActive,
    String? description,
  }) {
    return DiscountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      isPercentage: isPercentage ?? this.isPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      productId: productId ?? this.productId,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}

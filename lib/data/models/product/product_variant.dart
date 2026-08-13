import 'package:z_ecommerce/presentation/global/core/constants/product_enums.dart';

/// Represents a specific product variant with unique attributes, price, and stock.
class ProductVariant {
  final bool isDefault;
  final ProductSize? size;
  final ProductColor? color;
  final ProductMaterial? material;
  final ProductType? type;
  final double? weight;
  final WeightUnit? weightUnit;

  /// Final price for THIS specific variant
  final double price;

  /// Original price before discount (optional)
  final double? originalPrice;

  /// Stock for THIS specific variant
  final int stock;

  const ProductVariant({
    this.isDefault = false,
    this.size,
    this.color,
    this.material,
    this.type,
    this.weight,
    this.weightUnit,
    required this.price,
    this.originalPrice,
    required this.stock,
  });

  /// Unique identifier generated from non-null attributes
  String get variantKey {
    final List<String> parts = [];
    if (isDefault) parts.add('default');
    if (size != null) parts.add('size:${size!.name}');
    if (color != null) parts.add('color:${color!.name}');
    if (material != null) parts.add('material:${material!.name}');
    if (type != null) parts.add('type:${type!.name}');
    if (weight != null) {
      final unitStr = weightUnit != null ? ' ${weightUnit!.name}' : '';
      parts.add('weight:$weight$unitStr');
    }
    return parts.isEmpty ? 'standard' : parts.join('|');
  }

  /// Factory constructor to create a [ProductVariant] from a map.
  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      isDefault: map['isDefault'] as bool? ?? false,
      size: _enumFromString(ProductSize.values, map['size']),
      color: _enumFromString(ProductColor.values, map['color']),
      material: _enumFromString(ProductMaterial.values, map['material']),
      type: _enumFromString(ProductType.values, map['type']),
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      weightUnit: _enumFromString(WeightUnit.values, map['weightUnit']),
      price: (map['price'] as num? ?? 0.0).toDouble(),
      originalPrice: map['originalPrice'] != null ? (map['originalPrice'] as num).toDouble() : null,
      stock: map['stock'] as int? ?? 0,
    );
  }

  /// Converts this [ProductVariant] into a map.
  Map<String, dynamic> toMap() {
    return {
      'isDefault': isDefault,
      'size': size?.name,
      'color': color?.name,
      'material': material?.name,
      'type': type?.name,
      'weight': weight,
      'weightUnit': weightUnit?.name,
      'price': price,
      'originalPrice': originalPrice,
      'stock': stock,
    };
  }

  /// Helper function to parse enum from String safely.
  static T? _enumFromString<T extends Enum>(List<T> values, String? value) {
    if (value == null) return null;
    try {
      return values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }

  /// Creates a copy of this [ProductVariant] with modified fields.
  ProductVariant copyWith({
    bool? isDefault,
    ProductSize? size,
    ProductColor? color,
    ProductMaterial? material,
    ProductType? type,
    double? weight,
    WeightUnit? weightUnit,
    double? price,
    double? originalPrice,
    int? stock,
  }) {
    return ProductVariant(
      isDefault: isDefault ?? this.isDefault,
      size: size ?? this.size,
      color: color ?? this.color,
      material: material ?? this.material,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductVariant &&
        other.isDefault == isDefault &&
        other.size == size &&
        other.color == color &&
        other.material == material &&
        other.type == type &&
        other.weight == weight &&
        other.weightUnit == weightUnit &&
        other.price == price &&
        other.originalPrice == originalPrice &&
        other.stock == stock;
  }

  @override
  int get hashCode {
    return Object.hash(
      isDefault,
      size,
      color,
      material,
      type,
      weight,
      weightUnit,
      price,
      originalPrice,
      stock,
    );
  }

  /// إنشاء كائن ProductVariant فارغ بقيم افتراضية
  factory ProductVariant.empty() {
    return const ProductVariant(
      isDefault: false,
      price: 0.0,
      stock: 0,
    );
  }
}

import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/product_variant.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

/// Represents an item in the shopping cart.
class CartItemModel {
  final String id;
  final CartItemType type;
  final ProductModel? product;
  final OfferModel? offer;
  int quantity;
  final ProductVariant? selectedVariant;

  CartItemModel({
    required this.id,
    required this.type,
    this.product,
    this.offer,
    this.quantity = 1,
    this.selectedVariant,
  }) : assert(
         product != null || offer != null,
         'Cart item must have product or offer',
       ),
       assert(
         product == null || product.variants.isEmpty || selectedVariant != null,
         'Selected variant cannot be null when product has variants',
       ),
       assert(
         product == null ||
             product.variants.isNotEmpty ||
             selectedVariant == null,
         'Selected variant must be null when product has no variants',
       );

  /// Dynamic unit price based on variant and offer rules
  double get unitPrice {
    // Base price comes from selected variant if available, otherwise from product base price
    final basePrice =
        selectedVariant?.price ??
        product?.basePrice ??
        product?.originalPrice ??
        0;

    if (type == CartItemType.product) {
      return basePrice;
    }

    if (type == CartItemType.offer && offer != null) {
      switch (offer!.type) {
        case 'bundle':
          return offer!.price ?? 0;

        case 'percentage_discount':
          return basePrice - (basePrice * (offer!.discountPercent ?? 0) / 100);

        case 'fixed_discount':
          return basePrice - (offer!.discountAmount ?? 0);

        case 'product_gift':
          return 0;

        default:
          return offer!.price ?? 0;
      }
    }

    return 0;
  }

  /// Total price calculated from unit price and quantity
  double get totalPrice => unitPrice * quantity;

  /// Returns true if this cart item has a variant selected
  bool get hasVariant => selectedVariant != null;

  /// Returns the display name for the selected variant (e.g., "size: xlarge / color: red / material: cotton")
  String? get variantDisplayName {
    if (selectedVariant == null) return null;
    return selectedVariant!.variantKey
        .replaceAll('|', ' / ')
        .replaceAll(':', ': ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'product': product?.toMap(),
      'offer': offer?.toMap(),
      'quantity': quantity,
      'selectedVariant': selectedVariant?.toMap(),
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      type: CartItemType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CartItemType.product,
      ),
      product: map['product'] != null
          ? ProductModel.fromMap(
              Map<String, dynamic>.from(map['product'] as Map),
            )
          : null,
      offer: map['offer'] != null
          ? OfferModel.fromMap(Map<String, dynamic>.from(map['offer'] as Map))
          : null,
      quantity: map['quantity'] ?? 1,
      selectedVariant: map['selectedVariant'] != null
          ? ProductVariant.fromMap(
              Map<String, dynamic>.from(map['selectedVariant'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CartItemModel.fromJson(Map<String, dynamic> map) =>
      CartItemModel.fromMap(map);

  /// إنشاء كائن CartItemModel فارغ بقيم افتراضية
  factory CartItemModel.empty() {
    return CartItemModel(
      id: '',
      type: CartItemType.product,
      quantity: 1,
    );
  }
}

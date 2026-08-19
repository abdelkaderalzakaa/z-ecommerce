import 'package:z_ecommerce/data/models/product/product_variant.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

/// Represents a lightweight item in the shopping cart for local persistence.
class CartItemModel {
  final String id;
  final CartItemType type;
  
  // Product details snapshot for display
  final String? productId;
  final String? productName;
  final String? productImage;
  final String? businessId;
  
  // The selected variant (contains price, stock limit, attributes)
  final ProductVariant? selectedVariant;
  
  // For offers (if it's an offer instead of a product)
  final String? offerId;
  final String? offerName;
  
  // Pricing (For display purposes. Will be revalidated on checkout)
  final double displayPrice; 
  
  int quantity;

  CartItemModel({
    required this.id,
    required this.type,
    this.productId,
    this.productName,
    this.productImage,
    this.businessId,
    this.selectedVariant,
    this.offerId,
    this.offerName,
    required this.displayPrice,
    this.quantity = 1,
  }) : assert(
         productId != null || offerId != null,
         'Cart item must have productId or offerId',
       );

  double get unitPrice => displayPrice;
  double get totalPrice => unitPrice * quantity;
  bool get hasVariant => selectedVariant != null;

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
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'businessId': businessId,
      'selectedVariant': selectedVariant?.toMap(),
      'offerId': offerId,
      'offerName': offerName,
      'displayPrice': displayPrice,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      type: CartItemType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CartItemType.product,
      ),
      productId: map['productId'],
      productName: map['productName'],
      productImage: map['productImage'],
      businessId: map['businessId'],
      selectedVariant: map['selectedVariant'] != null
          ? ProductVariant.fromMap(
              Map<String, dynamic>.from(map['selectedVariant'] as Map),
            )
          : null,
      offerId: map['offerId'],
      offerName: map['offerName'],
      displayPrice: (map['displayPrice'] as num? ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CartItemModel.fromJson(Map<String, dynamic> map) =>
      CartItemModel.fromMap(map);
}

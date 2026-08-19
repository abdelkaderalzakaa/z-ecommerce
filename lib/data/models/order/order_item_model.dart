import 'dart:convert';

/// Represents a historical snapshot of an item in the order.
/// This prevents the order from changing if the merchant updates the product price or deletes the product.
class OrderItemModel {
  final String id;
  final String orderId;

  // Snapshot of Product & Variant details
  final String productId;
  final String? variantId; // Can be derived from variantKey or kept empty if not explicitly used
  final String variantKey; 
  final String productName;
  final String? variantName;
  final String? productImage;
  
  // JSON string representing the selected attributes (size, color, material, etc.)
  final String selectedAttributes;

  // Financial Snapshot for this line item
  final double unitPrice; // Price fixed at checkout
  final int quantity;
  final double discountAmount; // Discount applied at checkout
  final double totalPrice;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    this.variantId,
    required this.variantKey,
    required this.productName,
    this.variantName,
    this.productImage,
    this.selectedAttributes = '{}',
    required this.unitPrice,
    required this.quantity,
    this.discountAmount = 0.0,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'variantId': variantId,
      'variantKey': variantKey,
      'productName': productName,
      'variantName': variantName,
      'productImage': productImage,
      'selectedAttributes': selectedAttributes,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'discountAmount': discountAmount,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return OrderItemModel(
      id: docId ?? map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      productId: map['productId'] ?? '',
      variantId: map['variantId'],
      variantKey: map['variantKey'] ?? '',
      productName: map['productName'] ?? '',
      variantName: map['variantName'],
      productImage: map['productImage'],
      selectedAttributes: map['selectedAttributes'] ?? '{}',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 1,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

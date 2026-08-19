import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

/// Represents a historical snapshot of the entire checkout process (can contain orders from multiple stores).
class OrderGroupModel {
  final String id;
  final String customerId;
  final DateTime createdAt;

  // Financials
  final double subtotal;
  final double shippingTotal;
  final double discountTotal;
  final double grandTotal;

  // Payment
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;

  // Historical snapshot of where to ship (JSON string or Map)
  final String shippingAddressSnapshot;

  OrderGroupModel({
    required this.id,
    required this.customerId,
    required this.createdAt,
    required this.subtotal,
    required this.shippingTotal,
    required this.discountTotal,
    required this.grandTotal,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingAddressSnapshot,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'createdAt': createdAt.toIso8601String(),
      'subtotal': subtotal,
      'shippingTotal': shippingTotal,
      'discountTotal': discountTotal,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'shippingAddressSnapshot': shippingAddressSnapshot,
    };
  }

  factory OrderGroupModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return OrderGroupModel(
      id: docId ?? map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingTotal: (map['shippingTotal'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (map['discountTotal'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      shippingAddressSnapshot: map['shippingAddressSnapshot'] ?? '',
    );
  }
}

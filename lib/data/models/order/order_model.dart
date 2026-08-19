import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

/// Represents a single store's order, part of an OrderGroup.
class OrderModel {
  final String id;
  final String orderGroupId;
  final String businessId;
  final String customerId; // Duplicated for easy querying per store
  final DateTime createdAt;

  final OrderStatus status;

  // Financials specific to this store's portion of the order
  final double subTotal;
  final double shippingCost;
  final double storeTotal;

  OrderModel({
    required this.id,
    required this.orderGroupId,
    required this.businessId,
    required this.customerId,
    required this.createdAt,
    required this.status,
    required this.subTotal,
    required this.shippingCost,
    required this.storeTotal,
  });

  bool get isEmpty => id.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderGroupId': orderGroupId,
      'businessId': businessId,
      'customerId': customerId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'subTotal': subTotal,
      'shippingCost': shippingCost,
      'storeTotal': storeTotal,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return OrderModel(
      id: docId ?? map['id'] ?? '',
      orderGroupId: map['orderGroupId'] ?? '',
      businessId: map['businessId'] ?? '',
      customerId: map['customerId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      subTotal: (map['subTotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (map['shippingCost'] as num?)?.toDouble() ?? 0.0,
      storeTotal: (map['storeTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory OrderModel.empty() {
    return OrderModel(
      id: '',
      orderGroupId: '',
      businessId: '',
      customerId: '',
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      subTotal: 0.0,
      shippingCost: 0.0,
      storeTotal: 0.0,
    );
  }
}

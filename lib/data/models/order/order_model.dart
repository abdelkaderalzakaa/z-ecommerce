import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/cart_model.dart';

/// يمثل الطلب الخاص بمتجر واحد.
class OrderModel {
  final String id;
  final String businessId;
  final String customerId;
  final String? deliveryId;
  final DateTime createdAt;
  final OrderStatus status;
  
  final List<CartItemModel> items;

  // Financials
  final double subTotal;
  final double shippingCost;
  final double discountTotal;
  final double storeTotal; // storeTotal can be used as grandTotal

  // Payment
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;

  final AddressModel? shippingAddressSnapshot;

  OrderModel({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.subTotal,
    required this.shippingCost,
    required this.discountTotal,
    required this.storeTotal,
    required this.paymentMethod,
    required this.paymentStatus,
    this.deliveryId,
    this.shippingAddressSnapshot,
  });

  bool get isEmpty => id.isEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'customerId': customerId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'items': items.map((item) => item.toMap()).toList(),
      'subTotal': subTotal,
      'shippingCost': shippingCost,
      'discountTotal': discountTotal,
      'storeTotal': storeTotal,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      if (deliveryId != null) 'deliveryId': deliveryId,
      if (shippingAddressSnapshot != null)
        'shippingAddressSnapshot': shippingAddressSnapshot!.toMap(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return OrderModel(
      id: docId ?? map['id'] ?? '',
      deliveryId: map['deliveryId'],
      businessId: map['businessId'] ?? '',
      customerId: map['customerId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      items: map['items'] != null
          ? List<CartItemModel>.from(
              (map['items'] as List).map((x) => CartItemModel.fromMap(x)),
            )
          : [],
      subTotal: (map['subTotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (map['shippingCost'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (map['discountTotal'] as num?)?.toDouble() ?? 0.0,
      storeTotal: (map['storeTotal'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      shippingAddressSnapshot: map['shippingAddressSnapshot'] != null && map['shippingAddressSnapshot'] is Map
          ? AddressModel.fromMap(map['shippingAddressSnapshot'] as Map<String, dynamic>)
          : null,
    );
  }

  factory OrderModel.empty() {
    return OrderModel(
      id: '',
      deliveryId: null,
      businessId: '',
      customerId: '',
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      items: const [],
      subTotal: 0.0,
      shippingCost: 0.0,
      discountTotal: 0.0,
      storeTotal: 0.0,
      paymentMethod: PaymentMethod.cashOnDelivery,
      paymentStatus: PaymentStatus.pending,
      shippingAddressSnapshot: null,
    );
  }
}

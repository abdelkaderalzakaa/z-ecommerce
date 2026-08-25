import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/cart_model.dart';

/// يمثل الطلب الخاص بمتجر واحد مع دورة حياة تتبع متكاملة وإحداثيات جغرافية حية.
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

  // 📍 العناوين الجغرافية للطرفين (Customer & Store)
  final AddressModel? shippingAddressSnapshot;
  final AddressModel? storeAddressSnapshot;

  // 🛵 الإحداثيات والمسار اللحظي للسائق (Live GPS Tracking)
  final double? driverLatitude;
  final double? driverLongitude;
  final double? distanceKm;
  final int? estimatedMinutes;

  // Real-time Lifecycle & Tracking Timestamps
  final DateTime? confirmedAt;
  final DateTime? preparedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  // Real-time Driver Snapshot for Customer Tracking
  final String? deliveryDriverName;
  final String? deliveryDriverPhone;
  final String? deliveryNotes;

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
    this.storeAddressSnapshot,
    this.driverLatitude,
    this.driverLongitude,
    this.distanceKm,
    this.estimatedMinutes,
    this.confirmedAt,
    this.preparedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.deliveryDriverName,
    this.deliveryDriverPhone,
    this.deliveryNotes,
  });

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

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
      if (storeAddressSnapshot != null)
        'storeAddressSnapshot': storeAddressSnapshot!.toMap(),
      if (driverLatitude != null) 'driverLatitude': driverLatitude,
      if (driverLongitude != null) 'driverLongitude': driverLongitude,
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (estimatedMinutes != null) 'estimatedMinutes': estimatedMinutes,
      if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
      if (preparedAt != null) 'preparedAt': preparedAt!.toIso8601String(),
      if (shippedAt != null) 'shippedAt': shippedAt!.toIso8601String(),
      if (deliveredAt != null) 'deliveredAt': deliveredAt!.toIso8601String(),
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      if (deliveryDriverName != null) 'deliveryDriverName': deliveryDriverName,
      if (deliveryDriverPhone != null) 'deliveryDriverPhone': deliveryDriverPhone,
      if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return OrderModel(
      id: docId ?? map['id'] ?? '',
      deliveryId: map['deliveryId'],
      businessId: map['businessId'] ?? '',
      customerId: map['customerId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
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
      storeAddressSnapshot: map['storeAddressSnapshot'] != null && map['storeAddressSnapshot'] is Map
          ? AddressModel.fromMap(map['storeAddressSnapshot'] as Map<String, dynamic>)
          : null,
      driverLatitude: (map['driverLatitude'] as num?)?.toDouble(),
      driverLongitude: (map['driverLongitude'] as num?)?.toDouble(),
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt(),
      confirmedAt: map['confirmedAt'] != null ? DateTime.tryParse(map['confirmedAt']) : null,
      preparedAt: map['preparedAt'] != null ? DateTime.tryParse(map['preparedAt']) : null,
      shippedAt: map['shippedAt'] != null ? DateTime.tryParse(map['shippedAt']) : null,
      deliveredAt: map['deliveredAt'] != null ? DateTime.tryParse(map['deliveredAt']) : null,
      cancelledAt: map['cancelledAt'] != null ? DateTime.tryParse(map['cancelledAt']) : null,
      deliveryDriverName: map['deliveryDriverName'],
      deliveryDriverPhone: map['deliveryDriverPhone'],
      deliveryNotes: map['deliveryNotes'],
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

  OrderModel copyWith({
    String? id,
    String? businessId,
    String? customerId,
    String? deliveryId,
    DateTime? createdAt,
    OrderStatus? status,
    List<CartItemModel>? items,
    double? subTotal,
    double? shippingCost,
    double? discountTotal,
    double? storeTotal,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    AddressModel? shippingAddressSnapshot,
    AddressModel? storeAddressSnapshot,
    double? driverLatitude,
    double? driverLongitude,
    double? distanceKm,
    int? estimatedMinutes,
    DateTime? confirmedAt,
    DateTime? preparedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
    String? deliveryDriverName,
    String? deliveryDriverPhone,
    String? deliveryNotes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      deliveryId: deliveryId ?? this.deliveryId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      shippingCost: shippingCost ?? this.shippingCost,
      discountTotal: discountTotal ?? this.discountTotal,
      storeTotal: storeTotal ?? this.storeTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingAddressSnapshot: shippingAddressSnapshot ?? this.shippingAddressSnapshot,
      storeAddressSnapshot: storeAddressSnapshot ?? this.storeAddressSnapshot,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      preparedAt: preparedAt ?? this.preparedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      deliveryDriverName: deliveryDriverName ?? this.deliveryDriverName,
      deliveryDriverPhone: deliveryDriverPhone ?? this.deliveryDriverPhone,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
    );
  }
}

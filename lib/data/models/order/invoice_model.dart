import 'package:z_ecommerce/data/models/order/cart_model.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';



class InvoiceModel {
  final String id;

  final String storeId;

  final String customerId;

  final List<CartItemModel> items;

  final double subtotal;
  final double discount;
  final double shippingCost;
 
  final List<OrderStatusHistoryModel> history;

  final AddressModel shippingAddress;
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingCost,
    required this.history,
    required this.shippingAddress,
    required this.createdAt,
  });

  double get total => subtotal - discount + shippingCost;
 OrderStatus get status =>history.last.status ;
 bool get isEmpty => id.isEmpty;
  void updateStatus(
    OrderStatus newStatus,
    String userId,
    UserRole role, {
    String? note,
  }) {

    history.add(
      OrderStatusHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: newStatus,
        changeAt: DateTime.now(),
        changedBy: userId,
        userRole: role,
        note: note,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'customerId': customerId,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'shippingCost': shippingCost,
      'history': history.map((e) => e.toMap()).toList(),
      'shippingAddress': shippingAddress.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] ?? '',
      storeId: map['storeId'] ?? '',
      customerId: map['customerId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => CartItemModel.fromMap(e))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      shippingCost: (map['shippingCost'] ?? 0.0).toDouble(),
      history: (map['history'] as List<dynamic>?)
              ?.map((e) => OrderStatusHistoryModel.fromMap(e))
              .toList() ??
          [],
      shippingAddress: AddressModel.fromMap(map['shippingAddress'] ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory InvoiceModel.fromJson(Map<String, dynamic> map) => InvoiceModel.fromMap(map);

  /// إنشاء كائن InvoiceModel فارغ بقيم افتراضية
  factory InvoiceModel.empty() {
    return InvoiceModel(
      id: '',
      storeId: '',
      customerId: '',
      items: const [],
      shippingAddress: AddressModel.empty(),
      createdAt: DateTime.now(),
      subtotal: 0.0,
      discount: 0.0,
      shippingCost: 0.0,
      history: const [],
    );
  }
}

class OrderStatusHistoryModel {
  final String id;

  final OrderStatus status;

  final DateTime changeAt;

  final String changedBy;

  final UserRole userRole;

  final String? note;

  OrderStatusHistoryModel({
    required this.id,
    required this.status,
    required this.changeAt,
    required this.changedBy,
    required this.userRole,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.name,
      'changeAt': changeAt.toIso8601String(),
      'changedBy': changedBy,
      'userRole': userRole.name,
      'note': note,
    };
  }

  factory OrderStatusHistoryModel.fromMap(Map<String, dynamic> map) {
    return OrderStatusHistoryModel(
      id: map['id'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      changeAt: map['changeAt'] != null
          ? DateTime.parse(map['changeAt'])
          : DateTime.now(),
      changedBy: map['changedBy'] ?? '',
      userRole: UserRole.values.firstWhere(
        (e) => e.name == map['userRole'],
        orElse: () => UserRole.customer,
      ),
      note: map['note'],
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> map) => OrderStatusHistoryModel.fromMap(map);

  /// إنشاء كائن OrderStatusHistoryModel فارغ بقيم افتراضية
  factory OrderStatusHistoryModel.empty() {
    return OrderStatusHistoryModel(
      id: '',
      status: OrderStatus.pending,
      changeAt: DateTime.now(),
      changedBy: '',
      userRole: UserRole.customer,
    );
  }
}

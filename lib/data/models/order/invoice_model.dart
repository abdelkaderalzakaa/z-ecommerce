import 'package:z_ecommerce/data/models/cart_model.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  shipped,
  delivered,
  cancelled,
}

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
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/models/order/order_item_model.dart';
import 'package:z_ecommerce/data/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _customerOrders = [];
  List<OrderModel> _businessOrders = [];

  List<OrderModel> get customerOrders => _customerOrders;
  List<OrderModel> get businessOrders => _businessOrders;

  StreamSubscription<List<OrderModel>>? _customerOrdersSub;
  StreamSubscription<List<OrderModel>>? _businessOrdersSub;

  void listenToCustomerOrders(String customerId) {
    _customerOrdersSub?.cancel();
    _customerOrdersSub = _orderService.streamOrdersByCustomer(customerId).listen((orders) {
      _customerOrders = orders;
      notifyListeners();
    });
  }

  void listenToBusinessOrders(String businessId) {
    _businessOrdersSub?.cancel();
    _businessOrdersSub = _orderService.streamOrdersByStore(businessId).listen((orders) {
      _businessOrders = orders;
      notifyListeners();
    });
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    return await _orderService.getOrderItems(orderId);
  }

  @override
  void dispose() {
    _customerOrdersSub?.cancel();
    _businessOrdersSub?.cancel();
    super.dispose();
  }
}

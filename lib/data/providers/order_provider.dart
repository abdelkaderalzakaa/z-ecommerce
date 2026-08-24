import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/services/order_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _customerOrders = [];
  List<OrderModel> _businessOrders = [];
  List<OrderModel> _allOrders = [];

  List<OrderModel> get customerOrders => _customerOrders;
  List<OrderModel> get businessOrders => _businessOrders;
  List<OrderModel> get allOrders => _allOrders;

  StreamSubscription<List<OrderModel>>? _customerOrdersSub;
  StreamSubscription<List<OrderModel>>? _businessOrdersSub;
  StreamSubscription<List<OrderModel>>? _allOrdersSub;

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

  void listenToAllOrders() {
    _allOrdersSub?.cancel();
    _allOrdersSub = _orderService.streamAllOrders().listen((orders) {
      _allOrders = orders;
      notifyListeners();
    });
  }



  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    return await _orderService.updateOrderStatus(orderId: orderId, newStatus: newStatus);
  }

  Future<bool> updateOrderAddress(String orderId, AddressModel newAddress) async {
    return await _orderService.updateOrderAddress(orderId: orderId, newAddress: newAddress);
  }

  Future<bool> updateOrderDelivery(String orderId, String? deliveryId) async {
    return await _orderService.updateOrderDelivery(orderId: orderId, deliveryId: deliveryId);
  }

  @override
  void dispose() {
    _customerOrdersSub?.cancel();
    _businessOrdersSub?.cancel();
    _allOrdersSub?.cancel();
    super.dispose();
  }
}

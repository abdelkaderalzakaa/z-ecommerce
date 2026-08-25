import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_driver_model.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/data/services/delivery_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class DeliveryProvider with ChangeNotifier {
  final DeliveryService _deliveryService = DeliveryService();

  List<DeliveryModel> _deliveries = [];
  DeliveryModel _currentDelivery = DeliveryModel.empty();
  List<OrderModel> _assignedOrders = [];

  bool _isLoading = false;
  bool _isOrdersLoading = false;
  String _error = '';

  StreamSubscription<List<DeliveryModel>>? _deliveriesSubscription;
  StreamSubscription<DeliveryModel?>? _currentDeliverySubscription;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  // Getters
  List<DeliveryModel> get deliveries => _deliveries;
  DeliveryModel get currentDelivery => _currentDelivery;
  List<OrderModel> get assignedOrders => _assignedOrders;
  bool get isLoading => _isLoading;
  bool get isOrdersLoading => _isOrdersLoading;
  String get error => _error;
  bool get hasCurrentDelivery => _currentDelivery.isNotEmpty;

  // Filtered Orders Getters
  List<OrderModel> get pendingPickupOrders => _assignedOrders
      .where((o) => o.status == OrderStatus.confirmed || o.status == OrderStatus.preparing || o.status == OrderStatus.ready)
      .toList();

  List<OrderModel> get inTransitOrders => _assignedOrders
      .where((o) => o.status == OrderStatus.shipped)
      .toList();

  List<OrderModel> get deliveredOrders => _assignedOrders
      .where((o) => o.status == OrderStatus.delivered)
      .toList();

  List<OrderModel> get cancelledOrders => _assignedOrders
      .where((o) => o.status == OrderStatus.cancelled)
      .toList();

  // Financial Stats
  double get totalDeliveredEarnings => deliveredOrders.fold<double>(
        0.0,
        (sum, order) => sum + (order.shippingCost > 0 ? order.shippingCost : _currentDelivery.baseFee),
      );

  double get todayDeliveredEarnings {
    final now = DateTime.now();
    return deliveredOrders
        .where((o) =>
            o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day)
        .fold<double>(
          0.0,
          (sum, order) => sum + (order.shippingCost > 0 ? order.shippingCost : _currentDelivery.baseFee),
        );
  }

  DeliveryModel? getDeliveryById(String id) {
    try {
      return _deliveries.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  DeliveryProvider() {
    _initDeliveriesStream();
  }

  void _initDeliveriesStream() {
    _isLoading = true;
    notifyListeners();

    _deliveriesSubscription = _deliveryService.getDeliveries().listen(
      (deliveryList) {
        _deliveries = deliveryList;
        if (_currentDelivery.isNotEmpty) {
          final updated = deliveryList.firstWhere(
            (d) => d.id == _currentDelivery.id,
            orElse: () => _currentDelivery,
          );
          _currentDelivery = updated;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// تحميل وربط حساب المندوب/الشركة بالمستخدم المسجل
  Future<void> loadDeliveryForUser(String userId, {String? userName, String? userPhone}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final delivery = await _deliveryService.getDeliveryByUserId(userId);
      if (delivery != null) {
        _currentDelivery = delivery;
        listenToDeliveryOrders(delivery.id);
      } else {
        final now = DateTime.now();
        final fallback = DeliveryModel(
          id: userId,
          name: userName ?? 'كابتن التوصيل',
          phone: userPhone ?? '',
          type: DeliveryEntityType.individual,
          baseFee: 15.0,
          status: 'Active',
          isOnline: true,
          coverageAreas: const ['كافة المناطق'],
          vehicleDetails: 'دراجة نارية / سيارة',
          createdAt: now,
          updatedAt: now,
        );
        _currentDelivery = fallback;
        listenToDeliveryOrders(fallback.id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديد جهة التوصيل الحالية بالـ id
  void selectDelivery(String deliveryId) {
    final found = getDeliveryById(deliveryId);
    if (found != null) {
      _currentDelivery = found;
      listenToDeliveryOrders(deliveryId);
      notifyListeners();
    }
  }

  /// الاستماع اللحظي للطلبات المسندة لجهة التوصيل
  void listenToDeliveryOrders(String deliveryId) {
    _ordersSubscription?.cancel();
    _isOrdersLoading = true;
    notifyListeners();

    _ordersSubscription = _deliveryService.streamDeliveryOrders(deliveryId).listen(
      (orders) {
        _assignedOrders = orders;
        _isOrdersLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isOrdersLoading = false;
        notifyListeners();
      },
    );
  }

  /// تبديل حالة التواجد (Online / Offline)
  Future<void> toggleOnlineStatus() async {
    if (_currentDelivery.isEmpty) return;

    final newStatus = !_currentDelivery.isOnline;
    _currentDelivery = _currentDelivery.copyWith(isOnline: newStatus);
    notifyListeners();

    try {
      await _deliveryService.updateOnlineStatus(_currentDelivery.id, newStatus);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// تحديث حالة الطلب من قبل المندوب
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? deliveryNotes,
  }) async {
    try {
      await _deliveryService.updateOrderStatus(
        orderId,
        newStatus,
        deliveryNotes: deliveryNotes,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// حفظ أو تحديث بيانات جهة التوصيل
  Future<void> saveDelivery(DeliveryModel delivery) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _deliveryService.saveDelivery(delivery);
      if (_currentDelivery.id == delivery.id) {
        _currentDelivery = delivery;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة أو تعديل كابتن تابع للشركة
  Future<void> saveDriver(DeliveryDriverModel driver) async {
    if (_currentDelivery.isEmpty) return;
    try {
      await _deliveryService.saveDriver(_currentDelivery.id, driver);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// حذف كابتن من الأسطول
  Future<void> deleteDriver(String driverId) async {
    if (_currentDelivery.isEmpty) return;
    try {
      await _deliveryService.deleteDriver(_currentDelivery.id, driverId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// حذف جهة التوصيل
  Future<void> deleteDelivery(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _deliveryService.deleteDelivery(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _deliveriesSubscription?.cancel();
    _currentDeliverySubscription?.cancel();
    _ordersSubscription?.cancel();
    super.dispose();
  }
}

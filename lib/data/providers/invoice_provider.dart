import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/data/models/order/cart_model.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/services/order_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class InvoiceProvider with ChangeNotifier {
  final List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<InvoiceModel>>? _storeOrdersSubscription;
  StreamSubscription<List<InvoiceModel>>? _customerOrdersSubscription;

  List<InvoiceModel> get invoices => List.unmodifiable(_invoices);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get invoices filtered by store/business ID
  List<InvoiceModel> getInvoicesByStore(String storeId) {
    return _invoices.where((inv) => inv.storeId == storeId).toList();
  }

  /// Get invoices filtered by customer ID
  List<InvoiceModel> getInvoicesByCustomer(String customerId) {
    return _invoices.where((inv) => inv.customerId == customerId).toList();
  }

  /// Get invoice by unique ID
  InvoiceModel? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((inv) => inv.id == id);
    } catch (_) {
      return null;
    }
  }

  /// جلب طلبات متجر معين من السيرفس وتحديث الذاكرة
  Future<void> fetchOrdersByStore(String storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Mocked for now as we transition to OrderProvider
      final storeOrders = <InvoiceModel>[];
      for (var order in storeOrders) {
        final index = _invoices.indexWhere((i) => i.id == order.id);
        if (index >= 0) {
          _invoices[index] = order;
        } else {
          _invoices.add(order);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب طلبات عميل معين من السيرفس وتحديث الذاكرة
  Future<void> fetchOrdersByCustomer(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Mocked for now as we transition to OrderProvider
      final customerOrders = <InvoiceModel>[];
      for (var order in customerOrders) {
        final index = _invoices.indexWhere((i) => i.id == order.id);
        if (index >= 0) {
          _invoices[index] = order;
        } else {
          _invoices.add(order);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// الاستماع التلقائي المباشر لطلبات المتجر (Real-time Stream)
  void listenToStoreOrders(String storeId) {
    _storeOrdersSubscription?.cancel();
    // Mocked for now
    _storeOrdersSubscription = const Stream<List<InvoiceModel>>.empty().listen((_) {});
  }

  /// الاستماع التلقائي المباشر لطلبات العميل (Real-time Stream)
  void listenToCustomerOrders(String customerId) {
    _customerOrdersSubscription?.cancel();
    // Mocked for now
    _customerOrdersSubscription = const Stream<List<InvoiceModel>>.empty().listen((_) {});
  }

  /// Create and add a new invoice (Order creation via OrderService)
  Future<InvoiceModel?> createInvoice({
    required String storeId,
    required String customerId,
    required List<CartItemModel> items,
    required double subtotal,
    required double discount,
    required double shippingCost,
    required AddressModel shippingAddress,
    required String createdByUserId,
    required UserRole userRole,
    String? note,
  }) async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final id = 'inv_${now.millisecondsSinceEpoch}';

    final initialHistory = OrderStatusHistoryModel(
      id: 'hist_${now.millisecondsSinceEpoch}',
      status: OrderStatus.pending,
      changeAt: now,
      changedBy: createdByUserId,
      userRole: userRole,
      note: note ?? 'Order placed successfully',
    );

    final newInvoice = InvoiceModel(
      id: id,
      storeId: storeId,
      customerId: customerId,
      items: items,
      subtotal: subtotal,
      discount: discount,
      shippingCost: shippingCost,
      history: [initialHistory],
      shippingAddress: shippingAddress,
      createdAt: now,
    );

    // 1. إضافة محلياً فوراً لتحديث الواجهة فوراً
    _invoices.add(newInvoice);

    // 2. التخزين في السيرفس / Firestore
    // Mocked for now
    // final createdServerOrder = await _orderService.createOrder(newInvoice);

    _isLoading = false;
    notifyListeners();
    return newInvoice; // createdServerOrder ?? newInvoice;
  }

  /// Update invoice status and sync with OrderService
  Future<bool> updateInvoiceStatus({
    required String id,
    required OrderStatus newStatus,
    required String userId,
    required UserRole userRole,
    String? note,
  }) async {
    final invoice = getInvoiceById(id);
    if (invoice != null) {
      // 1. تحديث محلي بالسجل
      invoice.updateStatus(newStatus, userId, userRole, note: note);
      notifyListeners();

      // 2. تحديث في السيرفس
      // Mocked for now
      return true;
    }
    return false;
  }

  /// Delete or cancel an invoice via OrderService
  Future<bool> cancelInvoice(
    String id,
    String userId,
    UserRole role, {
    String? reason,
  }) async {
    return await updateInvoiceStatus(
      id: id,
      newStatus: OrderStatus.cancelled,
      userId: userId,
      userRole: role,
      note: reason ?? 'Order cancelled',
    );
  }

  @override
  void dispose() {
    _storeOrdersSubscription?.cancel();
    _customerOrdersSubscription?.cancel();
    super.dispose();
  }

  void generateInvoice({
    String? storeId,
    required List<CartItemModel> items,
    required discount,
    required int tax,
    required double shippingCost,
    required AddressModel shippingAddress,
  }) {}
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/order/invoice_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  /// إنشاء طلب جديد وتخزينه في Firebase / Local
  Future<InvoiceModel?> createOrder(InvoiceModel order) async {
    try {
      final docRef = _firestore.collection(_collection).doc(order.id);
      final data = order.toMap();
      await docRef.set(data);
      debugPrint('Order created successfully: ${order.id}');
      return order;
    } catch (e) {
      debugPrint('Error creating order in Firestore: $e');
      return order; // Return local instance on offline / local mode
    }
  }

  /// جلب كافة الطلبات لمتجر معين
  Future<List<InvoiceModel>> getOrdersByStore(String storeId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('storeId', isEqualTo: storeId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InvoiceModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching store orders: $e');
      return [];
    }
  }

  /// جلب كافة الطلبات الخاصة بعميل معين
  Future<List<InvoiceModel>> getOrdersByCustomer(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => InvoiceModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching customer orders: $e');
      return [];
    }
  }

  /// جلب تفاصيل طلب محدد بالمعرف
  Future<InvoiceModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return InvoiceModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching order by ID: $e');
    }
    return null;
  }

  /// تحديث حالة الطلب وإضافة عنصر إلى سجل التتبع (History)
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    required String changedByUserId,
    required UserRole userRole,
    String? note,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc(orderId);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        final order = InvoiceModel.fromMap(doc.data()!);
        order.updateStatus(newStatus, changedByUserId, userRole, note: note);

        await docRef.update({
          'history': order.history.map((e) => e.toMap()).toList(),
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
    return false;
  }

  /// إلغاء الطلب
  Future<bool> cancelOrder({
    required String orderId,
    required String userId,
    required UserRole userRole,
    String? reason,
  }) async {
    return updateOrderStatus(
      orderId: orderId,
      newStatus: OrderStatus.cancelled,
      changedByUserId: userId,
      userRole: userRole,
      note: reason ?? 'Order cancelled',
    );
  }

  /// الاستماع المباشر (Stream) لطلبات متجر معين
  Stream<List<InvoiceModel>> streamOrdersByStore(String storeId) {
    return _firestore
        .collection(_collection)
        .where('storeId', isEqualTo: storeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.data())).toList());
  }

  /// الاستماع المباشر (Stream) لطلبات عميل معين
  Stream<List<InvoiceModel>> streamOrdersByCustomer(String customerId) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.data())).toList());
  }
}

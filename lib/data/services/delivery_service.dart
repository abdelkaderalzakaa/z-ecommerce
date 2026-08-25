import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_driver_model.dart';
import 'package:z_ecommerce/data/models/delivery/delivery_model.dart';
import 'package:z_ecommerce/data/models/order/order_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إضافة أو تحديث شركة توصيل / مندوب
  Future<void> saveDelivery(DeliveryModel delivery) async {
    await _firestore
        .collection('deliveries')
        .doc(delivery.id)
        .set(delivery.toMap(), SetOptions(merge: true));
  }

  /// جلب كافة شركات التوصيل / المناديب
  Stream<List<DeliveryModel>> getDeliveries() {
    return _firestore
        .collection('deliveries')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DeliveryModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// جلب شركة/مندوب توصيل محدد بالـ id
  Future<DeliveryModel?> getDeliveryById(String id) async {
    final doc = await _firestore.collection('deliveries').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return DeliveryModel.fromMap(doc.data()!, docId: doc.id);
  }

  /// جلب جهة التوصيل المرتبطة بحساب مستخدم محدد (userId أو DocumentId)
  Future<DeliveryModel?> getDeliveryByUserId(String userId) async {
    final snapshot = await _firestore
        .collection('deliveries')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return DeliveryModel.fromMap(snapshot.docs.first.data(), docId: snapshot.docs.first.id);
    }

    // فحص إضافي في حال كان الـ Document ID يطابق الـ userId
    final directDoc = await _firestore.collection('deliveries').doc(userId).get();
    if (directDoc.exists && directDoc.data() != null) {
      return DeliveryModel.fromMap(directDoc.data()!, docId: directDoc.id);
    }

    return null;
  }

  /// استماع مباشر لجهة توصيل محددة
  Stream<DeliveryModel?> streamDelivery(String deliveryId) {
    return _firestore.collection('deliveries').doc(deliveryId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return DeliveryModel.fromMap(doc.data()!, docId: doc.id);
    });
  }

  /// جلب شركات توصيل محددة (مربوطة بمتجر معين)
  Stream<List<DeliveryModel>> getDeliveriesByIds(List<String> ids) {
    if (ids.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('deliveries')
        .where(FieldPath.documentId, whereIn: ids)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DeliveryModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// استماع مباشر لكافة الطلبات المسندة لجهة توصيل محددة
  Stream<List<OrderModel>> streamDeliveryOrders(String deliveryId) {
    return _firestore
        .collection('orders')
        .where('deliveryId', isEqualTo: deliveryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// تحديث حالة جاهزية التواجد (متاح أونلاين / أوفلاين)
  Future<void> updateOnlineStatus(String deliveryId, bool isOnline) async {
    await _firestore.collection('deliveries').doc(deliveryId).update({
      'isOnline': isOnline,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// تحديث حالة الطلب من قبل المندوب (تم الاستلام، في الطريق، تم التسليم، إلخ)
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? deliveryNotes,
  }) async {
    final Map<String, dynamic> updateData = {
      'status': newStatus.name,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (deliveryNotes != null && deliveryNotes.isNotEmpty) {
      updateData['deliveryNotes'] = deliveryNotes;
    }

    await _firestore.collection('orders').doc(orderId).update(updateData);
  }

  /// إضافة أو تحديث سائق/كابتن في أسطول شركة التوصيل
  Future<void> saveDriver(String deliveryId, DeliveryDriverModel driver) async {
    final delivery = await getDeliveryById(deliveryId);
    if (delivery == null) return;

    final updatedDrivers = List<DeliveryDriverModel>.from(delivery.drivers);
    final index = updatedDrivers.indexWhere((d) => d.id == driver.id);

    if (index >= 0) {
      updatedDrivers[index] = driver;
    } else {
      updatedDrivers.add(driver);
    }

    await _firestore.collection('deliveries').doc(deliveryId).update({
      'drivers': updatedDrivers.map((d) => d.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// حذف سائق من الأسطول
  Future<void> deleteDriver(String deliveryId, String driverId) async {
    final delivery = await getDeliveryById(deliveryId);
    if (delivery == null) return;

    final updatedDrivers = delivery.drivers.where((d) => d.id != driverId).toList();

    await _firestore.collection('deliveries').doc(deliveryId).update({
      'drivers': updatedDrivers.map((d) => d.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// حذف جهة توصيل
  Future<void> deleteDelivery(String id) async {
    await _firestore.collection('deliveries').doc(id).delete();
  }
}

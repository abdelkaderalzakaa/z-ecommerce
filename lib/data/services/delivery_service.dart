import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery/delivery_model.dart';

class DeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة أو تحديث شركة توصيل / مندوب
  Future<void> saveDelivery(DeliveryModel delivery) async {
    await _firestore
        .collection('deliveries')
        .doc(delivery.id)
        .set(delivery.toMap());
  }

  // جلب كافة شركات التوصيل / المناديب
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

  // جلب شركات توصيل محددة (مربوطة بمتجر معين مثلاً)
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

  // حذف جهة توصيل
  Future<void> deleteDelivery(String id) async {
    await _firestore.collection('deliveries').doc(id).delete();
  }
}

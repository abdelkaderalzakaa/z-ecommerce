import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';

/// 🎁 OfferService - إدارة العروض والخصومات والبنرات الترويجية في Firestore
///
/// مجموعة Firestore: `offers`
class OfferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'offers';

  // ==========================================
  // 📥 1. Real-time Streams (البث المباشر)
  // ==========================================

  /// البث المباشر لكافة العروض النشطة والفعالة في المنصة
  Stream<List<OfferModel>> streamActiveOffers() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OfferModel.fromMap({...doc.data(), 'id': doc.id}))
          .where((offer) => offer.isValid) // تصفية العروض السارية فقط بحسب التاريخ
          .toList();
    });
  }

  /// البث المباشر لجميع عروض متجر محدد (`businessId`)
  Stream<List<OfferModel>> streamOffersByStore(String businessId) {
    return _firestore
        .collection(_collection)
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OfferModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // ==========================================
  // 🔍 2. Queries & Actions (الاستعلامات والعمليات)
  // ==========================================

  /// جلب كافة العروض لمتجر محدد
  Future<List<OfferModel>> getOffersByStore(String businessId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('businessId', isEqualTo: businessId)
          .get();
      return snapshot.docs
          .map((doc) => OfferModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting offers for business ($businessId): $e');
      return [];
    }
  }

  /// البحث عن كوبون خصم بالكود (`couponCode`)
  Future<OfferModel?> getOfferByCouponCode(String couponCode, String businessId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('businessId', isEqualTo: businessId)
          .where('couponCode', isEqualTo: couponCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final offer = OfferModel.fromMap({
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        });
        return offer.isValid ? offer : null;
      }
    } catch (e) {
      debugPrint('Error fetching coupon code ($couponCode): $e');
    }
    return null;
  }

  /// ➕ إضافة عرض جديد وإرجاع المعرف المُنشأ
  Future<String?> addOffer(OfferModel offer) async {
    if (offer.isEmpty) {
      debugPrint('[OfferService] Blocked: Attempted to add an empty offer.');
      return null;
    }
    try {
      final docRef = await _firestore.collection(_collection).add(offer.toMap());
      debugPrint('Offer added successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding offer: $e');
      return null;
    }
  }

  /// ✏️ تحديث بيانات عرض قائم
  Future<bool> updateOffer(OfferModel offer) async {
    if (offer.isEmpty) {
      debugPrint('[OfferService] Blocked: Attempted to update with an empty offer.');
      return false;
    }
    try {
      await _firestore.collection(_collection).doc(offer.id).update(offer.toMap());
      debugPrint('Offer updated successfully: ${offer.id}');
      return true;
    } catch (e) {
      debugPrint('Error updating offer (${offer.id}): $e');
      return false;
    }
  }

  /// 🗑️ حذف عرض من Firestore
  Future<bool> deleteOffer(String offerId) async {
    try {
      await _firestore.collection(_collection).doc(offerId).delete();
      debugPrint('Offer deleted successfully: $offerId');
      return true;
    } catch (e) {
      debugPrint('Error deleting offer ($offerId): $e');
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/common/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'addresses';

  AddressService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  /// 🔹 حفظ أو تحديث عنوان في كولكشن addresses
  Future<void> saveAddress(AddressModel address) async {
    try {
      final docRef = _collection.doc(address.id);
      final addressData = address.toMap();
      addressData['updatedAt'] = DateTime.now().toIso8601String();

      await docRef.set(addressData, SetOptions(merge: true));

      // إذا كان هذا العنوان افتراضياً، قم بإلغاء الافتراضي عن باقي عناوين المستخدم
      if (address.isDefault && address.userId.isNotEmpty) {
        await _clearOtherDefaults(address.userId, address.id);
      }
    } catch (e) {
      debugPrint('Error saving address to Firestore: $e');
      rethrow;
    }
  }

  /// 🔹 جلب جميع عناوين مستخدم معين (الزبون، المتجر، الديليفري)
  Future<List<AddressModel>> getAddressesByUserId(String userId) async {
    try {
      if (userId.isEmpty) return [];

      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();

      final list = querySnapshot.docs
          .map((doc) => AddressModel.fromMap(doc.data(), docId: doc.id))
          .toList();

      // ترتيب بحسب الافتراضي ثم تاريخ الإنشاء
      list.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now());
      });

      return list;
    } catch (e) {
      debugPrint('Error fetching addresses for user $userId: $e');
      return [];
    }
  }

  /// 🔹 الاستماع اللحظي (Stream) لعناوين المستخدم
  Stream<List<AddressModel>> streamAddressesByUserId(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AddressModel.fromMap(doc.data(), docId: doc.id))
          .toList();

      list.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now());
      });

      return list;
    });
  }

  /// 🔹 الاستماع اللحظي لكافة عناوين المتاجر والأنشطة التجارية
  Stream<List<AddressModel>> streamAllBusinessAddresses() {
    return _collection
        .where('userType', isEqualTo: 'business')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AddressModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// 🔹 حذف عنوان بواسطة معرفه
  Future<void> deleteAddress(String addressId) async {
    try {
      await _collection.doc(addressId).delete();
    } catch (e) {
      debugPrint('Error deleting address $addressId: $e');
      rethrow;
    }
  }

  /// 🔹 تعيين عنوان كافتراضي وإلغاء الافتراضي عن باقي العناوين
  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      final batch = _firestore.batch();

      final userAddresses = await _collection
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in userAddresses.docs) {
        final isTarget = doc.id == addressId;
        batch.update(doc.reference, {
          'isDefault': isTarget,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error setting default address: $e');
      rethrow;
    }
  }

  /// 🔹 دالة مساعدة داخلية لضبط الافتراضي
  Future<void> _clearOtherDefaults(String userId, String currentAddressId) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        if (doc.id != currentAddressId) {
          batch.update(doc.reference, {'isDefault': false});
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing other default addresses: $e');
    }
  }
}

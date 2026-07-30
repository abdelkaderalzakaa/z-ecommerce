import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/company_settings_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class StoreService {
  FirebaseFirestore? get _firestore =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
  final AuthService _authService = AuthService();

  CollectionReference? get _storesRef => _firestore?.collection('stores');

  /// 1. Create Store & Store Owner (Called by Super Admin)
  Future<bool> createStoreWithOwner({
    required CompanySettingsModel store,
    required String ownerName,
    required String ownerEmail,
    required String ownerPassword,
    String? ownerPhone,
  }) async {
    try {
      if (_storesRef == null) return false;
      // 1. Create Store Document in Firestore
      final storeDocRef = _storesRef!.doc(store.id);
      final storeData = store.toJson();
      await storeDocRef.set(storeData);

      // 2. Create Store Owner Account in Firebase Auth & Firestore
      await _authService.createStoreOwnerAccount(
        name: ownerName,
        email: ownerEmail,
        password: ownerPassword,
        businessId: store.id,
        phoneNumber: ownerPhone,
      );

      return true;
    } catch (e) {
      throw Exception('فشل إنشاء المتجر وتعيين صاحبه: $e');
    }
  }

  /// 2. Get Store By ID
  Future<CompanySettingsModel?> getStoreById(String storeId) async {
    try {
      if (_storesRef == null) return null;
      final doc = await _storesRef!.doc(storeId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = storeId;
        return CompanySettingsModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 3. Get All Active Stores (For Customers)
  Future<List<CompanySettingsModel>> getActiveStores() async {
    try {
      if (_storesRef == null) return [];
      final querySnapshot = await _storesRef!
          .where('status', isEqualTo: 'Active')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CompanySettingsModel.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// 4. Get All Stores (For Super Admin)
  Future<List<CompanySettingsModel>> getAllStores() async {
    try {
      if (_storesRef == null) return [];
      final querySnapshot = await _storesRef!.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CompanySettingsModel.fromJson(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// 5. Update Store Settings (By Store Owner or Super Admin)
  Future<void> updateStoreSettings(
    String storeId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      if (_storesRef == null) return;
      updateData['updatedAt'] = DateTime.now().toIso8601String();
      await _storesRef!.doc(storeId).update(updateData);
    } catch (e) {
      throw Exception('فشل تحديث إعدادات المتجر: $e');
    }
  }

  /// 6. Update Store Status (Active/Inactive/Suspended)
  Future<void> updateStoreStatus(String storeId, String status) async {
    try {
      if (_storesRef == null) return;
      await _storesRef!.doc(storeId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('فشل تغيير حالة المتجر: $e');
    }
  }
}

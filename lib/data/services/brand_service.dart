import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/brand_model.dart';

class BrandService {
  FirebaseFirestore? get _firestore =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  CollectionReference? get _brandsRef => _firestore?.collection('store_brands');

  /// 1. Create a new brand in Firestore
  Future<BrandModel> createBrand(BrandModel brand) async {
    if (_brandsRef == null) {
      debugPrint('BrandService: Firestore is not initialized.');
      return brand;
    }
    try {
      final docRef = _brandsRef!.doc(brand.id.isNotEmpty ? brand.id : null);
      final finalId = docRef.id;
      final newBrand = BrandModel(
        id: finalId,
        businessId: brand.businessId,
        name: brand.name,
        logoUrl: brand.logoUrl,
        description: brand.description,
      );

      await docRef.set(newBrand.toJson());
      return newBrand;
    } catch (e) {
      debugPrint('Error creating brand in Firestore: $e');
      throw Exception('فشل إنشاء العلامة التجارية: $e');
    }
  }

  /// 2. Get all brands across all stores
  Future<List<BrandModel>> getAllBrands() async {
    if (_brandsRef == null) return [];
    try {
      final querySnapshot = await _brandsRef!.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return BrandModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      return [];
    }
  }

  /// 3. Get brands by store (businessId)
  Future<List<BrandModel>> getBrandsBybusinessId(String businessId) async {
    if (_brandsRef == null) return [];
    try {
      final querySnapshot = await _brandsRef!
          .where('businessId', isEqualTo: businessId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return BrandModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching brands for businessId $businessId: $e');
      return [];
    }
  }

  /// 4. Update brand data
  Future<void> updateBrand(String brandId, Map<String, dynamic> data) async {
    if (_brandsRef == null) return;
    try {
      await _brandsRef!.doc(brandId).update(data);
    } catch (e) {
      debugPrint('Error updating brand $brandId: $e');
      throw Exception('فشل تعديل العلامة التجارية: $e');
    }
  }

  /// 5. Delete brand
  Future<void> deleteBrand(String brandId) async {
    if (_brandsRef == null) return;
    try {
      await _brandsRef!.doc(brandId).delete();
    } catch (e) {
      debugPrint('Error deleting brand $brandId: $e');
      throw Exception('فشل حذف العلامة التجارية: $e');
    }
  }
}

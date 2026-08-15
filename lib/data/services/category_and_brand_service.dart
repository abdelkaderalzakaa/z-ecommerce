import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';

/// 🏷️ CategoryAndBrandService - إدارة الفئات/التصنيفات والماركات في Firestore
///
/// مجموعات Firestore:
/// - `categories` (الفئات)
/// - `brands` (الماركات)
class CategoryAndBrandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _categoriesCollection = 'categories';
  final String _brandsCollection = 'brands';

  // ==========================================
  // 📁 1. Categories (الفئات/التصنيفات)
  // ==========================================

  /// البث المباشر لجميع الفئات
  Stream<List<CategoryModel>> streamAllCategories() {
    return _firestore.collection(_categoriesCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// البث المباشر لفئات متجر/بزنس محدد (`businessId`)
  Stream<List<CategoryModel>> streamCategoriesByStore(String businessId) {
    return _firestore
        .collection(_categoriesCollection)
        .where('businessIds', arrayContains: businessId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// جلب جميع الفئات العامة وفئات البزنس المحدد
  Future<List<CategoryModel>> getCategories({String? businessId}) async {
    try {
      Query query = _firestore.collection(_categoriesCollection);
      final snapshot = await query.get();
      final all = snapshot.docs
          .map((doc) => CategoryModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      if (businessId != null) {
        return all.where((c) => c.isGlobal || c.businessIds.contains(businessId)).toList();
      }
      return all;
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  /// ➕ إضافة فئة/تصنيف جديد
  Future<String?> addCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore.collection(_categoriesCollection).add(category.toJson());
      debugPrint('Category added successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding category: $e');
      return null;
    }
  }

  /// ✏️ تحديث فئة/تصنيف
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _firestore.collection(_categoriesCollection).doc(category.id).update(category.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating category (${category.id}): $e');
      return false;
    }
  }

  /// 🗑️ حذف فئة/تصنيف
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_categoriesCollection).doc(categoryId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting category ($categoryId): $e');
      return false;
    }
  }

  // ==========================================
  // 🏷️ 2. Brands (الماركات والبراندات)
  // ==========================================

  /// البث المباشر لجميع الماركات
  Stream<List<BrandModel>> streamAllBrands() {
    return _firestore.collection(_brandsCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BrandModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// البث المباشر لماركات متجر/بزنس محدد (`businessId`)
  Stream<List<BrandModel>> streamBrandsByStore(String businessId) {
    return _firestore
        .collection(_brandsCollection)
        .where('businessIds', arrayContains: businessId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BrandModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// جلب جميع الماركات
  Future<List<BrandModel>> getBrands({String? businessId}) async {
    try {
      Query query = _firestore.collection(_brandsCollection);
      final snapshot = await query.get();
      final all = snapshot.docs
          .map((doc) => BrandModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      if (businessId != null) {
        return all.where((b) => b.isGlobal || b.businessIds.contains(businessId)).toList();
      }
      return all;
    } catch (e) {
      debugPrint('Error getting brands: $e');
      return [];
    }
  }

  /// ➕ إضافة ماركة جديدة
  Future<String?> addBrand(BrandModel brand) async {
    try {
      final docRef = await _firestore.collection(_brandsCollection).add(brand.toJson());
      debugPrint('Brand added successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding brand: $e');
      return null;
    }
  }

  /// ✏️ تحديث ماركة
  Future<bool> updateBrand(BrandModel brand) async {
    try {
      await _firestore.collection(_brandsCollection).doc(brand.id).update(brand.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating brand (${brand.id}): $e');
      return false;
    }
  }

  /// 🗑️ حذف ماركة
  Future<bool> deleteBrand(String brandId) async {
    try {
      await _firestore.collection(_brandsCollection).doc(brandId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting brand ($brandId): $e');
      return false;
    }
  }
}

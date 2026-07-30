import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';

class ProductCategoryService {
  FirebaseFirestore? get _firestore =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  CollectionReference? get _categoriesRef =>
      _firestore?.collection('product_categories');

  /// 1. Create a new product category in Firestore
  Future<CategoryModel> createCategory(CategoryModel category) async {
    if (_categoriesRef == null) {
      debugPrint('ProductCategoryService: Firestore is not initialized.');
      return category;
    }
    try {
      final docRef = _categoriesRef!.doc(
        category.id.isNotEmpty ? category.id : null,
      );
      final finalId = docRef.id;
      final newCategory = CategoryModel(
        id: finalId,
        businessId: category.businessId,
        label: category.label,
        bgColor: category.bgColor,
        icon: category.icon,
      );

      await docRef.set(newCategory.toJson());
      return newCategory;
    } catch (e) {
      debugPrint('Error creating product category: $e');
      throw Exception('فشل إنشاء فئة المنتجات: $e');
    }
  }

  /// 2. Get all product categories across the platform
  Future<List<CategoryModel>> getAllCategories() async {
    if (_categoriesRef == null) return [];
    try {
      final querySnapshot = await _categoriesRef!.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CategoryModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching product categories: $e');
      return [];
    }
  }

  /// 3. Get product categories by store (businessId)
  Future<List<CategoryModel>> getCategoriesBybusinessId(
    String businessId,
  ) async {
    if (_categoriesRef == null) return [];
    try {
      final querySnapshot = await _categoriesRef!
          .where('businessId', isEqualTo: businessId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CategoryModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories for businessId $businessId: $e');
      return [];
    }
  }

  /// 4. Get product category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    if (_categoriesRef == null) return null;
    try {
      final doc = await _categoriesRef!.doc(categoryId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CategoryModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching category $categoryId: $e');
      return null;
    }
  }

  /// 5. Update category data
  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    if (_categoriesRef == null) return;
    try {
      await _categoriesRef!.doc(categoryId).update(data);
    } catch (e) {
      debugPrint('Error updating category $categoryId: $e');
      throw Exception('فشل تعديل الفئة: $e');
    }
  }

  /// 6. Delete category
  Future<void> deleteCategory(String categoryId) async {
    if (_categoriesRef == null) return;
    try {
      await _categoriesRef!.doc(categoryId).delete();
    } catch (e) {
      debugPrint('Error deleting category $categoryId: $e');
      throw Exception('فشل حذف الفئة: $e');
    }
  }
}

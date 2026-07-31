import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';

/// 🛍️ ProductService - إدارة المنتجات في Firestore
///
/// مجموعة Firestore: `products`
/// ترتبط المنتجات بالمتجر عبر `businessId` وبالتصنيف عبر `categoryId` والماركة عبر `brandId`
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // ==========================================
  // 📥 1. Real-time Streams (البث المباشر للمنتجات)
  // ==========================================

  /// البث المباشر لجميع المنتجات في المنصة
  Stream<List<ProductModel>> streamAllProducts() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// البث المباشر لمنتجات متجر/بزنس محدد (`businessId`)
  Stream<List<ProductModel>> streamProductsByStore(String businessId) {
    return _firestore
        .collection(_collection)
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// البث المباشر لمنتجات قسم/تصنيف محدد (`categoryId`)
  Stream<List<ProductModel>> streamProductsByCategory(String categoryId) {
    return _firestore
        .collection(_collection)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// البث المباشر للمنتجات المميزة (`isFeatured = true`)
  Stream<List<ProductModel>> streamFeaturedProducts() {
    return _firestore
        .collection(_collection)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  // ==========================================
  // 🔍 2. Queries & CRUD Operations (الاستعلامات والعمليات)
  // ==========================================

  /// جلب جميع المنتجات دفعة واحدة
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting all products: $e');
      return [];
    }
  }

  /// جلب منتج محدد عبر المعرف `productId`
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      if (doc.exists && doc.data() != null) {
        return ProductModel.fromMap(doc.data()!, docId: doc.id);
      }
    } catch (e) {
      debugPrint('Error getting product by ID ($productId): $e');
    }
    return null;
  }

  /// جلب منتجات متجر محدد (`businessId`)
  Future<List<ProductModel>> getProductsByStore(String businessId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('businessId', isEqualTo: businessId)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting products for business ($businessId): $e');
      return [];
    }
  }

  /// ➕ إضافة منتج جديد وإرجاع المعرف المُنشأ
  Future<String?> addProduct(ProductModel product) async {
    try {
      final docRef = await _firestore.collection(_collection).add(product.toMap());
      debugPrint('Product added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return null;
    }
  }

  /// ✏️ تحديث بيانات منتج قائم
  Future<bool> updateProduct(ProductModel product) async {
    try {
      final updatedData = product.toMap();
      updatedData['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(_collection).doc(product.id).update(updatedData);
      debugPrint('Product updated successfully: ${product.id}');
      return true;
    } catch (e) {
      debugPrint('Error updating product (${product.id}): $e');
      return false;
    }
  }

  /// 🗑️ حذف منتج من Firestore
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
      debugPrint('Product deleted successfully: $productId');
      return true;
    } catch (e) {
      debugPrint('Error deleting product ($productId): $e');
      return false;
    }
  }

  // ==========================================
  // ⭐ 3. Sub-Operations (التقييمات والتفاعل)
  // ==========================================

  /// ⭐ إضافة تقييم ومراجعة جديدة للمنتج (`RatedUser`)
  Future<bool> addRatingToProduct({
    required String productId,
    required RatedUser rating,
  }) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'ratings': FieldValue.arrayUnion([rating.toMap()]),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding rating to product ($productId): $e');
      return false;
    }
  }
}

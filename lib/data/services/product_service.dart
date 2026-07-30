import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductService {
  FirebaseFirestore? get _firestore =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  CollectionReference? get _productsRef => _firestore?.collection('products');

  /// 1. Create a new product in Firestore
  Future<Product> createProduct(Product product) async {
    if (_productsRef == null) {
      debugPrint('ProductService: Firestore is not initialized.');
      return product;
    }
    try {
      final docRef = _productsRef!.doc(
        product.id.isNotEmpty ? product.id : null,
      );
      final finalId = docRef.id;
      final newProduct = Product(
        id: finalId,
        businessId: product.businessId,
        name: product.name,
        price: product.price,
        originalPrice: product.originalPrice,
        discountPercent: product.discountPercent,
        description: product.description,
        category: product.category,
        brand: product.brand,
        colors: product.colors,
        sizes: product.sizes,
        images: product.images,
        rating: product.rating,
        reviewsCount: product.reviewsCount,
        isNewArrival: product.isNewArrival,
        isTopSelling: product.isTopSelling,
        cardBgColor: product.cardBgColor,
      );

      await docRef.set(newProduct.toJson());
      return newProduct;
    } catch (e) {
      debugPrint('Error creating product in Firestore: $e');
      throw Exception('فشل إنشاء المنتج: $e');
    }
  }

  /// 2. Get all products across all stores
  Future<List<Product>> getAllProducts() async {
    if (_productsRef == null) return [];
    try {
      final querySnapshot = await _productsRef!.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products from Firestore: $e');
      return [];
    }
  }

  /// 3. Get products by store (businessId)
  Future<List<Product>> getProductsBybusinessId(String businessId) async {
    if (_productsRef == null) return [];
    try {
      final querySnapshot = await _productsRef!
          .where('businessId', isEqualTo: businessId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products for businessId $businessId: $e');
      return [];
    }
  }

  /// 4. Get product by ID
  Future<Product?> getProductById(String productId) async {
    if (_productsRef == null) return null;
    try {
      final doc = await _productsRef!.doc(productId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product $productId: $e');
      return null;
    }
  }

  /// 5. Update product data
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    if (_productsRef == null) return;
    try {
      await _productsRef!.doc(productId).update(data);
    } catch (e) {
      debugPrint('Error updating product $productId: $e');
      throw Exception('فشل تعديل المنتج: $e');
    }
  }

  /// 6. Delete product
  Future<void> deleteProduct(String productId) async {
    if (_productsRef == null) return;
    try {
      await _productsRef!.doc(productId).delete();
    } catch (e) {
      debugPrint('Error deleting product $productId: $e');
      throw Exception('فشل حذف المنتج: $e');
    }
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';
import 'package:z_ecommerce/data/services/product_service.dart';

/// 🛍️ ProductProvider - إدارة حالة المنتجات والربط بالواجهات والبزنس
class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _storeProducts = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<ProductModel>>? _productsSubscription;

  // Getters
  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get storeProducts => _storeProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // ⚡ 1. Real-time Streams Setup
  // ==========================================

  /// الاستماع للمنتجات بحسب البزنس/المتجر (`businessId`)
  void listenToProductsByStore(String businessId) {
    _isLoading = true;
    notifyListeners();

    _productsSubscription?.cancel();
    _productsSubscription = _productService.streamProductsByStore(businessId).listen(
      (products) {
        _storeProducts = products;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// الاستماع لكافة المنتجات في المنصة
  void listenToAllProducts() {
    _isLoading = true;
    notifyListeners();

    _productsSubscription?.cancel();
    _productsSubscription = _productService.streamAllProducts().listen(
      (products) {
        _allProducts = products;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ==========================================
  // 🔍 2. Filter & Fetch Helpers
  // ==========================================

  /// جلب جميع المنتجات دفعة واحدة
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allProducts = await _productService.getAllProducts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب منتجات متجر محدد (`businessId`)
  Future<List<ProductModel>> fetchProductsByBusiness(String businessId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _storeProducts = await _productService.getProductsByStore(businessId);
      return _storeProducts;
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// البحث عن منتج بواسطة المعرف `productId`
  Future<ProductModel?> fetchProductById(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedProduct = await _productService.getProductById(productId);
      return _selectedProduct;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// التصفية بحسب التصنيف `categoryId`
  List<ProductModel> getProductsByCategory(String categoryId) {
    return _allProducts.where((p) => p.categoryId == categoryId).toList();
  }

  /// المنتجات المميزة `isFeatured`
  List<ProductModel> get featuredProducts {
    return _allProducts.where((p) => p.isFeatured).toList();
  }

  /// المنتجات الأكثر مبيعاً `isTopSelling`
  List<ProductModel> get topSellingProducts {
    return _allProducts.where((p) => p.isTopSelling).toList();
  }

  // ==========================================
  // ✏️ 3. CRUD Actions (إضافة، تعديل، حذف)
  // ==========================================

  /// ➕ إضافة منتج جديد
  Future<bool> addProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docId = await _productService.addProduct(product);
      if (docId != null) {
        final newProduct = product.copyWith(id: docId);
        _allProducts.add(newProduct);
        _storeProducts.add(newProduct);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ✏️ تحديث منتج قائم
  Future<bool> updateProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _productService.updateProduct(product);
      if (success) {
        final index = _allProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) _allProducts[index] = product;

        final storeIndex = _storeProducts.indexWhere((p) => p.id == product.id);
        if (storeIndex != -1) _storeProducts[storeIndex] = product;

        if (_selectedProduct?.id == product.id) {
          _selectedProduct = product;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🗑️ حذف منتج
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _productService.deleteProduct(productId);
      if (success) {
        _allProducts.removeWhere((p) => p.id == productId);
        _storeProducts.removeWhere((p) => p.id == productId);
        if (_selectedProduct?.id == productId) {
          _selectedProduct = null;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ⭐ إضافة تقييم ومراجعة للمنتج (`RatedUser`)
  Future<bool> addRatingToProduct(String productId, RatedUser rating) async {
    final success = await _productService.addRatingToProduct(
      productId: productId,
      rating: rating,
    );
    if (success) {
      final index = _allProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final currentRatings = List<RatedUser>.from(_allProducts[index].ratings)..add(rating);
        _allProducts[index] = _allProducts[index].copyWith(ratings: currentRatings);
        notifyListeners();
      }
    }
    return success;
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}

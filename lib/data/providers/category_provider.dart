import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/services/category_and_brand_service.dart';

/// 📁 CategoryProvider - إدارة فئات/تصنيفات المنتجات وربطها بالبزنس والمنصة
class CategoryProvider extends ChangeNotifier {
  final CategoryAndBrandService _service = CategoryAndBrandService();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<CategoryModel>>? _categoriesSubscription;

  // Getters
  List<CategoryModel> get categories => _categories;
  CategoryModel? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // ⚡ 1. Real-time Streams Setup
  // ==========================================

  /// الاستماع لفئات متجر محدد (`businessId`)
  void listenToCategoriesByStore(String businessId) {
    _isLoading = true;
    notifyListeners();

    _categoriesSubscription?.cancel();
    _categoriesSubscription = _service.streamCategoriesByStore(businessId).listen(
      (categoriesList) {
        _categories = categoriesList;
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

  /// الاستماع لجميع الفئات في المنصة
  void listenToAllCategories() {
    _isLoading = true;
    notifyListeners();

    _categoriesSubscription?.cancel();
    _categoriesSubscription = _service.streamAllCategories().listen(
      (categoriesList) {
        _categories = categoriesList;
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
  // 🔍 2. Queries & Actions
  // ==========================================

  /// جلب الفئات لمتجر معين أو المنصة عامة
  Future<void> fetchCategories({String? businessId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _service.getCategories(businessId: businessId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديد الفئة المختارة حالياً
  void selectCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// ➕ إضافة فئة جديدة
  Future<bool> addCategory(CategoryModel category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _service.addCategory(category);
      if (id != null) {
        final newCategory = CategoryModel(
          id: id,
          businessIds: category.businessIds,
          label: category.label,
          bgColor: category.bgColor,
          icon: category.icon,
          isGlobal: category.isGlobal,
        );
        final index = _categories.indexWhere((c) => c.id == newCategory.id);
        if (index != -1) {
          _categories[index] = newCategory;
        } else {
          _categories.add(newCategory);
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

  /// 🔄 تفعيل أو تعطيل الفئة للمتجر
  Future<bool> toggleCategoryStatus(CategoryModel category, String storeId, bool enable) async {
    final List<String> updatedStoreIds = List<String>.from(category.businessIds);
    if (enable) {
      if (!updatedStoreIds.contains(storeId)) {
        updatedStoreIds.add(storeId);
      }
    } else {
      updatedStoreIds.remove(storeId);
    }
    final updatedCategory = category.copyWith(businessIds: updatedStoreIds);
    return updateCategory(updatedCategory);
  }

  /// ✏️ تحديث فئة قائمة
  Future<bool> updateCategory(CategoryModel category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.updateCategory(category);
      if (success) {
        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
        }
        if (_selectedCategory?.id == category.id) {
          _selectedCategory = category;
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

  /// 🗑️ حذف فئة
  Future<bool> deleteCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.deleteCategory(categoryId);
      if (success) {
        _categories.removeWhere((c) => c.id == categoryId);
        if (_selectedCategory?.id == categoryId) {
          _selectedCategory = null;
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

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    super.dispose();
  }
}

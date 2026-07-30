import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/product_category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final ProductCategoryService _categoryService = ProductCategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories([String? businessId]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final realCategories = businessId != null
          ? await _categoryService.getCategoriesBybusinessId(businessId)
          : await _categoryService.getAllCategories();

      _categories = realCategories;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      _error = e.toString();
      _categories = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addCategory(CategoryModel category) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await _categoryService.createCategory(category);
      _categories.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _categoryService.updateCategory(category.id, category.toJson());
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _categoryService.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

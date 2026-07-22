import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../fake_data/categories.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];

  CategoryProvider() {
    _loadCategories();
  }

  void _loadCategories() {
    // تحميل بيانات الفئات الوهمية
    _categories = fakeCategories;
    notifyListeners();
  }

  // Getters للوصول إلى القوائم
  List<CategoryModel> get categories => _categories;

  // دالة لجلب تفاصيل فئة معينة بواسطة الـ ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

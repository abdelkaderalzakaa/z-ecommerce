import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../fake_data/products.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _newArrivals = [];
  List<Product> _topSelling = [];
  List<Product> _discountedProducts = [];

  ProductProvider() {
    _loadProducts();
  }

  void _loadProducts() {
    // تحميل البيانات الوهمية
    _allProducts = fakeProducts;
    
    // تصفية المنتجات لقائمة أحدث الوصول (New Arrivals)
    _newArrivals = _allProducts.where((p) => p.isNewArrival).toList();
    
    // تصفية المنتجات لقائمة الأكثر مبيعاً (Top Selling)
    _topSelling = _allProducts.where((p) => p.isTopSelling).toList();
    
    // تصفية المنتجات التي عليها خصم
    _discountedProducts = _allProducts.where((p) => p.discountPercent != null && p.discountPercent! > 0).toList();
    
    notifyListeners();
  }

  // Getters للوصول إلى القوائم
  List<Product> get allProducts => _allProducts;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get topSelling => _topSelling;
  List<Product> get discountedProducts => _discountedProducts;

  // ==================== FILTER, SORT & PAGINATION STATE ====================
  double _minPrice = 0;
  double _maxPrice = 500;
  List<Color> _selectedColors = [];
  List<String> _selectedSizes = [];
  List<String> _selectedStyles = []; // from Figma "Dress Style"
  List<String> _selectedBrands = [];
  
  String _sortBy = 'Most Popular';
  int _currentPage = 1;
  final int _itemsPerPage = 9;
  String _searchQuery = '';

  // Getters for current filter state (useful for FilterSidebar to initialize sliders/checkboxes)
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  List<Color> get selectedColors => _selectedColors;
  List<String> get selectedSizes => _selectedSizes;
  List<String> get selectedStyles => _selectedStyles;
  List<String> get selectedBrands => _selectedBrands;
  String get sortBy => _sortBy;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  String get searchQuery => _searchQuery;

  // ==================== DYNAMIC GETTERS ====================
  
  List<Product> getFilteredAndSortedProducts(String? category, {String? brand, bool onSale = false}) {
    var list = _allProducts.where((p) {
      // 1. Category check
      if (category != null && category.isNotEmpty) {
        if (p.category.toLowerCase() != category.toLowerCase()) return false;
      }

      // 1.2. Brand check (Route level)
      if (brand != null && brand.isNotEmpty) {
        if (p.brand?.toLowerCase() != brand.toLowerCase()) return false;
      }
      
      // 1.5. Search Query check
      if (_searchQuery.isNotEmpty) {
        if (!p.name.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      }
      
      // 1.6 On Sale check
      if (onSale) {
        if (p.discountPercent == null || p.discountPercent! <= 0) return false;
      }

      // 2. Price check
      if (p.price < _minPrice || p.price > _maxPrice) return false;
      
      // 3. Colors check (Product must have at least one of the selected colors)
      if (_selectedColors.isNotEmpty) {
        bool hasColor = false;
        for (var c in p.colors) {
          if (_selectedColors.contains(c)) {
            hasColor = true;
            break;
          }
        }
        if (!hasColor) return false;
      }
      
      // 4. Sizes check
      if (_selectedSizes.isNotEmpty) {
        bool hasSize = false;
        for (var s in p.sizes) {
          if (_selectedSizes.contains(s)) {
            hasSize = true;
            break;
          }
        }
        if (!hasSize) return false;
      }
      
      // 5. Brands check (Sidebar filter level)
      if (_selectedBrands.isNotEmpty) {
        if (p.brand == null || !_selectedBrands.contains(p.brand)) return false;
      }
      
      return true;
    }).toList();

    // Sort
    if (_sortBy == 'Price: Low to High') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Newest') {
      list.sort((a, b) => a.isNewArrival ? -1 : (b.isNewArrival ? 1 : 0));
    } else {
      // Default: Most Popular
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  List<Product> getPaginatedProducts(String? category, {String? brand, bool onSale = false}) {
    final list = getFilteredAndSortedProducts(category, brand: brand, onSale: onSale);
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= list.length) return [];
    return list.skip(startIndex).take(_itemsPerPage).toList();
  }

  int getTotalPages(String? category, {String? brand, bool onSale = false}) {
    final list = getFilteredAndSortedProducts(category, brand: brand, onSale: onSale);
    return (list.length / _itemsPerPage).ceil();
  }

  // ==================== DYNAMIC FILTERS DATA ====================
  
  List<Color> getAvailableColors(String? category) {
    final Set<Color> colors = {};
    final products = category != null ? _allProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()) : _allProducts;
    for (var p in products) {
      colors.addAll(p.colors);
    }
    return colors.toList();
  }

  List<String> getAvailableSizes(String? category) {
    final Set<String> sizes = {};
    final products = category != null ? _allProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()) : _allProducts;
    for (var p in products) {
      sizes.addAll(p.sizes);
    }
    return sizes.toList();
  }

  // ==================== ACTIONS ====================

  void applyFilters({
    required double minP,
    required double maxP,
    required List<Color> colors,
    required List<String> sizes,
    required List<String> styles,
    required List<String> brands,
  }) {
    _minPrice = minP;
    _maxPrice = maxP;
    _selectedColors = colors;
    _selectedSizes = sizes;
    _selectedStyles = styles;
    _selectedBrands = brands;
    _currentPage = 1; // Reset to page 1 on new filters
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _currentPage = 1; // Reset to page 1 on new sort
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to page 1 on new search
    notifyListeners();
  }

  void setPage(int page, String? category, {String? brand, bool onSale = false}) {
    final total = getTotalPages(category, brand: brand, onSale: onSale);
    if (page > 0 && page <= total) {
      _currentPage = page;
      notifyListeners();
    }
  }

  // دالة لجلب المنتجات بناءً على الفئة (Original)
  List<Product> getProductsByCategory(String category) {
    return _allProducts
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // دالة لجلب تفاصيل منتج معين بواسطة الـ ID
  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // دالة لجلب مجموعة منتجات بواسطة قائمة من الـ IDs (مثل الويش ليست)
  List<Product> getProductsByIds(List<String> ids) {
    return _allProducts.where((p) => ids.contains(p.id)).toList();
  }

  // دالة لجلب منتجات ذات صلة (نفس الفئة مثلاً)
  List<Product> getRelatedProducts(Product product) {
    return _allProducts
        .where((p) => p.category == product.category && p.id != product.id)
        .take(4) // أخذ 4 منتجات كحد أقصى للـ Related Products
        .toList();
  }
}

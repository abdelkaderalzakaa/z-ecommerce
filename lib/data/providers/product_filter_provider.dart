import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/product/product_variant.dart';
import 'package:z_ecommerce/presentation/global/core/constants/product_enums.dart';
import 'package:z_ecommerce/data/providers/like_provider.dart';

/// Enum for Quick Filters and Highlight modes
enum QuickFilter {
  all,
  recommended,
  bestSellers,
  newArrivals,
  mostLiked,
  onSale,
  featured,
}

class ProductFilterProvider extends ChangeNotifier {
  String _searchQuery = '';
  QuickFilter _quickFilter = QuickFilter.all;

  final Set<String> _selectedBrandIds = {};
  final Set<String> _selectedCategoryIds = {};
  final Set<ProductSize> _selectedSizes = {};
  final Set<ProductColor> _selectedColors = {};
  final Set<ProductMaterial> _selectedMaterials = {};
  final Set<ProductType> _selectedTypes = {};

  RangeValues? _priceRange;

  // Getters
  String get searchQuery => _searchQuery;
  QuickFilter get quickFilter => _quickFilter;
  Set<String> get selectedBrandIds => Set.unmodifiable(_selectedBrandIds);
  Set<String> get selectedCategoryIds => Set.unmodifiable(_selectedCategoryIds);
  Set<ProductSize> get selectedSizes => Set.unmodifiable(_selectedSizes);
  Set<ProductColor> get selectedColors => Set.unmodifiable(_selectedColors);
  Set<ProductMaterial> get selectedMaterials => Set.unmodifiable(_selectedMaterials);
  Set<ProductType> get selectedTypes => Set.unmodifiable(_selectedTypes);
  RangeValues? get priceRange => _priceRange;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _quickFilter != QuickFilter.all ||
      _selectedBrandIds.isNotEmpty ||
      _selectedCategoryIds.isNotEmpty ||
      _selectedSizes.isNotEmpty ||
      _selectedColors.isNotEmpty ||
      _selectedMaterials.isNotEmpty ||
      _selectedTypes.isNotEmpty ||
      _priceRange != null;

  int get activeFiltersCount {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_quickFilter != QuickFilter.all) count++;
    count += _selectedBrandIds.length;
    count += _selectedCategoryIds.length;
    count += _selectedSizes.length;
    count += _selectedColors.length;
    count += _selectedMaterials.length;
    count += _selectedTypes.length;
    if (_priceRange != null) count++;
    return count;
  }

  /// Initializer when navigating with pre-selected category or brand
  void initializeWithDefaults({
    String? categoryId,
    String? categoryLabel,
    String? brandId,
    String? brandName,
    bool onSale = false,
    QuickFilter? initialQuickFilter,
  }) {
    bool changed = false;
    if (categoryId != null && categoryId.isNotEmpty && !_selectedCategoryIds.contains(categoryId)) {
      _selectedCategoryIds.add(categoryId);
      changed = true;
    } else if (categoryLabel != null && categoryLabel.isNotEmpty && !_selectedCategoryIds.contains(categoryLabel)) {
      _selectedCategoryIds.add(categoryLabel);
      changed = true;
    }

    if (brandId != null && brandId.isNotEmpty && !_selectedBrandIds.contains(brandId)) {
      _selectedBrandIds.add(brandId);
      changed = true;
    } else if (brandName != null && brandName.isNotEmpty && !_selectedBrandIds.contains(brandName)) {
      _selectedBrandIds.add(brandName);
      changed = true;
    }

    if (onSale && _quickFilter != QuickFilter.onSale) {
      _quickFilter = QuickFilter.onSale;
      changed = true;
    }
    
    if (initialQuickFilter != null && _quickFilter != initialQuickFilter) {
      _quickFilter = initialQuickFilter;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  // Setters & Toggle Actions
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setQuickFilter(QuickFilter filter) {
    if (_quickFilter == filter) {
      _quickFilter = QuickFilter.all;
    } else {
      _quickFilter = filter;
    }
    notifyListeners();
  }

  void toggleBrand(String brandIdOrName) {
    if (_selectedBrandIds.contains(brandIdOrName)) {
      _selectedBrandIds.remove(brandIdOrName);
    } else {
      _selectedBrandIds.add(brandIdOrName);
    }
    notifyListeners();
  }

  void selectBrandExclusive(String brandIdOrName) {
    if (_selectedBrandIds.length == 1 && _selectedBrandIds.contains(brandIdOrName)) {
      _selectedBrandIds.clear();
    } else {
      _selectedBrandIds.clear();
      _selectedBrandIds.add(brandIdOrName);
    }
    notifyListeners();
  }

  void toggleCategory(String categoryIdOrName) {
    if (_selectedCategoryIds.contains(categoryIdOrName)) {
      _selectedCategoryIds.remove(categoryIdOrName);
    } else {
      _selectedCategoryIds.add(categoryIdOrName);
    }
    notifyListeners();
  }

  void selectCategoryExclusive(String categoryIdOrName) {
    if (_selectedCategoryIds.length == 1 && _selectedCategoryIds.contains(categoryIdOrName)) {
      _selectedCategoryIds.clear();
    } else {
      _selectedCategoryIds.clear();
      _selectedCategoryIds.add(categoryIdOrName);
    }
    notifyListeners();
  }

  void toggleSize(ProductSize size) {
    if (_selectedSizes.contains(size)) {
      _selectedSizes.remove(size);
    } else {
      _selectedSizes.add(size);
    }
    notifyListeners();
  }

  void toggleColor(ProductColor color) {
    if (_selectedColors.contains(color)) {
      _selectedColors.remove(color);
    } else {
      _selectedColors.add(color);
    }
    notifyListeners();
  }

  void toggleMaterial(ProductMaterial material) {
    if (_selectedMaterials.contains(material)) {
      _selectedMaterials.remove(material);
    } else {
      _selectedMaterials.add(material);
    }
    notifyListeners();
  }

  void toggleType(ProductType type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    notifyListeners();
  }

  void setPriceRange(RangeValues? range) {
    _priceRange = range;
    notifyListeners();
  }

  /// Clear all active filters and reset to default
  void clearAllFilters() {
    _searchQuery = '';
    _quickFilter = QuickFilter.all;
    _selectedBrandIds.clear();
    _selectedCategoryIds.clear();
    _selectedSizes.clear();
    _selectedColors.clear();
    _selectedMaterials.clear();
    _selectedTypes.clear();
    _priceRange = null;
    notifyListeners();
  }

  /// Filter & Sort pipeline
  List<ProductModel> getFilteredProducts(
    List<ProductModel> allProducts, {
    LikeProvider? likeProvider,
  }) {
    List<ProductModel> list = allProducts.where((p) {
      // 0. Base Customer Visibility Rule
      if (!p.isValidForCustomer) return false;

      // 1. Search Query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final nameMatches = p.name.toLowerCase().contains(q);
        final descMatches = p.description.toLowerCase().contains(q);
        final catMatches = p.category.toLowerCase().contains(q);
        final brandMatches = p.brand != null && p.brand!.toLowerCase().contains(q);
        if (!nameMatches && !descMatches && !catMatches && !brandMatches) {
          return false;
        }
      }

      // 2. Quick Filter Criteria
      if (_quickFilter == QuickFilter.recommended && !p.isRecommended) {
        return false;
      }
      if (_quickFilter == QuickFilter.bestSellers && !p.isTopSelling) {
        return false;
      }
      if (_quickFilter == QuickFilter.featured && !p.isFeatured) {
        return false;
      }
      if (_quickFilter == QuickFilter.onSale) {
        final hasDiscount = p.activeDiscount != null ||
            p.offers.isNotEmpty ||
            (p.discountPercent != null && p.discountPercent! > 0);
        if (!hasDiscount) return false;
      }

      // 3. Brand Filter
      if (_selectedBrandIds.isNotEmpty) {
        final matchesBrandId = p.brandId != null && _selectedBrandIds.contains(p.brandId);
        final matchesBrandName = p.brand != null && _selectedBrandIds.contains(p.brand);
        if (!matchesBrandId && !matchesBrandName) {
          return false;
        }
      }

      // 4. Category Filter
      if (_selectedCategoryIds.isNotEmpty) {
        final matchesCatId = _selectedCategoryIds.contains(p.categoryId);
        final matchesCatName = _selectedCategoryIds.contains(p.category);
        if (!matchesCatId && !matchesCatName) {
          return false;
        }
      }

      // 5. Variants & Attributes (Sizes, Colors, Materials, Types)
      if (_selectedSizes.isNotEmpty) {
        final hasMatchingSize = p.variants.any(
          (v) => v.size != null && _selectedSizes.contains(v.size),
        );
        if (!hasMatchingSize) return false;
      }

      if (_selectedColors.isNotEmpty) {
        final hasMatchingColor = p.variants.any(
          (v) => v.color != null && _selectedColors.contains(v.color),
        );
        if (!hasMatchingColor) return false;
      }

      if (_selectedMaterials.isNotEmpty) {
        final hasMatchingMaterial = p.variants.any(
          (v) => v.material != null && _selectedMaterials.contains(v.material),
        );
        if (!hasMatchingMaterial) return false;
      }

      if (_selectedTypes.isNotEmpty) {
        final hasMatchingType = p.variants.any(
          (v) => v.type != null && _selectedTypes.contains(v.type),
        );
        if (!hasMatchingType) return false;
      }

      // 6. Price Range
      if (_priceRange != null) {
        final price = p.basePrice;
        if (price < _priceRange!.start || price > _priceRange!.end) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    if (_quickFilter == QuickFilter.newArrivals) {
      list.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    } else if (_quickFilter == QuickFilter.mostLiked) {
      list.sort((a, b) {
        final aLikes = likeProvider?.getLikesCount(a.id) ?? 0;
        final bLikes = likeProvider?.getLikesCount(b.id) ?? 0;
        if (bLikes != aLikes) {
          return bLikes.compareTo(aLikes);
        }
        return b.ratings.length.compareTo(a.ratings.length);
      });
    } else if (_quickFilter == QuickFilter.recommended) {
      list.sort((a, b) => (b.isRecommended ? 1 : 0).compareTo(a.isRecommended ? 1 : 0));
    } else if (_quickFilter == QuickFilter.bestSellers) {
      list.sort((a, b) => (b.isTopSelling ? 1 : 0).compareTo(a.isTopSelling ? 1 : 0));
    }

    return list;
  }
}

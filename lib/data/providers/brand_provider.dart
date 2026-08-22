import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/services/category_and_brand_service.dart';

/// 🏷️ BrandProvider - إدارة الماركات والبراندات وربطها بالبزنس والمنصة
class BrandProvider extends ChangeNotifier {
  final CategoryAndBrandService _service = CategoryAndBrandService();

  List<BrandModel> _brands = [];
  BrandModel? _selectedBrand;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<BrandModel>>? _brandsSubscription;

  // Getters
  List<BrandModel> get brands => _brands.isNotEmpty ? _brands : [];
  BrandModel? get selectedBrand => _selectedBrand;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // ⚡ 1. Real-time Streams Setup
  // ==========================================

  /// الاستماع لماركات متجر محدد (`businessId`)
  void listenToBrandsByStore(String businessId) {
    _isLoading = true;
    notifyListeners();

    _brandsSubscription?.cancel();
    _brandsSubscription = _service
        .streamBrandsByStore(businessId)
        .listen(
          (brandsList) {
            _brands = brandsList.isNotEmpty ? brandsList : [];
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

  /// الاستماع لجميع الماركات في المنصة
  void listenToAllBrands() {
    _isLoading = true;
    notifyListeners();

    _brandsSubscription?.cancel();
    _brandsSubscription = _service.streamAllBrands().listen(
      (brandsList) {
        _brands = brandsList.isNotEmpty ? brandsList : [];
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

  /// جلب الماركات لمتجر معين أو المنصة عامة
  Future<void> fetchBrands({String? businessId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _service.getBrands(businessId: businessId);
      _brands = fetched.isNotEmpty ? fetched : [];
    } catch (e) {
      _errorMessage = e.toString();
      _brands = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديد الماركة المختارة حالياً
  void selectBrand(BrandModel? brand) {
    _selectedBrand = brand;
    notifyListeners();
  }

  /// ➕ إضافة ماركة جديدة
  Future<bool> addBrand(BrandModel brand) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newId = await _service.addBrand(brand);
      if (newId != null) {
        final newBrand = brand.copyWith(id: newId);
        _brands = [..._brands, newBrand];
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// ✏️ تحديث ماركة
  Future<bool> updateBrand(BrandModel brand) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.updateBrand(brand);
      if (success) {
        final index = _brands.indexWhere((b) => b.id == brand.id);
        if (index != -1) {
          _brands[index] = brand;
          notifyListeners();
        }
        return true;
      } else {
        // Fallback for memory list if offline
        final index = _brands.indexWhere((b) => b.id == brand.id);
        if (index != -1) {
          _brands[index] = brand;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      final index = _brands.indexWhere((b) => b.id == brand.id);
      if (index != -1) {
        _brands[index] = brand;
        notifyListeners();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  /// 🔄 تفعيل أو إيقاف ماركة لمتجر محدد
  Future<bool> toggleBrandStatus(
    BrandModel brand,
    String businessId,
    bool enable,
  ) async {
    final currentIds = List<String>.from(brand.businessIds);
    if (enable) {
      if (!currentIds.contains(businessId)) {
        currentIds.add(businessId);
      }
    } else {
      currentIds.remove(businessId);
    }
    final updatedBrand = brand.copyWith(businessIds: currentIds);
    return await updateBrand(updatedBrand);
  }

  /// 🗑️ حذف ماركة
  Future<bool> deleteBrand(String brandId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.deleteBrand(brandId);
      if (success) {
        _brands.removeWhere((b) => b.id == brandId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  @override
  void dispose() {
    _brandsSubscription?.cancel();
    super.dispose();
  }
}

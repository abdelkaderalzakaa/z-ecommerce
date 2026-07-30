import 'package:flutter/material.dart';
import '../models/brand_model.dart';
import '../services/brand_service.dart';

class BrandProvider extends ChangeNotifier {
  final BrandService _brandService = BrandService();

  List<BrandModel> _brands = [];
  bool _isLoading = false;
  String? _error;

  List<BrandModel> get brands => _brands;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BrandProvider() {
    fetchBrands();
  }

  Future<void> fetchBrands([String? businessId]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final realBrands = businessId != null
          ? await _brandService.getBrandsBybusinessId(businessId)
          : await _brandService.getAllBrands();

      _brands = realBrands;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      _error = e.toString();
      _brands = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBrand(BrandModel brand) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await _brandService.createBrand(brand);
      _brands.insert(0, created);
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

  Future<bool> updateBrand(BrandModel brand) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _brandService.updateBrand(brand.id, brand.toJson());
      final index = _brands.indexWhere((b) => b.id == brand.id);
      if (index != -1) {
        _brands[index] = brand;
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

  Future<bool> deleteBrand(String brandId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _brandService.deleteBrand(brandId);
      _brands.removeWhere((b) => b.id == brandId);
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

import 'package:flutter/material.dart';
import '../models/company_settings_model.dart';
import '../fake_data/company.dart';
import '../services/store_service.dart';

class CompanyProvider extends ChangeNotifier {
  final StoreService _storeService = StoreService();
  CompanySettingsModel? _companySettings;
  bool _isLoading = false;
  String? _error;

  CompanySettingsModel? get companySettings => _companySettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CompanyProvider() {
    loadCompanySettings();
  }

  Future<void> loadCompanySettings([String? storeId]) async {
    _isLoading = true;
    _error = null;
    Future.microtask(notifyListeners);

    try {
      if (storeId != null) {
        final realStore = await _storeService.getStoreById(storeId);
        if (realStore != null) {
          _companySettings = realStore;
        } else {
          final found = fakeCompanies.where((company) => company.id == storeId).toList();
          _companySettings = found.isNotEmpty ? found.first : fakeCompanies.first;
        }
      } else {
        final activeStores = await _storeService.getActiveStores();
        if (activeStores.isNotEmpty) {
          _companySettings = activeStores.first;
        } else {
          _companySettings = fakeCompanies.first;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _companySettings = fakeCompanies.first;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchStore(String storeId) async {
    await loadCompanySettings(storeId);
  }

  void updateStoreTheme(StoreTheme newTheme) {
    if (_companySettings != null) {
      _companySettings = _companySettings!.copyWith(theme: newTheme);
      notifyListeners();
    }
  }

  bool companyExists(String id) {
    return fakeCompanies.any((c) => c.id == id);
  }
}


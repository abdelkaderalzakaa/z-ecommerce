import 'package:flutter/material.dart';
import '../models/company_settings_model.dart';
import '../fake_data/company.dart';

class CompanyProvider extends ChangeNotifier {
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
      // Simulating network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (storeId != null) {
        final found = fakeCompanies.where((company) => company.id == storeId).toList();
        if (found.isNotEmpty) {
          _companySettings = found.first;
        } else {
          _companySettings = null;
          _error = "Store not found";
        }
      } else {
        _companySettings = fakeCompanies.first;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
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

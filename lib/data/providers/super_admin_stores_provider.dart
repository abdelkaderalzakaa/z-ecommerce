import 'package:flutter/material.dart';
import '../models/company_settings_model.dart';
import '../models/user_model.dart';
import '../fake_data/company.dart';
import '../fake_data/users.dart';

class SuperAdminStoresProvider extends ChangeNotifier {
  List<CompanySettingsModel> _stores = [];
  List<UserModel> _storeOwners = [];
  bool _isLoading = false;
  String? _error;

  List<CompanySettingsModel> get stores => _stores;
  List<UserModel> get storeOwners => _storeOwners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalStores => _stores.length;
  int get activeStores => _stores.where((s) => s.status == 'Active').length;
  int get inactiveStores => _stores.where((s) => s.status == 'Inactive').length;

  SuperAdminStoresProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Load from fake data initially
      _stores = List.from(fakeCompanies);
      
      // Load store owners from fake users
      _storeOwners = fakeUsers.where((u) => u.role == UserRole.companyOwner).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createStoreAndOwner({
    required CompanySettingsModel newStore,
    required UserModel newOwner,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _stores.add(newStore);
      _storeOwners.add(newOwner);
      
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

  Future<void> toggleStoreStatus(String storeId, bool isActive) async {
    final index = _stores.indexWhere((s) => s.id == storeId);
    if (index >= 0) {
      // In a real app, this would be an API call, and we would copyWith the model.
      // Since our model is immutable without copyWith for status right now, we will create a new instance with the updated status.
      // Or simply update the list if we add copyWith to CompanySettingsModel.
      // For now, this is a placeholder.
      notifyListeners();
    }
  }
}

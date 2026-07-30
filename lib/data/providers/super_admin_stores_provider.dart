import 'package:flutter/material.dart';
import '../models/company_settings_model.dart';
import '../models/user_model.dart';
import '../fake_data/company.dart';
import '../services/store_service.dart';

class SuperAdminStoresProvider extends ChangeNotifier {
  final StoreService _storeService = StoreService();
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
      final realStores = await _storeService.getAllStores();
      _stores = realStores;
      _storeOwners = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stores: $e');
      _stores = [];
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createStoreAndOwner({
    required CompanySettingsModel newStore,
    required UserModel newOwner,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storeService.createStoreWithOwner(
        store: newStore,
        ownerName: newOwner.name,
        ownerEmail: newOwner.email,
        ownerPassword: password,
        ownerPhone: newOwner.phoneNumber,
      );

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

  Future<void> updateStoreStatus(String storeId, String newStatus) async {
    try {
      await _storeService.updateStoreStatus(storeId, newStatus);
      final index = _stores.indexWhere((s) => s.id == storeId);
      if (index >= 0) {
        _stores[index] = _stores[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleStoreStatus(String storeId, bool isActive) async {
    await updateStoreStatus(storeId, isActive ? 'Active' : 'Inactive');
  }
}

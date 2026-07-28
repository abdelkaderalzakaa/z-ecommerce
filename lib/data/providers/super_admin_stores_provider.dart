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

  Future<void> updateStoreStatus(String storeId, String newStatus) async {
    final index = _stores.indexWhere((s) => s.id == storeId);
    if (index >= 0) {
      final oldStore = _stores[index];
      final updatedStore = CompanySettingsModel(
        id: oldStore.id,
        category: oldStore.category,
        name: oldStore.name,
        addresses: oldStore.addresses,
        slogan: oldStore.slogan,
        description: oldStore.description,
        footerDescription: oldStore.footerDescription,
        orders: oldStore.orders,
        followers: oldStore.followers,
        followersUsers: oldStore.followersUsers,
        visitor: oldStore.visitor,
        heroCards: oldStore.heroCards,
        ratingStore: oldStore.ratingStore,
        theme: oldStore.theme,
        brands: oldStore.brands,
        currency: oldStore.currency,
        deliveryFee: oldStore.deliveryFee,
        aboutUs: oldStore.aboutUs,
        termsAndConditions: oldStore.termsAndConditions,
        privacyPolicy: oldStore.privacyPolicy,
        socials: oldStore.socials,
        paymentMethods: oldStore.paymentMethods,
        logoUrl: oldStore.logoUrl,
        coverUrl: oldStore.coverUrl,
        status: newStatus,
        createdAt: oldStore.createdAt,
        updatedAt: DateTime.now(),
        contactEmail: oldStore.contactEmail,
        contactPhone: oldStore.contactPhone,
      );
      _stores[index] = updatedStore;
      notifyListeners();
    }
  }

  Future<void> toggleStoreStatus(String storeId, bool isActive) async {
    await updateStoreStatus(storeId, isActive ? 'Active' : 'Inactive');
  }
}

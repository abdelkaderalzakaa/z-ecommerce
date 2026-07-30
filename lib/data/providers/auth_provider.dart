import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    _isLoading = true;
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        _currentUser = await _authService.getUserProfile(firebaseUser.uid);
      }
    } catch (e) {
      debugPrint('Error loading user session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Try Real Firebase Login
      _currentUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (firebaseError) {
      _isLoading = false;
      _errorMessage = firebaseError.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Login or Register with Google Account
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Customer Registration Priority
  Future<bool> register(String name, String email, String password, {String? phoneNumber}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create Customer in Firebase Auth & Firestore
      _currentUser = await _authService.signUpCustomer(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Create Super Admin Account
  Future<bool> createSuperAdminAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.createSuperAdminAccount(
        name: name,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
    } catch (e) {
      debugPrint('Error removing user session: $e');
    }

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() => logout();

  Future<bool> updateUserProfile({
    required String name,
    String? phoneNumber,
    Map<String, String>? socialLinks,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    final updatedUser = _currentUser!.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      socialLinks: socialLinks,
    );

    try {
      final Map<String, dynamic> updateData = {
        'name': name,
        'phoneNumber': phoneNumber,
      };
      if (socialLinks != null) {
        updateData['socialLinks'] = socialLinks;
      }
      await _authService.updateUserProfile(_currentUser!.id, updateData);
      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  void updateProfile(UserModel updatedUser) {
    if (_currentUser?.id == updatedUser.id) {
      _currentUser = updatedUser;
      notifyListeners();
    }
  }

  void addAddress(AddressModel address) {
    if (_currentUser != null) {
      final updatedAddresses = List<AddressModel>.from(_currentUser!.addresses)..add(address);
      _currentUser = _currentUser!.copyWith(addresses: updatedAddresses);
      notifyListeners();
    }
  }

  void updateAddress(AddressModel updatedAddress) {
    if (_currentUser != null) {
      final updatedAddresses = _currentUser!.addresses.map((address) {
        return address.id == updatedAddress.id ? updatedAddress : address;
      }).toList();
      _currentUser = _currentUser!.copyWith(addresses: updatedAddresses);
      notifyListeners();
    }
  }

  void deleteAddress(String addressId) {
    if (_currentUser != null) {
      final updatedAddresses = _currentUser!.addresses.where((addr) => addr.id != addressId).toList();
      _currentUser = _currentUser!.copyWith(addresses: updatedAddresses);
      notifyListeners();
    }
  }

  void toggleWishlist(String productId) {
    if (_currentUser != null) {
      final wishlist = List<String>.from(_currentUser!.wishlist);
      if (wishlist.contains(productId)) {
        wishlist.remove(productId);
      } else {
        wishlist.add(productId);
      }
      _currentUser = _currentUser!.copyWith(wishlist: wishlist);
      notifyListeners();
    }
  }
}

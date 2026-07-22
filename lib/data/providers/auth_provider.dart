import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../fake_data/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      if (savedEmail != null) {
        // Try to find the fake user, otherwise create a mock one to restore session
        _currentUser = authenticateFakeUser(savedEmail, 'password123') ?? UserModel(
          id: 'usr_restored',
          name: savedEmail.split('@').first,
          email: savedEmail,
          createdAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user session: $e');
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      // Check against fake users first
      final fakeUser = authenticateFakeUser(email, password);
      if (fakeUser != null) {
        _currentUser = fakeUser;
        _isLoading = false;
        
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email);
        }
        
        notifyListeners();
        return true;
      }
      
      // If not a fake user, but password is >= 6, we just mock login successfully
      if (password.length >= 6) {
        _currentUser = UserModel(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@').first,
          email: email,
          createdAt: DateTime.now(),
        );
        _isLoading = false;

        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email);
        }

        notifyListeners();
        return true;
      }
    }
    
    _isLoading = false;
    _errorMessage = 'Invalid email or password. Use sarah@example.com / password123';
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _currentUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = 'Please fill all fields and ensure password is 6+ chars';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
    } catch (e) {
      debugPrint('Error removing user session: $e');
    }

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
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

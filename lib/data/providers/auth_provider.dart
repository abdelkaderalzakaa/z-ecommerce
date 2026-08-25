import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/store/currency_store.dart';
import 'package:z_ecommerce/data/models/super_admin/super_admin_model.dart';
import 'package:z_ecommerce/data/models/customer/customer_model.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/services/address_service.dart';
import 'package:z_ecommerce/data/services/auth_service.dart';
import 'package:z_ecommerce/data/services/user_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _currentUser;
  BusinessModel? _currentBusiness;
  SuperAdminModel? _currentSuperAdmin;
  CustomerModel? _currentCustomer;

  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  BusinessModel? get currentBusiness => _currentBusiness;
  SuperAdminModel? get currentSuperAdmin => _currentSuperAdmin;
  CustomerModel? get currentCustomer => _currentCustomer;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuthStateListener();
  }

  /// الاستماع لمظلة حالة المصادقة من Firebase (Auto Sync)
  void _initAuthStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      _isLoading = true;

      try {
        if (firebaseUser != null) {
          final existingUser = await _userService.getUserById(firebaseUser.uid);
          if (existingUser != null) {
            await setCurrentUser(existingUser);
          } else {
            final newUser = _authService.mapFirebaseUserToUserModel(firebaseUser);
            await _userService.saveUser(newUser);
            await setCurrentUser(newUser);
          }
        } else {
          _currentUser = null;
          _currentBusiness = null;
          _currentSuperAdmin = null;
          _currentCustomer = null;
        }
      } catch (e) {
        debugPrint('Error in authStateListener: $e');
      } finally {
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// 1. تسجيل الدخول بواسطة البريد الإلكتروني وكلمة المرور عبر Firebase
  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.loginWithEmailAndPassword(
        email: emailOrPhone,
        password: password,
      );

      if (credential?.user != null) {
        final existingUser = await _userService.getUserById(
          credential!.user!.uid,
        );
        if (existingUser != null) {
          await setCurrentUser(existingUser);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 2. تسجيل حساب عميل جديد بالبريد الإلكتروني وكلمة المرور
  Future<bool> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        final now = DateTime.now();
        final user = UserModel(
          id: credential!.user!.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          role: UserRole.customer,
          createdAt: now,
        );
        await _userService.saveUser(user);

        final customer = CustomerModel(
          id: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          businessActivities: [],
          createdAt: now,
        );

        await _userService.saveCustomer(customer);
        await setCurrentUser(user);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 2.1 تسجيل حساب نشاط تجاري/متجر جديد بالبريد الإلكتروني وكلمة المرور
  Future<bool> registerBusiness({
    required String ownerName,
    required String email,
    required String password,
    required String phoneNumber,
    required BusinessType businessType,
    List<AddressModel> addresses = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential?.user != null) {
        final now = DateTime.now();
        final ownerUser = UserModel(
          id: credential!.user!.uid,
          name: ownerName,
          email: email,
          phoneNumber: phoneNumber,
          role: UserRole.businessOwner,
          businessId: credential.user!.uid,
          createdAt: now,
        );
        await _userService.saveUser(ownerUser);

        final business = BusinessModel(
          id: credential.user!.uid,
          ownerId: ownerUser.id,
          ownerName: ownerUser.name,
          ownerEmail: ownerUser.email,
          ownerPhone: ownerUser.phoneNumber,
          businessType: businessType,
          theme: ThemeAdmin.empty(),
          localization: LocalizationAdmin.empty(),
          currency: CurrencyStore.empty(),
          status: 'بانتظار التفعيل',
          createdAt: now,
        );

        await _userService.saveBusiness(business);

        // حفظ عناوين المتجر في كولكشن addresses
        for (final addr in addresses) {
          await AddressService().saveAddress(
            addr.copyWith(
              userId: credential.user!.uid,
              userType: 'business',
            ),
          );
        }

        await setCurrentUser(ownerUser);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 3. تسجيل الدخول بواسطة حساب Google (Google Sign-In)
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithGoogle();
      if (credential?.user != null) {
        final firebaseUser = credential!.user!;
        var user = await _userService.getUserById(firebaseUser.uid);

        if (user == null) {
          user = _authService.mapFirebaseUserToUserModel(firebaseUser);
          await _userService.saveUser(user);
          final customer = CustomerModel(
            id: user.id,
            name: user.name,
            email: user.email,
            phoneNumber: user.phoneNumber,
            avatarUrl: user.avatarUrl,
            businessActivities: [],
            createdAt: DateTime.now(),
          );
          await _userService.saveCustomer(customer);
        }

        await setCurrentUser(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 4. إرسال رابط إعادة تعيين كلمة المرور
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// تعيين المستخدم الحالي وتحديث بياناته التخصصية حسب الدور
  Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;
    _isLoading = true;

    try {
      if (user.role == UserRole.businessOwner && user.businessId != null) {
        _currentBusiness = await _userService.getBusinessById(user.businessId!);
      } else if (user.role == UserRole.superAdmin) {
        _currentSuperAdmin = await _userService.getSuperAdminById(user.id);
      } else if (user.role == UserRole.customer) {
        _currentCustomer = await _userService.getCustomerById(user.id);
      }
    } catch (e) {
      debugPrint('Error setting detailed user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة أو تحديث عنوان في كولكشن addresses المستقل
  Future<void> addAddress(AddressModel address) async {
    final effectiveUserId = _currentUser?.id ?? _currentCustomer?.id ?? '';
    if (effectiveUserId.isNotEmpty) {
      final addressToSave = address.copyWith(
        userId: effectiveUserId,
        userType: _currentUser?.role.name ?? 'customer',
      );
      await AddressService().saveAddress(addressToSave);
      notifyListeners();
    }
  }

  /// حذف عنوان من كولكشن addresses
  Future<void> deleteAddress(String addressId) async {
    await AddressService().deleteAddress(addressId);
    notifyListeners();
  }

  /// إضافة أو إزالة منتج من قائمة المفضلة للعميل الحالي
  Future<void> toggleWishlist(String productId) async {
    if (_currentCustomer != null) {
      final currentWishlist = List<String>.from(_currentCustomer!.wishlist);
      if (currentWishlist.contains(productId)) {
        currentWishlist.remove(productId);
      } else {
        currentWishlist.add(productId);
      }
      _currentCustomer = _currentCustomer!.copyWith(wishlist: currentWishlist);
      notifyListeners();
      await _userService.updateCustomerWishlist(
        customerId: _currentCustomer!.id,
        wishlist: currentWishlist,
      );
    }
  }

  /// 5. تعديل بيانات المستخدم الحالية (تعديل الملف الشخصي)
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );

      await _userService.saveUser(updatedUser);
      _currentUser = updatedUser;

      if (_currentCustomer != null) {
        _currentCustomer = _currentCustomer!.copyWith(
          name: updatedUser.name,
          phoneNumber: updatedUser.phoneNumber,
          avatarUrl: updatedUser.avatarUrl,
        );
        await _userService.saveCustomer(_currentCustomer!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 6. تحديث كلمة المرور
  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updatePassword(newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 7. حذف حساب المستخدم نهائياً من Firebase Auth و Firestore
  Future<bool> deleteAccount() async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _currentUser!.id;
      final role = _currentUser!.role;

      // 1. حذف من Firestore
      await _userService.deleteUserFromFirestore(userId, role);

      // 2. حذف من Firebase Auth
      await _authService.deleteAccount();

      // 3. مسح الحالة المحلية
      _currentUser = null;
      _currentBusiness = null;
      _currentSuperAdmin = null;
      _currentCustomer = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _currentBusiness = null;
    _currentSuperAdmin = null;
    _currentCustomer = null;
    notifyListeners();
  }

  /// Alias for signOut
  Future<void> signOut() => logout();
}

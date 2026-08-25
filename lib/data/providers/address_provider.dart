import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/common/address_model.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService;

  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<AddressModel>>? _addressesSubscription;
  String? _currentListeningUserId;

  AddressProvider({AddressService? addressService})
      : _addressService = addressService ?? AddressService();

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// إرجاع العنوان الافتراضي للمستخدم أو أول عنوان متوفر
  AddressModel? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  /// 🔹 الاستماع اللحظي لعناوين مستخدم معين (Realtime Stream)
  void listenToUserAddresses(String userId) {
    if (userId.isEmpty) {
      _addresses = [];
      notifyListeners();
      return;
    }

    if (_currentListeningUserId == userId && _addressesSubscription != null) {
      return;
    }

    _currentListeningUserId = userId;
    _addressesSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    _addressesSubscription = _addressService
        .streamAddressesByUserId(userId)
        .listen(
      (list) {
        _addresses = list;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('AddressProvider stream error: $error');
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// 🔹 جلب عناوين المستخدم لمرة واحدة
  Future<void> fetchUserAddresses(String userId) async {
    if (userId.isEmpty) {
      _addresses = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _addresses = await _addressService.getAddressesByUserId(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 حفظ أو تحديث عنوان في Firestore
  Future<bool> saveAddress({
    required String userId,
    required AddressModel address,
    String userType = 'customer',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final addressToSave = address.copyWith(
        userId: userId,
        userType: userType,
        isDefault: address.isDefault || _addresses.isEmpty,
        updatedAt: DateTime.now(),
        createdAt: address.createdAt ?? DateTime.now(),
      );

      await _addressService.saveAddress(addressToSave);

      // تحديث القائمة المحلية إن لم تكن عبر الـ Stream
      final index = _addresses.indexWhere((a) => a.id == addressToSave.id);
      if (index >= 0) {
        _addresses[index] = addressToSave;
      } else {
        _addresses.insert(0, addressToSave);
      }

      if (addressToSave.isDefault) {
        for (int i = 0; i < _addresses.length; i++) {
          if (_addresses[i].id != addressToSave.id) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
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

  /// 🔹 حذف عنوان
  Future<bool> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      await _addressService.deleteAddress(addressId);
      _addresses.removeWhere((a) => a.id == addressId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 🔹 تعيين عنوان كافتراضي
  Future<bool> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      await _addressService.setDefaultAddress(userId, addressId);
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == addressId,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _addressesSubscription?.cancel();
    super.dispose();
  }
}

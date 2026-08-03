import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/store/business_visit_model.dart';
import 'package:z_ecommerce/data/models/store/currency_store.dart';
import 'package:z_ecommerce/data/models/store/followers_store.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/services/user_service.dart';

class BusinessProvider with ChangeNotifier {
  final UserService _userService = UserService();

  List<BusinessModel> _businesses = [];
  BusinessModel? _businessSettings;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<BusinessModel>>? _businessSubscription;

  List<BusinessModel> get businesses => List.unmodifiable(_businesses);
  
  /// المتاجر الفعالة للعرض للزبائن (نشط أو نشط ومعتمد)
  List<BusinessModel> get activeBusinesses => _businesses.where((b) => b.isActive).toList();
  
  /// المتاجر المعتمدة (نشط ومعتمد)
  List<BusinessModel> get verifiedBusinesses => _businesses.where((b) => b.isVerified).toList();

  BusinessModel? get businessSettings => _businessSettings;
  BusinessModel? get selectedBusiness => _businessSettings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BusinessProvider() {
    _initStream();
  }

  /// الاستماع التلقائي المباشر لكافة المتاجر من UserService
  void _initStream() {
    _businessSubscription = _userService.streamBusinesses().listen(
      (list) {
        _businesses = list;
        if (_businessSettings != null) {
          final updated = list.firstWhere(
            (b) => b.id == _businessSettings!.id,
            orElse: () => _businessSettings!,
          );
          _businessSettings = updated;
        } else if (activeBusinesses.isNotEmpty) {
          _businessSettings = activeBusinesses.first;
        }
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  /// جلب كافة المتاجر من السيرفس
  Future<void> fetchBusinesses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _businesses = await _userService.getAllBusinesses();
      if (_businessSettings == null && _businesses.isNotEmpty) {
        _businessSettings = _businesses.first;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب متجر محدد وتعيينه كالمتجر الحالي المختار
  Future<void> selectBusiness(String businessId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final business = await _userService.getBusinessById(businessId);
      if (business != null) {
        _businessSettings = business;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حفظ أو تحديث نشاط تجاري عبر السيرفس
  Future<void> saveBusiness(BusinessModel business) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.saveBusiness(business);
      final index = _businesses.indexWhere((b) => b.id == business.id);
      if (index >= 0) {
        _businesses[index] = business;
      } else {
        _businesses.add(business);
      }
      if (_businessSettings?.id == business.id) {
        _businessSettings = business;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔄 تحديث حالة المتجر (نشط/غير نشط)
  Future<void> updateStoreStatus(String businessId, String newStatus) async {
    final index = _businesses.indexWhere((b) => b.id == businessId);
    if (index >= 0) {
      final businessMap = _businesses[index].toMap();
      businessMap['status'] = newStatus;
      final updatedBusiness = BusinessModel.fromMap(businessMap, businessId);
      await saveBusiness(updatedBusiness);
    }
  }

  // ==========================================
  // 🧩 Sub-Models Operations for Business
  // ==========================================

  /// 📱 تحديث وسائل التواصل للمتجر
  Future<void> updateSocials(String businessId, List<dynamic> socials) async {
    await _userService.updateBusinessSocials(
      businessId: businessId,
      socials: socials.cast(),
    );
    notifyListeners();
  }

  /// 👁️ إضافة زيارة جديدة للمتجر
  Future<void> addVisit(String businessId, BusinessVisitModel visit) async {
    await _userService.addBusinessVisit(
      businessId: businessId,
      visit: visit,
    );
    notifyListeners();
  }

  /// 🌐 تحديث إعدادات اللغة والترجمة للمتجر
  Future<void> updateLocalization(String businessId, LocalizationAdmin localization) async {
    await _userService.updateBusinessLocalization(
      businessId: businessId,
      localization: localization,
    );
    notifyListeners();
  }

  /// 🔱 تحديث إعدادات العملة للمتجر
  Future<void> updateCurrency(String businessId, CurrencyStore currency) async {
    await _userService.updateBusinessCurrency(
      businessId: businessId,
      currency: currency,
    );
    notifyListeners();
  }

  /// 🎨 تحديث الثيم والمظهر البصري للمتجر
  Future<void> updateTheme(String businessId, ThemeAdmin theme) async {
    await _userService.updateBusinessTheme(
      businessId: businessId,
      theme: theme,
    );
    notifyListeners();
  }

  /// 👍 زيادة أو إنقاص إعجابات المتجر (Likes)
  Future<void> incrementLikes(String businessId) async {
    await _userService.incrementBusinessLikes(businessId);
    notifyListeners();
  }

  Future<void> decrementLikes(String businessId) async {
    await _userService.decrementBusinessLikes(businessId);
    notifyListeners();
  }

  /// 👥 إضافة أو حذف متابع للمتجر
  Future<void> addFollower(String businessId, FollowersStore follower) async {
    await _userService.addFollowerToBusiness(
      businessId: businessId,
      follower: follower,
    );
    notifyListeners();
  }

  Future<void> removeFollower(String businessId, FollowersStore follower) async {
    await _userService.removeFollowerFromBusiness(
      businessId: businessId,
      follower: follower,
    );
    notifyListeners();
  }

  /// ⭐ إضافة تقييم جديد للمتجر
  Future<void> addRating(String businessId, RatedUser rating) async {
    await _userService.addRatingToBusiness(
      businessId: businessId,
      rating: rating,
    );
    notifyListeners();
  }

  /// 📍 تحديث عناوين المتجر
  Future<void> updateAddresses(String businessId, List<dynamic> addresses) async {
    await _userService.updateBusinessAddresses(
      businessId: businessId,
      addresses: addresses.cast(),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _businessSubscription?.cancel();
    super.dispose();
  }
}

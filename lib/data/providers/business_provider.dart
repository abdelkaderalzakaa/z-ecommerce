import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/store/business_visit_model.dart';
import 'package:z_ecommerce/data/models/store/currency_store.dart';
import 'package:z_ecommerce/data/models/store/followers_store.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/services/address_service.dart';
import 'package:z_ecommerce/data/services/geo_proximity_service.dart';
import 'package:z_ecommerce/data/services/user_service.dart';

class BusinessProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final AddressService _addressService = AddressService();
  final GeoProximityService _geoService = GeoProximityService();

  List<BusinessModel> _businesses = [];
  Map<String, List<AddressModel>> _businessAddressesMap = {};
  AddressModel? _activeCustomerLocation;
  GeoProximityTier? _selectedProximityFilter;
  bool _onlyDeliverableFilter = false;

  BusinessModel _businessSettings = BusinessModel.empty();
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<BusinessModel>>? _businessSubscription;
  StreamSubscription<List<AddressModel>>? _businessAddressesSubscription;

  List<BusinessModel> get businesses => List.unmodifiable(_businesses);
  
  /// المتاجر الفعالة للعرض للزبائن (نشط أو نشط ومعتمد)
  List<BusinessModel> get activeBusinesses => _businesses.where((b) => b.isActive).toList();
  
  /// المتاجر المعتمدة (نشط ومعتمد)
  List<BusinessModel> get verifiedBusinesses => _businesses.where((b) => b.isVerified).toList();

  BusinessModel get businessSettings => _businessSettings;
  BusinessModel get selectedBusiness => _businessSettings;
  bool get businessSettingsIsEmpty => _businessSettings.isEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // موقع الزبون النشط المعتمد للتحليل الجغرافي والتوصيل
  AddressModel? get activeCustomerLocation => _activeCustomerLocation;
  GeoProximityTier? get selectedProximityFilter => _selectedProximityFilter;
  bool get onlyDeliverableFilter => _onlyDeliverableFilter;
  Map<String, List<AddressModel>> get businessAddressesMap => _businessAddressesMap;

  BusinessModel? getBusinessById(String id) {
    try {
      return _businesses.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  BusinessProvider() {
    _initStream();
    _initBusinessAddressesStream();
  }

  /// الاستماع التلقائي المباشر لكافة المتاجر من UserService
  void _initStream() {
    _businessSubscription = _userService.streamBusinesses().listen(
      (list) {
        _businesses = list;
        if (_businessSettings.isNotEmpty) {
          final updated = list.firstWhere(
            (b) => b.id == _businessSettings.id,
            orElse: () => _businessSettings,
          );
          _businessSettings = updated;
        }
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  /// الاستماع التلقائي المباشر لكافة عناوين وفروع المتاجر لحساب القرب الجغرافي
  void _initBusinessAddressesStream() {
    _businessAddressesSubscription = _addressService.streamAllBusinessAddresses().listen(
      (addresses) {
        final Map<String, List<AddressModel>> map = {};
        for (final addr in addresses) {
          if (addr.userId.isNotEmpty) {
            map.putIfAbsent(addr.userId, () => []).add(addr);
          }
        }
        _businessAddressesMap = map;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error streaming business addresses: $e');
      },
    );
  }

  // =========================================================================
  // 🗺️ إدارة التحليل والتسهيلات الجغرافية والتوصيل (Geo Discovery Engine)
  // =========================================================================

  /// تعيين الموقع الجغرافي للزبون يدوياً أو تلقائياً من العنوان الافتراضي
  void setActiveCustomerLocation(AddressModel? location) {
    _activeCustomerLocation = location;
    notifyListeners();
  }

  /// تعيين فلتر القرب الجغرافي (في بلدتك / في قضائك / في محافظتك / الكل)
  void setProximityFilter(GeoProximityTier? tier) {
    _selectedProximityFilter = tier;
    notifyListeners();
  }

  /// تبديل فلتر المتاجر التي توصل فقط
  void toggleDeliverableFilter(bool? value) {
    _onlyDeliverableFilter = value ?? !_onlyDeliverableFilter;
    notifyListeners();
  }

  /// تحليل مدى قرب متجر معين من موقع الزبون الحالي
  BusinessGeoAnalysis analyzeBusiness(BusinessModel business, {bool isAr = true}) {
    final addresses = _businessAddressesMap[business.id] ?? [];
    return _geoService.analyzeBusinessProximity(
      business: business,
      businessAddresses: addresses,
      customerAddress: _activeCustomerLocation,
      isAr: isAr,
    );
  }

  /// الحصول على قائمة المتاجر مرتبة ومفلترة جغرافياً مع كافة المعايير
  List<BusinessGeoAnalysis> getGeoSortedBusinesses({
    String? categoryId,
    String? searchQuery,
    GeoProximityTier? filterTier,
    bool? onlyDeliverable,
    bool isAr = true,
  }) {
    final tier = filterTier ?? _selectedProximityFilter;
    final deliverOnly = onlyDeliverable ?? _onlyDeliverableFilter;

    // 1. فلترة المتاجر النشطة
    var filtered = activeBusinesses;

    // 2. فلترة البحث النصي
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((b) {
        final nameAr = b.localization.name.ar.toLowerCase();
        final nameEn = b.localization.name.en.toLowerCase();
        final sloganAr = b.localization.slogan.ar.toLowerCase();
        final sloganEn = b.localization.slogan.en.toLowerCase();
        return nameAr.contains(q) || nameEn.contains(q) || sloganAr.contains(q) || sloganEn.contains(q);
      }).toList();
    }

    // 3. الترتيب والتحليل الجغرافي المرجح
    var analyzedList = _geoService.sortBusinessesByCustomerLocation(
      businesses: filtered,
      businessAddressesMap: _businessAddressesMap,
      customerAddress: _activeCustomerLocation,
      isAr: isAr,
    );

    // 4. تطبيق فلتر رتبة القرب الجغرافي إن وجد
    if (tier != null) {
      analyzedList = analyzedList.where((item) => item.proximityTier == tier).toList();
    }

    // 5. تطبيق فلتر التوصيل المتاح إن وجد
    if (deliverOnly) {
      analyzedList = analyzedList.where((item) => item.canDeliver).toList();
    }

    return analyzedList;
  }

  /// إحصاء عدد المتاجر في رتبة جغرافية معينة
  int countBusinessesInTier(GeoProximityTier tier, {bool isAr = true}) {
    return activeBusinesses.where((b) {
      final addresses = _businessAddressesMap[b.id] ?? [];
      final analysis = _geoService.analyzeBusinessProximity(
        business: b,
        businessAddresses: addresses,
        customerAddress: _activeCustomerLocation,
        isAr: isAr,
      );
      return analysis.proximityTier == tier;
    }).length;
  }

  /// إحصاء عدد المتاجر التي توفر التوصيل
  int countDeliverableBusinesses({bool isAr = true}) {
    return activeBusinesses.where((b) {
      final addresses = _businessAddressesMap[b.id] ?? [];
      final analysis = _geoService.analyzeBusinessProximity(
        business: b,
        businessAddresses: addresses,
        customerAddress: _activeCustomerLocation,
        isAr: isAr,
      );
      return analysis.canDeliver;
    }).length;
  }

  // =========================================================================
  // 🏬 عمليات المتاجر الأساسية
  // =========================================================================

  /// جلب كافة المتاجر من السيرفس
  Future<void> fetchBusinesses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _businesses = await _userService.getAllBusinesses();
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

  /// مسح المتجر المختار حالياً
  void clearSelectedBusiness() {
    _businessSettings = BusinessModel.empty();
    notifyListeners();
  }

  /// تسجيل زيارة جديدة لمتجر
  Future<void> recordVisit(String businessId, BusinessVisitModel visit) async {
    await addVisit(businessId, visit);
  }

  /// 🌐 تحديث إعدادات اللغة والترجمة للمتجر
  Future<void> updateLocalization(String businessId, LocalizationAdmin localization) async {
    await _userService.updateBusinessLocalization(
      businessId: businessId,
      localization: localization,
    );
    if (_businessSettings.id == businessId) {
      _businessSettings = _businessSettings.copyWith(localization: localization);
    }
    final index = _businesses.indexWhere((b) => b.id == businessId);
    if (index != -1) {
      _businesses[index] = _businesses[index].copyWith(localization: localization);
    }
    notifyListeners();
  }

  /// 🔱 تحديث إعدادات العملة للمتجر
  Future<void> updateCurrency(String businessId, CurrencyStore currency) async {
    await _userService.updateBusinessCurrency(
      businessId: businessId,
      currency: currency,
    );
    if (_businessSettings.id == businessId) {
      _businessSettings = _businessSettings.copyWith(currency: currency);
    }
    final index = _businesses.indexWhere((b) => b.id == businessId);
    if (index != -1) {
      _businesses[index] = _businesses[index].copyWith(currency: currency);
    }
    notifyListeners();
  }

  /// 🎨 تحديث الثيم والمظهر البصري للمتجر
  Future<void> updateTheme(String businessId, ThemeAdmin theme) async {
    await _userService.updateBusinessTheme(
      businessId: businessId,
      theme: theme,
    );
    if (_businessSettings.id == businessId) {
      _businessSettings = _businessSettings.copyWith(theme: theme);
    }
    final index = _businesses.indexWhere((b) => b.id == businessId);
    if (index != -1) {
      _businesses[index] = _businesses[index].copyWith(theme: theme);
    }
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

  /// 💾 حفظ أو تحديث بيانات متجر كاملة
  Future<void> saveBusiness(BusinessModel business) async {
    await _userService.saveBusiness(business);
    if (_businessSettings.id == business.id) {
      _businessSettings = business;
    }
    final index = _businesses.indexWhere((b) => b.id == business.id);
    if (index != -1) {
      _businesses[index] = business;
    } else {
      _businesses.add(business);
    }
    notifyListeners();
  }

  /// 🔄 تحديث حالة المتجر
  Future<void> updateStoreStatus(String businessId, String newStatus) async {
    await _userService.updateBusinessStatus(businessId, newStatus);
    if (_businessSettings.id == businessId) {
      _businessSettings = _businessSettings.copyWith(status: newStatus);
    }
    final index = _businesses.indexWhere((b) => b.id == businessId);
    if (index != -1) {
      _businesses[index] = _businesses[index].copyWith(status: newStatus);
    }
    notifyListeners();
  }

  /// 🔒 تحديث صلاحيات وخصائص المتجر
  Future<void> updatePermissions(
    String businessId, {
    bool? allowFollow,
    bool? allowLikes,
    bool? allowReviews,
    bool? allowOffers,
    bool? isRecommended,
  }) async {
    final business = getBusinessById(businessId);
    if (business == null) return;

    final updated = business.copyWith(
      allowFollow: allowFollow,
      allowLikes: allowLikes,
      allowReviews: allowReviews,
      allowOffers: allowOffers,
      isRecommended: isRecommended,
    );

    await saveBusiness(updated);
  }

  /// 👁️ تسجيل زيارة لمتجر
  Future<void> addVisit(String businessId, BusinessVisitModel visit) async {
    final business = getBusinessById(businessId);
    if (business == null) return;
    final updated = business.copyWith(
      visits: [...business.visits, visit],
    );
    await saveBusiness(updated);
  }

  @override
  void dispose() {
    _businessSubscription?.cancel();
    _businessAddressesSubscription?.cancel();
    super.dispose();
  }
}

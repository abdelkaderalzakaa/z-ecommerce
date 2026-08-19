import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/services/offer_service.dart';

/// 🎁 OfferProvider - إدارة العروض والخصومات والبنرات الترويجية في التطبيق
class OfferProvider extends ChangeNotifier {
  final OfferService _offerService = OfferService();

  List<OfferModel> _activeOffers = [];
  List<OfferModel> _storeOffers = [];
  OfferModel? _appliedCoupon;

  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<OfferModel>>? _offersSubscription;

  // Getters
  List<OfferModel> get activeOffers => _activeOffers;
  List<OfferModel> get storeOffers => _storeOffers;
  OfferModel? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ==========================================
  // ⚡ 1. Real-time Streams Setup
  // ==========================================

  /// الاستماع لكافة العروض النشطة في المنصة (للبنرات الترويجية)
  void listenToActiveOffers() {
    _isLoading = true;
    notifyListeners();

    _offersSubscription?.cancel();
    _offersSubscription = _offerService.streamActiveOffers().listen(
      (offers) {
        _activeOffers = offers;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// الاستماع لعروض متجر محدد (`businessId`)
  void listenToStoreOffers(String businessId) {
    _isLoading = true;
    notifyListeners();

    _offersSubscription?.cancel();
    _offersSubscription = _offerService.streamOffersByStore(businessId).listen(
      (offers) {
        _storeOffers = offers;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ==========================================
  // 🏷️ 2. Coupon Validation & Business Logic
  // ==========================================

  /// تطبيق كود الخصم (Coupon Code) على السلة
  Future<bool> applyCouponCode(String code, String businessId, double cartTotal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final offer = await _offerService.getOfferByCouponCode(code, businessId);
      if (offer != null) {
        if (offer.minOrderAmount != null && cartTotal < offer.minOrderAmount!) {
          _errorMessage = 'الحد الأدنى لاستخدام الكوبون هو ${offer.minOrderAmount}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _appliedCoupon = offer;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'كوبون الخصم غير صحيح أو منتهي الصلاحية';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// إزالة الكوبون المطبق
  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  // ==========================================
  // ✏️ 3. CRUD Actions for Business Owners
  // ==========================================

  /// ➕ إضافة عرض جديد
  Future<bool> addOffer(OfferModel offer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docId = await _offerService.addOffer(offer);
      if (docId != null) {
        final newOffer = OfferModel.fromMap({...offer.toMap(), 'id': docId});
        final storeIndex = _storeOffers.indexWhere((o) => o.id == newOffer.id);
        if (storeIndex != -1) {
          _storeOffers[storeIndex] = newOffer;
        } else {
          _storeOffers.add(newOffer);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// ✏️ تحديث عرض قائم
  Future<bool> updateOffer(OfferModel offer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _offerService.updateOffer(offer);
      if (success) {
        final index = _storeOffers.indexWhere((o) => o.id == offer.id);
        if (index != -1) _storeOffers[index] = offer;

        final activeIndex = _activeOffers.indexWhere((o) => o.id == offer.id);
        if (activeIndex != -1) _activeOffers[activeIndex] = offer;

        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🗑️ حذف عرض
  Future<bool> deleteOffer(String offerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _offerService.deleteOffer(offerId);
      if (success) {
        _storeOffers.removeWhere((o) => o.id == offerId);
        _activeOffers.removeWhere((o) => o.id == offerId);
        if (_appliedCoupon?.id == offerId) {
          _appliedCoupon = null;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _offersSubscription?.cancel();
    super.dispose();
  }
}

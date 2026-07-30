import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../fake_data/offers.dart';

class OfferProvider extends ChangeNotifier {
  List<OfferModel> _offers = [];

  OfferProvider() {
    _loadOffers();
  }

  void _loadOffers() {
    _offers = fakeOffers;
    notifyListeners();
  }

  List<OfferModel> get allOffers => _offers;
  List<OfferModel> get offers => _offers;

  // ==================== CRUD OPERATIONS ====================

  void addOffer(OfferModel offer) {
    _offers.insert(0, offer);
    notifyListeners();
  }

  void updateOffer(OfferModel offer) {
    final index = _offers.indexWhere((o) => o.id == offer.id);
    if (index != -1) {
      _offers[index] = offer;
      notifyListeners();
    }
  }

  void deleteOffer(String offerId) {
    _offers.removeWhere((o) => o.id == offerId);
    notifyListeners();
  }

  List<OfferModel> getActiveOffers(String businessId) {
    return _offers
        .where((o) => o.isValid && o.businessId == businessId)
        .toList();
  }

  OfferModel? getOfferById(String businessId, String offerId) {
    try {
      return getActiveOffers(businessId).firstWhere((o) => o.id == offerId);
    } catch (_) {
      return null;
    }
  }

  OfferModel? getOfferForProduct(String businessId, String productId) {
    try {
      return getActiveOffers(businessId).firstWhere(
        (o) =>
            (o.type == 'product_gift' || o.type == 'buy_x_get_y') &&
            (o.productId == productId ||
                (o.productIds != null && o.productIds!.contains(productId))),
      );
    } catch (_) {
      return null;
    }
  }

  double calculateDiscount(
    String businessId,
    double subtotal,
    List<String> cartProductIds,
    String? couponCode,
  ) {
    double totalDiscount = 0;

    for (var offer in getActiveOffers(businessId)) {
      if (offer.type == 'percentage_discount' || offer.type == 'clearance') {
        if (offer.productIds != null &&
            offer.productIds!.any((id) => cartProductIds.contains(id))) {
          // For simplicity, applying discount to the whole subtotal if any product matches. In a real app, calculate per item.
          totalDiscount += subtotal * ((offer.discountPercent ?? 0) / 100);
        } else if (offer.productIds == null) {
          totalDiscount += subtotal * ((offer.discountPercent ?? 0) / 100);
        }
      } else if (offer.type == 'fixed_discount') {
        if (offer.minOrderAmount != null && subtotal >= offer.minOrderAmount!) {
          totalDiscount += offer.discountAmount ?? 0;
        } else if (offer.minOrderAmount == null) {
          totalDiscount += offer.discountAmount ?? 0;
        }
      } else if (offer.type == 'coupon' &&
          couponCode != null &&
          offer.couponCode == couponCode) {
        if (offer.discountPercent != null) {
          totalDiscount += subtotal * ((offer.discountPercent ?? 0) / 100);
        } else if (offer.discountAmount != null) {
          if (offer.minOrderAmount == null ||
              subtotal >= offer.minOrderAmount!) {
            totalDiscount += offer.discountAmount ?? 0;
          }
        }
      }
    }
    return totalDiscount;
  }

  bool hasFreeShipping(String businessId, double subtotal) {
    return getActiveOffers(businessId).any(
      (offer) =>
          offer.type == 'free_shipping' &&
          (offer.minOrderAmount == null || subtotal >= offer.minOrderAmount!),
    );
  }
}

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
  
  List<OfferModel> getActiveOffers(String companyId) {
    return _offers.where((o) => o.isValid && o.companyId == companyId).toList();
  }

  OfferModel? getOfferById(String companyId, String offerId) {
    try {
      return getActiveOffers(companyId).firstWhere((o) => o.id == offerId);
    } catch (_) {
      return null;
    }
  }

  OfferModel? getOfferForProduct(String companyId, String productId) {
    try {
      return getActiveOffers(companyId).firstWhere((o) => 
        (o.type == 'product_gift' || o.type == 'buy_x_get_y') && 
        (o.productId == productId || (o.productIds != null && o.productIds!.contains(productId)))
      );
    } catch (_) {
      return null;
    }
  }

  double calculateDiscount(String companyId, double subtotal, List<String> cartProductIds, String? couponCode) {
    double totalDiscount = 0;
    
    for (var offer in getActiveOffers(companyId)) {
      if (offer.type == 'percentage_discount' || offer.type == 'clearance') {
        if (offer.productIds != null && offer.productIds!.any((id) => cartProductIds.contains(id))) {
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
      } else if (offer.type == 'coupon' && couponCode != null && offer.couponCode == couponCode) {
        if (offer.discountPercent != null) {
          totalDiscount += subtotal * ((offer.discountPercent ?? 0) / 100);
        } else if (offer.discountAmount != null) {
          if (offer.minOrderAmount == null || subtotal >= offer.minOrderAmount!) {
            totalDiscount += offer.discountAmount ?? 0;
          }
        }
      }
    }
    return totalDiscount;
  }

  bool hasFreeShipping(String companyId, double subtotal) {
    return getActiveOffers(companyId).any((offer) => 
      offer.type == 'free_shipping' && 
      (offer.minOrderAmount == null || subtotal >= offer.minOrderAmount!)
    );
  }
}

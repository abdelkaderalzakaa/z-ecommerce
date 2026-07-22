import 'package:flutter/material.dart';
import '../models/store_visit_model.dart';

class UserVisitsProvider extends ChangeNotifier {
  // Keyed by storeId
  final Map<String, StoreVisitModel> _visits = {};

  String? _lastRecordedStoreId;

  Map<String, StoreVisitModel> get visits => _visits;

  StoreVisitModel? getVisit(String storeId) => _visits[storeId];

  void recordVisit(String storeId) {
    if (_lastRecordedStoreId == storeId) return; // Prevent spamming
    _lastRecordedStoreId = storeId;

    if (_visits.containsKey(storeId)) {
      final visit = _visits[storeId]!;
      visit.visitCount += 1;
      visit.lastVisitDate = DateTime.now();
    } else {
      _visits[storeId] = StoreVisitModel(
        storeId: storeId,
        firstVisitDate: DateTime.now(),
        lastVisitDate: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void updateOrderStats(String storeId, double orderValue) {
    if (_visits.containsKey(storeId)) {
      final visit = _visits[storeId]!;
      visit.orderCount += 1;
      visit.totalOrdersValue += orderValue;
      notifyListeners();
    }
  }

  void toggleFavoriteProduct(String storeId, String productId) {
    if (_visits.containsKey(storeId)) {
      final visit = _visits[storeId]!;
      if (visit.favoriteProducts.contains(productId)) {
        visit.favoriteProducts.remove(productId);
      } else {
        visit.favoriteProducts.add(productId);
      }
      notifyListeners();
    }
  }
}

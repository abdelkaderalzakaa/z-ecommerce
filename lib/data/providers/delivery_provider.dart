import 'package:flutter/foundation.dart';
import '../models/delivery/delivery_model.dart';
import '../services/delivery_service.dart';

class DeliveryProvider with ChangeNotifier {
  final DeliveryService _deliveryService = DeliveryService();

  List<DeliveryModel> _deliveries = [];
  bool _isLoading = false;
  String _error = '';

  List<DeliveryModel> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String get error => _error;

  DeliveryModel? getDeliveryById(String id) {
    try {
      return _deliveries.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  DeliveryProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();

    _deliveryService.getDeliveries().listen(
      (deliveryList) {
        _deliveries = deliveryList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> saveDelivery(DeliveryModel delivery) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _deliveryService.saveDelivery(delivery);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDelivery(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _deliveryService.deleteDelivery(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

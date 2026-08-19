import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/customer/activity_customer_inbusiness.dart';
import 'package:z_ecommerce/data/models/customer/customer_model.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/services/user_service.dart';

class CustomerProvider with ChangeNotifier {
  final UserService _userService = UserService();

  List<CustomerModel> _customers = [];
  CustomerModel _selectedCustomer = CustomerModel.empty();
  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerModel> get customers => List.unmodifiable(_customers);
  CustomerModel get selectedCustomer => _selectedCustomer;
  bool get selectedCustomerIsEmpty => _selectedCustomer.isEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// جلب قائمة جميع العملاء من السيرفس
  Future<void> fetchAllCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _userService.getAllCustomers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب عميل محدد بالـ ID
  Future<CustomerModel> fetchCustomerById(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _userService.getCustomerById(customerId);
      _selectedCustomer = result ?? CustomerModel.empty();
      return _selectedCustomer;
    } catch (e) {
      _errorMessage = e.toString();
      _selectedCustomer = CustomerModel.empty();
      return _selectedCustomer;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حفظ أو تحديث بيانات العميل في السيرفس والذاكرة
  Future<void> saveCustomer(CustomerModel customer) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index >= 0) {
        _customers[index] = customer;
      } else {
        _customers.add(customer);
      }
      if (_selectedCustomer.id == customer.id) {
        _selectedCustomer = customer;
      }
      await _userService.saveCustomer(customer);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 🧩 Sub-Models Operations for Customer
  // ==========================================

  /// 📍 تحديث عناوين توصيل العميل
  Future<void> updateAddresses(String customerId, List<AddressModel> addresses) async {
    await _userService.updateCustomerAddresses(
      customerId: customerId,
      addresses: addresses,
    );
    notifyListeners();
  }

  /// ❤️ تحديث قائمة المفضلة للعميل
  Future<void> updateWishlist(String customerId, List<String> wishlist) async {
    await _userService.updateCustomerWishlist(
      customerId: customerId,
      wishlist: wishlist,
    );
    notifyListeners();
  }

  /// 📊 تحديث أنشطة العميل في الأنشطة التجارية (ActivityCustomerInBusiness)
  Future<void> updateBusinessActivities(
    String customerId,
    List<ActivityCustomerInBusiness> activities,
  ) async {
    await _userService.updateCustomerBusinessActivities(
      customerId: customerId,
      activities: activities,
    );
    notifyListeners();
  }
}

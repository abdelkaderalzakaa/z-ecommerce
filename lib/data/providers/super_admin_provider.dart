import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/super_admin/super_admin_model.dart';
import 'package:z_ecommerce/data/services/user_service.dart';

class SuperAdminProvider with ChangeNotifier {
  final UserService _userService = UserService();

  SuperAdminModel? _currentSuperAdmin;
  bool _isLoading = false;
  String? _errorMessage;

  SuperAdminModel? get currentSuperAdmin => _currentSuperAdmin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// جلب بيانات السوبر أدمن بالمعرف
  Future<SuperAdminModel?> fetchSuperAdmin(String adminId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSuperAdmin = await _userService.getSuperAdminById(adminId);
      return _currentSuperAdmin;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حفظ أو تحديث بيانات السوبر أدمن
  Future<void> saveSuperAdmin(SuperAdminModel superAdmin) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.saveSuperAdmin(superAdmin);
      _currentSuperAdmin = superAdmin;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // 🧩 Sub-Models Operations for SuperAdmin
  // ==========================================

  /// 📱 تحديث وسائل التواصل الاجتماعي لمدير النظام
  Future<void> updateSocials(String adminId, List<dynamic> socials) async {
    await _userService.updateSuperAdminSocials(
      adminId: adminId,
      socials: socials.cast(),
    );
    notifyListeners();
  }

  /// 🌐 تحديث إعدادات الترجمات واللغة لمدير النظام
  Future<void> updateLocalization(String adminId, dynamic localization) async {
    await _userService.updateSuperAdminLocalization(
      adminId: adminId,
      localization: localization,
    );
    notifyListeners();
  }
}

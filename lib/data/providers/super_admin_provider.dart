import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/super_admin/platform_config_model.dart';
import 'package:z_ecommerce/data/models/super_admin/platform_settings.dart';
import 'package:z_ecommerce/data/models/super_admin/super_admin_model.dart';
import 'package:z_ecommerce/data/services/user_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

class SuperAdminProvider with ChangeNotifier {
  final UserService _userService = UserService();

  SuperAdminModel? _currentSuperAdmin;
  PlatformConfigModel _platformConfig = PlatformConfigModel.defaultConfig();

  bool _isLoading = false;
  String? _errorMessage;

  SuperAdminModel? get currentSuperAdmin => _currentSuperAdmin;
  PlatformConfigModel get platformConfig => _platformConfig;
  LocalizationAdmin get platformLocalization => _platformConfig.localization;
  ThemeAdmin get platformTheme => _platformConfig.theme;
  List<SocialModel> get platformSocials => _platformConfig.socials;
  PlatformSettings get platformSettings => _platformConfig.settings;

  // Compatibility getters for existing UI
  LocalizationAdmin get localizationAdmin => _platformConfig.localization;
  ThemeAdmin get themeAdmin => _platformConfig.theme;
  List<SocialModel> get socials => _platformConfig.socials;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SuperAdminProvider() {
    _initPlatformConfig();
  }

  /// الاستماع اللحظي لإعدادات المنصة العامة
  void _initPlatformConfig() {
    _userService.streamPlatformConfig().listen((config) {
      if (config != null) {
        _platformConfig = config;
        notifyListeners();
      }
    });
  }

  /// جلب إعدادات المنصة العامة لمرة واحدة
  Future<PlatformConfigModel> fetchPlatformConfig() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final config = await _userService.getPlatformConfig();
      if (config != null) {
        _platformConfig = config;
      }
      return _platformConfig;
    } catch (e) {
      _errorMessage = e.toString();
      return _platformConfig;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// حفظ أو تحديث إعدادات المنصة بالكامل
  Future<void> savePlatformConfig(PlatformConfigModel config) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.savePlatformConfig(config);
      _platformConfig = config;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📱 تحديث وسائل التواصل الاجتماعي للمنصة
  Future<void> updatePlatformSocials(List<SocialModel> socials) async {
    _platformConfig = _platformConfig.copyWith(socials: socials);
    notifyListeners();
    await _userService.updatePlatformSocials(
      socials.map((e) => e.toMap()).toList(),
    );
  }

  /// 🌐 تحديث إعدادات الترجمات واللغة للمنصة
  Future<void> updatePlatformLocalization(LocalizationAdmin localization) async {
    _platformConfig = _platformConfig.copyWith(localization: localization);
    notifyListeners();
    await _userService.updatePlatformLocalization(localization.toMap());
  }

  /// 🎨 تحديث هوية وألوان وثيم المنصة
  Future<void> updatePlatformTheme(ThemeAdmin theme) async {
    _platformConfig = _platformConfig.copyWith(theme: theme);
    notifyListeners();
    await _userService.updatePlatformTheme(theme.toMap());
  }

  /// ⚙️ تحديث إعدادات النظام والتشغيل للمنصة
  Future<void> updatePlatformSettings(PlatformSettings settings) async {
    _platformConfig = _platformConfig.copyWith(settings: settings);
    notifyListeners();
    await _userService.updatePlatformSettings(settings.toMap());
  }

  // ==========================================
  // 👤 SuperAdmin User Management
  // ==========================================

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

  /// حفظ أو تحديث بيانات السوبر أدمن مع إضافته للمصادقة (Firebase Auth) وتهيئة إعدادات المنصة
  Future<void> saveSuperAdminOnce() async {
    _isLoading = true;
    notifyListeners();

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential;

      try {
        // محاولة تسجيل الدخول إذا كان الحساب موجوداً مسبقاً
        userCredential = await auth.signInWithEmailAndPassword(
          email: "testsuperadmin@gmail.com",
          password: "testsuperadmin",
        );
      } catch (e) {
        // إذا لم يكن موجوداً، نقوم بإنشائه
        userCredential = await auth.createUserWithEmailAndPassword(
          email: "testsuperadmin@gmail.com",
          password: "testsuperadmin",
        );
      }

      final String superAdminId = userCredential.user!.uid;

      final user = UserModel(
        id: superAdminId,
        name: "test super admin",
        email: "testsuperadmin@gmail.com",
        phoneNumber: "81728282",
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
      );
      await _userService.saveUser(user);

      final superAdmin = SuperAdminModel(
        id: superAdminId,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userService.saveSuperAdmin(superAdmin);
      _currentSuperAdmin = superAdmin;

      // تهيئة إعدادات المنصة الافتراضية إذا لم تكن موجودة
      final existingPlatform = await _userService.getPlatformConfig();
      if (existingPlatform == null) {
        final defaultPlatform = PlatformConfigModel.defaultConfig();
        await _userService.savePlatformConfig(defaultPlatform);
        _platformConfig = defaultPlatform;
      } else {
        _platformConfig = existingPlatform;
      }

      debugPrint("Super admin and Platform config initialized successfully: $superAdminId");
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error in saveSuperAdminOnce: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

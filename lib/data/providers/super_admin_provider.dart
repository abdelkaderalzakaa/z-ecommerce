import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/super_admin/super_admin_model.dart';
import 'package:z_ecommerce/data/services/user_service.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

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

  /// حفظ أو تحديث بيانات السوبر أدمن مع إضافته للمصادقة (Firebase Auth)
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

      SuperAdminModel superAdmin = SuperAdminModel(
        user: UserModel(
          id: superAdminId,
          name: "test super admin",
          email: "testsuperadmin@gmail.com",
          phoneNumber: "81728282",
          role: UserRole.superAdmin,
          createdAt: DateTime.now(),
        ),
        socials: [],
        themeAdmin: ThemeAdmin.empty(),
        localizationAdmin: LocalizationAdmin(
          name: const LocalizedString(
            ar: 'متاجر زد', 
            en: 'Z-Matajer'
          ),
          slogan: const LocalizedString(
            ar: 'وجهتك الأولى للتسوق الإلكتروني', 
            en: 'Your first destination for e-commerce'
          ),
          description: const LocalizedString(
            ar: 'منصة متكاملة تتيح لك التسوق بكل سهولة وأمان وتوفر لك كل ما تحتاجه في مكان واحد.',
            en: 'An integrated platform that allows you to shop with ease and security, providing everything you need in one place.'
          ),
          footerDescription: const LocalizedString(
            ar: 'نحن هنا لخدمتك على مدار الساعة، تسوق بأمان واطمئنان.',
            en: 'We are here to serve you 24/7. Shop safely and with peace of mind.'
          ),
          aboutUs: const LocalizedString(
            ar: 'منصة متاجر زد هي الرائدة في تقديم حلول التجارة الإلكترونية لتجربة تسوق لا مثيل لها.',
            en: 'Z-Matajer is the leading platform in providing e-commerce solutions for an unparalleled shopping experience.'
          ),
          termsAndConditions: const LocalizedString(
            ar: 'يرجى مراجعة صفحة الشروط والأحكام لمعرفة التفاصيل الخاصة باستخدام المنصة.',
            en: 'Please review the Terms and Conditions page for details on using the platform.'
          ),
          privacyPolicy: const LocalizedString(
            ar: 'نحن نلتزم بحماية بياناتك الشخصية وضمان سرية معلوماتك تماماً.',
            en: 'We are committed to protecting your personal data and ensuring the complete confidentiality of your information.'
          ),
        ),
      );

      await _userService.saveSuperAdmin(superAdmin);
      _currentSuperAdmin = superAdmin;
      
      debugPrint("Super admin created/signed in successfully with UID: $superAdminId");
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error in saveSuperAdminOnce: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

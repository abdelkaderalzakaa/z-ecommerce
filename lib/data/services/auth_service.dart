import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _mobileGoogleSignIn;
  GoogleSignIn get _googleSignIn => _mobileGoogleSignIn ??= GoogleSignIn();

  /// الحصول على المستخدم الحالي في Firebase Auth
  User? get currentFirebaseUser => _auth.currentUser;

  /// 1. تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<UserCredential?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      debugPrint('Error logging in with email/password: $e');
      rethrow;
    }
  }

  /// 2. إنشاء حساب جديد بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      debugPrint('Error registering with email/password: $e');
      rethrow;
    }
  }

  /// 3. تسجيل الدخول بواسطة حساب Google (Google Sign-In)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // 1. فتح نافذة اختيار حساب Google للأجهزة الذكية
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // قام المستخدم بإلغاء التسجيل

        // 2. الحصول على تفاصيل المصادقة من Google
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // 3. إنشاء اعتمادات Firebase من خلال توكنات Google
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 4. تسجيل الدخول في Firebase Auth
        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// 4. إعادة تعيين كلمة المرور عبر البريد الإلكتروني
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// 6. حذف حساب المستخدم الحار من Firebase Auth
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      debugPrint('Error deleting Firebase Auth user: $e');
      rethrow;
    }
  }

  /// 7. تحديث كلمة المرور للمستخدم الحالي
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      debugPrint('Error updating password in Firebase Auth: $e');
      rethrow;
    }
  }

  /// 8. تسجيل الخروج من Firebase و Google
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  /// تحويل كائن Firebase User إلى UserModel
  UserModel mapFirebaseUserToUserModel(User firebaseUser, {UserRole role = UserRole.customer}) {
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'مستخدم',
      email: firebaseUser.email ?? '',
      phoneNumber: firebaseUser.phoneNumber ?? '',
      avatarUrl: firebaseUser.photoURL ?? '',
      role: role,
      createdAt: DateTime.now(),
    );
  }
}

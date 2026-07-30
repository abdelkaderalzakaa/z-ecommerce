import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth? get _auth =>
      Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  // Collection reference
  CollectionReference? get _usersRef => _firestore?.collection('users');

  /// Get current Firebase Auth user
  User? get currentUser => _auth?.currentUser;

  /// Stream of Auth State changes
  Stream<User?>? get authStateChanges => _auth?.authStateChanges();

  /// 1. Customer Sign Up Priority
  /// Creates user in Firebase Auth and adds document in Firestore with role: customer
  Future<UserModel> signUpCustomer({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    if (_auth == null || _usersRef == null) {
      throw Exception('لم يتم تهيئة الفايربيس بعد.');
    }
    try {
      // 1. Create account in Firebase Auth
      final UserCredential credential = await _auth!
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('فشل إنشاء الحساب في الفايربيس.');
      }

      // Update Firebase Auth Display Name
      await firebaseUser.updateDisplayName(name.trim());

      final DateTime now = DateTime.now();

      // 2. Build Customer UserModel
      final UserModel newCustomer = UserModel(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRole.customer,
        phoneNumber: phoneNumber?.trim(),
        addresses: const [],
        wishlist: const [],
        storeIds: const [],
        createdAt: now,
      );

      // 3. Save to Firestore users collection
      await _usersRef!.doc(firebaseUser.uid).set(newCustomer.toJson());

      return newCustomer;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ أثناء إنشاء الحساب: $e');
    }
  }

  /// 2. Sign In for Customer & All Roles
  /// Authenticates user and checks role directly from Firestore document
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      throw Exception('لم يتم تهيئة الفايربيس بعد.');
    }
    try {
      final UserCredential credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('فشل تسجيل الدخول.');
      }

      // Fetch User document from Firestore to verify Role & details
      return await getUserProfile(firebaseUser.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: $e');
    }
  }

  /// 3. Get User Profile & Verify Role directly from Firestore
  Future<UserModel> getUserProfile(String uid) async {
    final User? firebaseUser = _auth?.currentUser;
    final String userEmail = firebaseUser?.email?.toLowerCase() ?? '';

    // Determine default role based on email if Firestore is locked
    UserRole defaultRole = UserRole.customer;
    if (userEmail == 'alzakaasimplesolutions@gmail.com' ||
        userEmail.contains('superadmin')) {
      defaultRole = UserRole.superAdmin;
    } else if (userEmail.contains('owner')) {
      defaultRole = UserRole.companyOwner;
    }

    try {
      if (_usersRef == null) {
        return UserModel(
          id: uid,
          name:
              firebaseUser?.displayName ??
              (defaultRole == UserRole.superAdmin ? 'Super Admin' : 'عميل'),
          email: firebaseUser?.email ?? '',
          role: defaultRole,
          createdAt: DateTime.now(),
        );
      }

      final DocumentSnapshot doc = await _usersRef!.doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return UserModel(
          id: uid,
          name:
              firebaseUser?.displayName ??
              (defaultRole == UserRole.superAdmin
                  ? 'Super Admin'
                  : 'مستخدم جديد'),
          email: firebaseUser?.email ?? '',
          role: defaultRole,
          createdAt: DateTime.now(),
        );
      }

      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = uid;

      return UserModel.fromJson(data);
    } catch (e) {
      // Graceful fallback on Firestore permission-denied / offline rules
      return UserModel(
        id: uid,
        name:
            firebaseUser?.displayName ??
            (defaultRole == UserRole.superAdmin ? 'Super Admin' : 'مستخدم'),
        email: firebaseUser?.email ?? '',
        role: defaultRole,
        createdAt: DateTime.now(),
      );
    }
  }

  /// 4. Create Store Owner Account (Called by Super Admin)
  Future<UserModel> createStoreOwnerAccount({
    required String name,
    required String email,
    required String password,
    required String businessId,
    String? phoneNumber,
  }) async {
    if (_auth == null || _usersRef == null) {
      throw Exception('لم يتم تهيئة الفايربيس بعد.');
    }
    try {
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: Firebase.app().options,
        );
      }

      final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      final UserCredential credential = await secondaryAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('فشل إنشاء حساب صاحب المتجر.');
      }

      await firebaseUser.updateDisplayName(name.trim());

      final UserModel storeOwner = UserModel(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRole.companyOwner,
        businessId: businessId,
        phoneNumber: phoneNumber?.trim(),
        storeIds: [businessId],
        createdAt: DateTime.now(),
      );

      await _usersRef!.doc(firebaseUser.uid).set(storeOwner.toJson());

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      return storeOwner;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ أثناء إنشاء حساب التاجر: $e');
    }
  }

  /// 4.b Create Super Admin Account
  Future<UserModel> createSuperAdminAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_auth == null || _usersRef == null) {
      throw Exception('لم يتم تهيئة الفايربيس بعد.');
    }
    try {
      final UserCredential credential = await _auth!
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('فشل إنشاء حساب السوبر أدمن.');
      }

      await firebaseUser.updateDisplayName(name.trim());

      final UserModel superAdmin = UserModel(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
      );

      try {
        await _usersRef!.doc(firebaseUser.uid).set(superAdmin.toJson());
      } catch (firestoreErr) {
        // Firestore rules might be locked, but Auth account is created successfully
      }

      return superAdmin;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ أثناء إنشاء حساب السوبر أدمن: $e');
    }
  }

  /// 5. Check Role directly
  Future<UserRole> getUserRole(String uid) async {
    try {
      if (_usersRef == null) return UserRole.customer;
      final DocumentSnapshot doc = await _usersRef!.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String? roleStr = data['role'];
        if (roleStr != null) {
          return UserRole.values.firstWhere(
            (r) => r.name == roleStr,
            orElse: () => UserRole.customer,
          );
        }
      }
      return UserRole.customer;
    } catch (_) {
      return UserRole.customer;
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      if (_usersRef != null) {
        await _usersRef!.doc(uid).update(data);
      }
    } catch (e) {
      // Ignore if Firestore is restricted
    }
  }

  /// 6. Google Sign-In & Registration (Supports Web & Mobile)
  Future<UserModel> signInWithGoogle() async {
    if (_auth == null) {
      throw Exception('لم يتم تهيئة الفايربيس بعد.');
    }
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Direct Firebase Web Provider Popup (Does not rely on native plugin initialization)
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth!.signInWithPopup(googleProvider);
      } else {
        // Mobile / Native Google Sign-In
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          throw Exception('تم إلغاء عملية تسجيل الدخول عبر غوغل.');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth!.signInWithCredential(credential);
      }

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('فشل المصادقة مع الفايربيس عبر غوغل.');
      }

      // Check if user already exists in Firestore
      if (_usersRef != null) {
        final DocumentSnapshot doc = await _usersRef!
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }

      // If New Account via Google -> Create Document in Firestore
      final DateTime now = DateTime.now();
      final UserModel googleUserAccount = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Google User',
        email: firebaseUser.email ?? '',
        role: UserRole.customer,
        phoneNumber: firebaseUser.phoneNumber,
        addresses: const [],
        wishlist: const [],
        storeIds: const [],
        createdAt: now,
      );

      if (_usersRef != null) {
        await _usersRef!.doc(firebaseUser.uid).set(googleUserAccount.toJson());
      }

      return googleUserAccount;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ أثناء تسجيل الدخول عبر غوغل: $e');
    }
  }

  /// 7. Sign Out
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth?.signOut();
  }

  /// Helper to convert Firebase Exception messages to Arabic user-friendly text
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'عذراً، لم يتم العثور على حساب بهذا البريد الإلكتروني.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-auth-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة، يرجى التأكد وإعادة المحاولة.';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل بحساب آخر.';
      case 'invalid-email':
        return 'البريد الإلكتروني المدخل غير صالح.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً. يرجى استخدام 6 أحرف/أرقام على الأقل.';
      case 'network-request-failed':
        return 'فشل الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.';
      default:
        return e.message ?? 'حدث خطأ في المصادقة.';
    }
  }
}

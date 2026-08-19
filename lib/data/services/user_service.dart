import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/models/store/currency_store.dart';
import 'package:z_ecommerce/data/models/super_admin/super_admin_model.dart';
import 'package:z_ecommerce/data/models/customer/customer_model.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/customer/activity_customer_inbusiness.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/store/business_visit_model.dart';
import 'package:z_ecommerce/data/models/store/followers_store.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';

/// users => role businesses =>
/// users => role super_admins =>
/// users => role customers
///
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  final String _usersCollection = 'users';
  final String _businessesCollection = 'businesses';
  final String _superAdminsCollection = 'super_admins';
  final String _customersCollection = 'customers';

  // ==========================================
  // 👤 1. UserModel (إدارة الحسابات العامة)
  // ==========================================

  /// حفظ أو تحديث بيانات UserModel الأساسية في مجموعة users
  Future<void> saveUser(UserModel user) async {
    if (user.id.isEmpty) {
      debugPrint(
        '[UserService] Blocked: Attempted to save a user with empty ID.',
      );
      return;
    }
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
      debugPrint('User saved successfully: ${user.id}');
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  /// إنشاء مستخدم في Authentication دون تسجيل خروج الأدمن الحالي
  Future<String?> createNewAuthUserWithoutLoggingOut(
    String email,
    String password,
  ) async {
    try {
      final secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      await auth.signOut();
      await secondaryApp.delete();
      return uid;
    } catch (e) {
      debugPrint('Error creating secondary auth user: $e');
      rethrow;
    }
  }

  /// تغيير حالة تنشيط أو حظر المستخدم
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'isActive': isActive,
      });
      debugPrint('User status updated successfully: $userId to $isActive');
    } catch (e) {
      debugPrint('Error updating user status: $e');
      rethrow;
    }
  }

  /// جلب بيانات UserModel بحسب الـ ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
    return null;
  }

  /// جلب جميع المستخدمين
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_usersCollection).get();
      return snapshot.docs.map((doc) {
        // Try fromMap if exists, else fallback to fromJson if fromMap is just an alias or vice versa
        try {
          return UserModel.fromJson(doc.data());
        } catch (_) {
          return UserModel.fromJson(
            doc.data(),
          ); // just use fromJson which we verified exists
        }
      }).toList();
    } catch (e) {
      debugPrint('Error fetching all users: $e');
      return [];
    }
  }

  /// حذف بيانات UserModel ومجموعاتها الفرعية بالكامل من Firestore
  Future<void> deleteUserFromFirestore(String userId, UserRole role) async {
    try {
      // 1. حذف وثيقة users الرئيسية
      await _firestore.collection(_usersCollection).doc(userId).delete();

      // 2. حذف الوثيقة التفصيلية حسَب دور المستخدم
      if (role == UserRole.customer) {
        await _firestore.collection(_customersCollection).doc(userId).delete();
      } else if (role == UserRole.businessOwner) {
        await _firestore.collection(_businessesCollection).doc(userId).delete();
      } else if (role == UserRole.superAdmin) {
        await _firestore
            .collection(_superAdminsCollection)
            .doc(userId)
            .delete();
      }
      debugPrint('User deleted from Firestore successfully: $userId');
    } catch (e) {
      debugPrint('Error deleting user from Firestore: $e');
    }
  }

  // ==========================================
  // 🏪 2. BusinessModel (إدارة المتاجر والأنشطة)
  // ==========================================

  /// إنشاء أو تحديث بيانات المتجر/النشاط التجاري في مجموعة businesses
  Future<void> saveBusiness(BusinessModel business) async {
    if (business.isEmpty) {
      debugPrint(
        '[UserService] Blocked: Attempted to save a business with empty ID.',
      );
      return;
    }
    try {
      // 1. حفظ UserModel أولاً في users إن وجد
      if (business.owner != null) {
        await saveUser(business.owner!);
      }

      // 2. حفظ BusinessModel في businesses
      await _firestore
          .collection(_businessesCollection)
          .doc(business.id)
          .set(business.toMap(), SetOptions(merge: true));
      debugPrint('Business saved successfully: ${business.id}');
    } catch (e) {
      debugPrint('Error saving business: $e');
    }
  }

  /// جلب بيانات المتجر بالمعرف
  Future<BusinessModel?> getBusinessById(String businessId) async {
    try {
      final doc = await _firestore
          .collection(_businessesCollection)
          .doc(businessId)
          .get();
      if (doc.exists && doc.data() != null) {
        return BusinessModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Error fetching business: $e');
    }
    return null;
  }

  /// جلب قائمة جميع المتاجر
  Future<List<BusinessModel>> getAllBusinesses() async {
    try {
      final snapshot = await _firestore.collection(_businessesCollection).get();
      return snapshot.docs
          .map((doc) => BusinessModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching businesses: $e');
      return [];
    }
  }

  /// جلب المتاجر التي ليس لها مدير حالياً
  Future<List<BusinessModel>> getUnassignedBusinesses() async {
    try {
      final snapshot = await _firestore.collection(_businessesCollection).get();
      return snapshot.docs
          .map((doc) => BusinessModel.fromMap(doc.data(), doc.id))
          .where((b) => b.owner == null)
          .toList();
    } catch (e) {
      debugPrint('Error fetching unassigned businesses: $e');
      return [];
    }
  }

  /// جلب مدراء المتاجر الذين ليس لديهم متجر حالياً
  Future<List<UserModel>> getUnassignedBusinessOwners() async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: UserRole.businessOwner.name)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((u) => u.businessId == null || u.businessId!.isEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error fetching unassigned business owners: $e');
      return [];
    }
  }

  /// الاستماع المباشر للتغيرات على المتاجر (Real-time Stream)
  Stream<List<BusinessModel>> streamBusinesses() {
    return _firestore
        .collection(_businessesCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BusinessModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ==========================================
  // 👑 3. SuperAdminModel (إدارة السوبر أدمن)
  // ==========================================

  /// حفظ بيانات السوبر أدمن في مجموعة super_admins
  Future<void> saveSuperAdmin(SuperAdminModel superAdmin) async {
    try {
      // 1. حفظ UserModel الأساسي
      await saveUser(superAdmin.user);

      // 2. حفظ بيانات السوبر أدمن
      await _firestore
          .collection(_superAdminsCollection)
          .doc(superAdmin.id)
          .set(superAdmin.toMap(), SetOptions(merge: true));
      debugPrint('SuperAdmin saved successfully: ${superAdmin.id}');
    } catch (e) {
      debugPrint('Error saving SuperAdmin: $e');
    }
  }

  /// جلب بيانات السوبر أدمن بالمعرف
  Future<SuperAdminModel?> getSuperAdminById(String adminId) async {
    try {
      final doc = await _firestore
          .collection(_superAdminsCollection)
          .doc(adminId)
          .get();
      if (doc.exists && doc.data() != null) {
        return SuperAdminModel.fromMap(doc.data()!, docId: doc.id);
      }
    } catch (e) {
      debugPrint('Error fetching SuperAdmin: $e');
    }
    return null;
  }

  /// البث المباشر لإعدادات السوبر أدمن العامة للمنصة
  Stream<SuperAdminModel?> streamPlatformSuperAdmin() {
    return _firestore
        .collection(_superAdminsCollection)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            return SuperAdminModel.fromMap(doc.data(), docId: doc.id);
          }
          return null;
        });
  }

  /// تحديث إعدادات المنصة لمدير النظام
  Future<void> updateSuperAdminPlatformSettings({
    required String adminId,
    required dynamic platformSettings,
  }) async {
    try {
      await _firestore.collection(_superAdminsCollection).doc(adminId).update({
        'platformSettings': platformSettings,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating platform settings: $e');
    }
  }

  /// تحديث الثيم (ThemeAdmin) لمدير النظام
  Future<void> updateSuperAdminTheme({
    required String adminId,
    required Map<String, dynamic> theme,
  }) async {
    try {
      await _firestore.collection(_superAdminsCollection).doc(adminId).update({
        'themeAdmin': theme,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating super admin theme: $e');
    }
  }

  /// تحديث بيانات الترجمة والنصوص (LocalizationAdmin) لمدير النظام
  Future<void> updateSuperAdminLocalization({
    required String adminId,
    required Map<String, dynamic> localization,
  }) async {
    try {
      await _firestore.collection(_superAdminsCollection).doc(adminId).update({
        'localizationAdmin': localization,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating super admin localization: $e');
    }
  }

  // ==========================================
  // 🛒 4. CustomerModel (إدارة العملاء)
  // ==========================================

  /// حفظ أو تحديث بيانات العميل في مجموعة customers
  Future<void> saveCustomer(CustomerModel customer) async {
    if (customer.isEmpty) {
      debugPrint(
        '[UserService] Blocked: Attempted to save a customer with empty ID.',
      );
      return;
    }
    try {
      // 1. حفظ UserModel الأساسي
      await saveUser(customer.user);

      // 2. حفظ بيانات العميل
      await _firestore
          .collection(_customersCollection)
          .doc(customer.id)
          .set(customer.toMap(), SetOptions(merge: true));
      debugPrint('Customer saved successfully: ${customer.id}');
    } catch (e) {
      debugPrint('Error saving customer: $e');
    }
  }

  /// جلب بيانات العميل بالمعرف
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      final doc = await _firestore
          .collection(_customersCollection)
          .doc(customerId)
          .get();
      if (doc.exists && doc.data() != null) {
        return CustomerModel.fromMap(doc.data()!, docId: doc.id);
      }
    } catch (e) {
      debugPrint('Error fetching customer: $e');
    }
    return null;
  }

  /// جلب قائمة جميع العملاء
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final snapshot = await _firestore.collection(_customersCollection).get();
      return snapshot.docs
          .map((doc) => CustomerModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all customers: $e');
      return [];
    }
  }

  // ==========================================
  // 🧩 5. Sub-Models Operations (تعديل وإضافة وحذف الأجزاء الفرعية)
  // ==========================================

  // --- 📱 SocialModel (وسائل التواصل الاجتماعي) ---
  Future<void> updateBusinessSocials({
    required String businessId,
    required List<SocialModel> socials,
  }) async {
    try {
      await _firestore
          .collection(_businessesCollection)
          .doc(businessId)
          .update({
            'socials': socials.map((e) => e.toMap()).toList(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error updating business socials: $e');
    }
  }

  Future<void> updateSuperAdminSocials({
    required String adminId,
    required List<SocialModel> socials,
  }) async {
    try {
      await _firestore.collection(_superAdminsCollection).doc(adminId).update({
        'socials': socials.map((e) => e.toMap()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating super admin socials: $e');
    }
  }

  // --- 👁️ BusinessVisitModel (سجل الزيارات) ---
  Future<void> addBusinessVisit({
    required String businessId,
    required BusinessVisitModel visit,
  }) async {
    try {
      await _firestore.collection(_businessesCollection).doc(businessId).update(
        {
          'visits': FieldValue.arrayUnion([visit.toMap()]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error adding business visit: $e');
    }
  }

  // --- 🌐 LocalizationAdmin (إعدادات اللغة والترجمة) ---
  Future<void> updateBusinessLocalization({
    required String businessId,
    required LocalizationAdmin localization,
  }) async {
    try {
      await _firestore
          .collection(_businessesCollection)
          .doc(businessId)
          .update({
            'localization': localization.toMap(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error updating business localization: $e');
    }
  }

  // --- 🔱 CurrencyStore (إدارة العملة وإعداداتها للبزنس) ---
  Future<void> updateBusinessCurrency({
    required String businessId,
    required CurrencyStore currency,
  }) async {
    try {
      await _firestore.collection(_businessesCollection).doc(businessId).update(
        {
          'currency': currency.toMap(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error updating business currency: $e');
    }
  }

  // --- 🎨 ThemeAdmin (إعدادات الثيم والمظهر) ---
  Future<void> updateBusinessTheme({
    required String businessId,
    required ThemeAdmin theme,
  }) async {
    try {
      await _firestore.collection(_businessesCollection).doc(businessId).update(
        {'theme': theme.toMap(), 'updatedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      debugPrint('Error updating business theme: $e');
    }
  }

  // --- 👍 Business Likes (إدارة اللايكات والإعجابات) ---
  Future<void> incrementBusinessLikes(String businessId) async {
    try {
      await _firestore
          .collection(_businessesCollection)
          .doc(businessId)
          .update({
            'likes': FieldValue.increment(1),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error incrementing business likes: $e');
    }
  }

  Future<void> decrementBusinessLikes(String businessId) async {
    try {
      await _firestore
          .collection(_businessesCollection)
          .doc(businessId)
          .update({
            'likes': FieldValue.increment(-1),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error decrementing business likes: $e');
    }
  }

  // --- 👥 FollowersStore (إدارة المتابعين للمتجر) ---
  Future<void> addFollowerToBusiness({
    required String businessId,
    required FollowersStore follower,
  }) async {
    try {
      await _firestore.collection(_businessesCollection).doc(businessId).update(
        {
          'followersUsers': FieldValue.arrayUnion([follower.toMap()]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error adding follower: $e');
    }
  }

  Future<void> removeFollowerFromBusiness({
    required String businessId,
    required FollowersStore follower,
  }) async {
    try {
      await _firestore.collection(_businessesCollection).doc(businessId).update(
        {
          'followersUsers': FieldValue.arrayRemove([follower.toMap()]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error removing follower: $e');
    }
  }

  // --- ⭐ RatedUser (إدارة التقييمات) ---
  Future<void> addRatingToBusiness({
    required String businessId,
    required RatedUser rating,
  }) async {
    try {
      await _firestore.collection(_businessesCollection).doc(businessId).update(
        {
          'ratings': FieldValue.arrayUnion([rating.toMap()]),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error adding rating: $e');
    }
  }

  // --- 📍 AddressModel (إدارة العناوين) ---
  Future<void> updateCustomerAddresses({
    required String customerId,
    required List<AddressModel> addresses,
  }) async {
    try {
      await _firestore.collection(_customersCollection).doc(customerId).update({
        'addresses': addresses.map((e) => e.toMap()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating customer addresses: $e');
    }
  }

  Future<void> updateBusinessAddresses({
    required String businessId,
    required List<AddressModel> addresses,
  }) async {
    try {
      await _firestore
          .collection(_businessesCollection)
          .doc(businessId)
          .update({
            'addAddress': addresses.map((e) => e.toMap()).toList(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      debugPrint('Error updating business addresses: $e');
    }
  }

  // --- ❤️ Wishlist (إدارة قائمة المفضلة) ---
  Future<void> updateCustomerWishlist({
    required String customerId,
    required List<String> wishlist,
  }) async {
    try {
      await _firestore.collection(_customersCollection).doc(customerId).update({
        'wishlist': wishlist,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating customer wishlist: $e');
    }
  }

  // --- 📊 ActivityCustomerInBusiness (أنشطة العملاء في الأنشطة التجارية) ---
  Future<void> updateCustomerBusinessActivities({
    required String customerId,
    required List<ActivityCustomerInBusiness> activities,
  }) async {
    try {
      await _firestore.collection(_customersCollection).doc(customerId).update({
        'businessActivities': activities.map((e) => e.toMap()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating customer business activities: $e');
    }
  }
}

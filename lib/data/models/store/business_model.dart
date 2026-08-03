import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/store/business_visit_model.dart';
import 'package:z_ecommerce/data/models/store/followers_store.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';
import '../auth/user_model.dart';
import 'currency_store.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

// ==========================================
// 🧮 حالات جاهزية المتجر (Readiness Status)
// ==========================================

enum ReadinessStatus {
  critical,
  fair,
  good,
  complete,
}

extension ReadinessStatusExtension on ReadinessStatus {
  /// الحصول على التسمية العربية للحالة
  String get label {
    switch (this) {
      case ReadinessStatus.critical: return 'حرج';
      case ReadinessStatus.fair: return 'مقبول';
      case ReadinessStatus.good: return 'جيد';
      case ReadinessStatus.complete: return 'مكتمل';
    }
  }

  /// الحصول على كود اللون (Hex Color) للحالة
  String get hexColor {
    switch (this) {
      case ReadinessStatus.critical: return '#F44336'; // أحمر
      case ReadinessStatus.fair: return '#FF9800'; // برتقالي
      case ReadinessStatus.good: return '#2196F3'; // أزرق
      case ReadinessStatus.complete: return '#4CAF50'; // أخضر
    }
  }
}

class BusinessModel {
  final String id;
  final UserModel? owner;
  final BusinessType businessType;
  final List<AddressModel> addAddress;
  final int likes;
  // 2. الهوية والإعدادات البصرية والمالية
  final ThemeAdmin theme;
  final LocalizationAdmin localization;
  final CurrencyStore currency;

  // 3. وسائل التواصل وطرق الدفع
  final List<SocialModel> socials;
  final List<PaymentMethodType> paymentMethods;

  // 4. الإحصائيات والتفاعل
  final int orders;
  final List<FollowersStore> followersUsers;
  final List<RatedUser> ratings;
  final List<BusinessVisitModel> visits;

  // 5. الحالة والتواريخ
  final String? status; // 'Active', 'Active & Verified', 'Pending', 'Inactive'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == 'Active' || status == 'Active & Verified';
  bool get isVerified => status == 'Active & Verified';
  bool get isPending => status == 'Pending';
  bool get isInactive => status == 'Inactive' || status == null;

  BusinessModel({
    required this.id,
    this.owner,
    this.addAddress = const [],
    this.businessType = BusinessType.retailStore,
    this.likes = 0,
    required this.theme,
    required this.localization,
    required this.currency,
    this.socials = const [],
    this.paymentMethods = const [],
    this.orders = 0,
    this.followersUsers = const [],
    this.ratings = const [],
    this.visits = const [],
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  BusinessModel copyWith({
    String? id,
    UserModel? owner,
    BusinessType? businessType,
    List<AddressModel>? addAddress,
    int? likes,
    ThemeAdmin? theme,
    LocalizationAdmin? localization,
    CurrencyStore? currency,
    List<SocialModel>? socials,
    List<PaymentMethodType>? paymentMethods,
    int? orders,
    List<FollowersStore>? followersUsers,
    List<RatedUser>? ratings,
    List<BusinessVisitModel>? visits,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      businessType: businessType ?? this.businessType,
      addAddress: addAddress ?? this.addAddress,
      likes: likes ?? this.likes,
      theme: theme ?? this.theme,
      localization: localization ?? this.localization,
      currency: currency ?? this.currency,
      socials: socials ?? this.socials,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      orders: orders ?? this.orders,
      followersUsers: followersUsers ?? this.followersUsers,
      ratings: ratings ?? this.ratings,
      visits: visits ?? this.visits,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // 🧮 الحسابات الديناميكية (Dynamic Getters)
  // ==========================================

  /// إجمالي عدد الزيارات بناءً على القائمة
  int get visitorsCount => visits.length;

  // ==========================================
  // 🧮 مؤشر جاهزية المتجر للإطلاق
  // ==========================================

  /// دالة مساعدة للتحقق من صحة النص المترجم (عربي أو إنجليزي)
  bool _isValidLocalizedText(LocalizedString? text) {
    if (text == null) return false;
    return text.ar.trim().isNotEmpty || text.en.trim().isNotEmpty;
  }

  // --- الخصائص المستقلة لكل عنصر (Getters) ---
  bool get hasOwner => owner != null;
  bool get hasName => _isValidLocalizedText(localization.name);
  bool get hasSlogan => _isValidLocalizedText(localization.slogan);
  bool get hasDescription => _isValidLocalizedText(localization.description);
  bool get hasFooterDescription => _isValidLocalizedText(localization.footerDescription);
  bool get hasAbout => _isValidLocalizedText(localization.aboutUs);
  bool get hasTerms => _isValidLocalizedText(localization.termsAndConditions);
  bool get hasPrivacy => _isValidLocalizedText(localization.privacyPolicy);
  
  // المنتجات والفئات (ملاحظة: تحتاج لربطها ببيانات الداتابيز الفعلي إذا لم تكن في الموديل)
  bool get hasProducts => false; 
  bool get hasCategories => false; 

  bool get hasPaymentMethods => paymentMethods.isNotEmpty;
  bool get hasAddress => addAddress.isNotEmpty;

  /// مؤشر جهوزية المتجر للإطلاق (نسبة مئوية من 0 إلى 100)
  double get readinessPercentage {
    double score = 0.0;
    
    // المدير (10%)
    if (hasOwner) score += 10.0;
    
    // النصوص المترجمة (كل واحد 5% ، المجموع 35%)
    if (hasName) score += 5.0;
    if (hasSlogan) score += 5.0;
    if (hasDescription) score += 5.0;
    if (hasFooterDescription) score += 5.0;
    if (hasAbout) score += 5.0;
    if (hasTerms) score += 5.0;
    if (hasPrivacy) score += 5.0;
    
    // المنتجات (10%)
    if (hasProducts) score += 10.0;
    
    // الفئات (10%)
    if (hasCategories) score += 10.0;
    
    // وسائل الدفع (10%)
    if (hasPaymentMethods) score += 10.0;
    
    // العنوان (15%)
    if (hasAddress) score += 15.0;
    
    return score;
  }

  /// حالة الجاهزية الحالية
  ReadinessStatus get readinessStatus {
    final score = readinessPercentage;
    if (score < 50.0) return ReadinessStatus.critical;
    if (score >= 50.0 && score <= 74.0) return ReadinessStatus.fair;
    if (score >= 75.0 && score <= 99.0) return ReadinessStatus.good;
    return ReadinessStatus.complete;
  }

  /// العناصر الناقصة للوصول إلى 100%
  List<String> get missingItems {
    final List<String> missing = [];
    if (!hasOwner) missing.add('تحديد مدير المتجر');
    if (!hasName) missing.add('اسم المتجر');
    if (!hasSlogan) missing.add('الشعار اللفظي (Slogan)');
    if (!hasDescription) missing.add('وصف المتجر');
    if (!hasFooterDescription) missing.add('وصف الفوتر');
    if (!hasAbout) missing.add('صفحة من نحن');
    if (!hasTerms) missing.add('الشروط والأحكام');
    if (!hasPrivacy) missing.add('سياسة الخصوصية');
    if (!hasProducts) missing.add('إضافة منتج واحد على الأقل');
    if (!hasCategories) missing.add('إضافة فئة واحدة على الأقل');
    if (!hasPaymentMethods) missing.add('تحديد وسيلة دفع واحدة على الأقل');
    if (!hasAddress) missing.add('إضافة عنوان واحد على الأقل');
    return missing;
  }

  /// إجمالي عدد المتابعين بناءً على القائمة
  int get followersCount => followersUsers.length;

  /// حساب التقييم النهائي الموزون للنشاط (Weighted Score)
  /// يعتمد على متوسط مراجعات التقييم مع أوزان تفاعلية للزيارات والمتابعين
  double get rating {
    if (ratings.isEmpty) return 0.0;

    // 1. حساب متوسط التقييمات المباشرة (من 5)
    double averageRating =
        ratings.map((e) => e.rating).reduce((a, b) => a + b) / ratings.length;

    // 2. عامل مؤشر التفاعل (Engagement Score) بناءً على المتابعين والزيارات
    // يضيف نسبة دعم بسيطة تصل لـ 0.5 كحد أقصى للأنشطة الأكثر تفاعلاً
    double engagementBonus = 0.0;
    if (visitorsCount > 0) {
      double followerRatio = followersCount / visitorsCount; // نسبة التحويل
      engagementBonus = (followerRatio * 0.5).clamp(0.0, 0.5);
    }

    // النتيجة النهائية محصورة بين 0 و 5
    return (averageRating + engagementBonus).clamp(0.0, 5.0);
  }

  // ==========================================
  // 🔄 Serialization (fromMap & toMap)
  // ==========================================

  factory BusinessModel.fromMap(Map<String, dynamic> map, String docId) {
    return BusinessModel(
      id: docId,
      owner: map['owner'] != null ? UserModel.fromMap(map['owner']) : null,
      addAddress:
          (map['addAddress'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromMap(e))
              .toList() ??
          [],
      businessType: BusinessType.fromString(map['businessType']),
      likes: map['likes'] ?? 0,
      theme: ThemeAdmin.fromMap(map['theme'] ?? {}),
      localization: LocalizationAdmin.fromMap(map['localization'] ?? {}),
      currency: CurrencyStore.fromMap(map['currency'] ?? {}),
      socials:
          (map['socials'] as List<dynamic>?)
              ?.map((e) => SocialModel.fromMap(e))
              .toList() ??
          [],
      paymentMethods:
          (map['paymentMethods'] as List<dynamic>?)
              ?.map((e) => PaymentMethodType.fromString(e.toString()))
              .toList() ??
          [],
      orders: map['orders'] ?? 0,
      followersUsers:
          (map['followersUsers'] as List<dynamic>?)
              ?.map((e) => FollowersStore.fromMap(e))
              .toList() ??
          [],
      ratings:
          (map['ratings'] as List<dynamic>?)
              ?.map((e) => RatedUser.fromMap(e))
              .toList() ??
          [],
      visits:
          (map['visits'] as List<dynamic>?)
              ?.map((e) => BusinessVisitModel.fromMap(e, e['id'] ?? ''))
              .toList() ??
          [],
      status: map['status'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (owner != null) 'owner': owner!.toMap(),
      'addAddress': addAddress.map((e) => e.toMap()).toList(),
      'businessType': businessType.name,
      'likes': likes,
      'theme': theme.toMap(),
      'localization': localization.toMap(),
      'currency': currency.toMap(),
      'socials': socials.map((e) => e.toMap()).toList(),
      'paymentMethods': paymentMethods.map((e) => e.name).toList(),
      'orders': orders,
      'followersUsers': followersUsers.map((e) => e.toMap()).toList(),
      'ratings': ratings.map((e) => e.toMap()).toList(),
      'visits': visits.map((e) => e.toMap()).toList(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// إنشاء كائن BusinessModel فارغ بقيم افتراضية
  factory BusinessModel.empty() {
    return BusinessModel(
      id: 'empty_business',
      owner: null,
      theme: ThemeAdmin.empty(),
      localization: LocalizationAdmin.empty(),
      currency: CurrencyStore.empty(),
    );
  }
}

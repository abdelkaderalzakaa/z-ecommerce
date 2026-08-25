import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/shared/localization_admin.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';
import 'package:z_ecommerce/data/models/shared/theme_admin.dart';
import 'package:z_ecommerce/data/models/store/business_visit_model.dart';
import 'package:z_ecommerce/data/models/store/currency_store.dart';
import 'package:z_ecommerce/data/models/store/followers_store.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';

enum ReadinessStatus {
  needsAttention, // 0 - 49%
  good,           // 50 - 79%
  complete;       // 80 - 100%

  String get labelAr {
    switch (this) {
      case ReadinessStatus.needsAttention: return 'يحتاج إلى تحسين';
      case ReadinessStatus.good: return 'جاهز جزئياً';
      case ReadinessStatus.complete: return 'مكتمل وجاهز';
    }
  }

  String get labelEn {
    switch (this) {
      case ReadinessStatus.needsAttention: return 'Needs Attention';
      case ReadinessStatus.good: return 'Partially Ready';
      case ReadinessStatus.complete: return 'Fully Ready';
    }
  }

  String get colorHex {
    switch (this) {
      case ReadinessStatus.needsAttention: return '#FFA000'; // برتقالي
      case ReadinessStatus.good: return '#2196F3'; // أزرق
      case ReadinessStatus.complete: return '#4CAF50'; // أخضر
    }
  }
}

class BusinessModel {
  final String id;
  // بيانات المالك الخفيفة (مفصولة عن كوليكشن users)
  final String? ownerId;
  final String? ownerName;
  final String? ownerEmail;
  final String? ownerPhone;

  final BusinessType businessType;
  final int likes;
  // 2. الهوية والإعدادات البصرية والمالية
  final ThemeAdmin theme;
  final LocalizationAdmin localization;
  final CurrencyStore currency;

  // 3. وسائل التواصل وطرق الدفع
  final List<SocialModel> socials;
  final List<PaymentMethodType> paymentMethods;
  final DeliveryHandlingType deliveryHandling;
  final List<String> assignedDeliveryIds;

  // 4. الإحصائيات والتفاعل
  final int orders;
  final List<FollowersStore> followersUsers;
  final List<RatedUser> ratings;
  final List<BusinessVisitModel> visits;

  // 5. التحكم بالخصائص والتفاعلات (Permissions & Recommendations)
  final bool allowFollow;
  final bool allowLikes;
  final bool allowReviews;
  final bool isRecommended;
  final bool allowOffers;

  // 6. الحالة والتواريخ
  final String? status; // 'Active', 'Active & Verified', 'Pending', 'Inactive'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == 'Active' || status == 'Active & Verified';
  bool get isVerified => status == 'Active & Verified';
  bool get isPending => status == 'Pending';
  bool get isInactive => status == 'Inactive' || status == null;
  bool get isEmpty => id.isEmpty || id == 'empty_business';
  bool get isNotEmpty => !isEmpty;

  BusinessModel({
    required this.id,
    this.ownerId,
    this.ownerName,
    this.ownerEmail,
    this.ownerPhone,
    this.businessType = BusinessType.retailStore,
    this.likes = 0,
    required this.theme,
    required this.localization,
    required this.currency,
    this.socials = const [],
    this.paymentMethods = const [],
    this.deliveryHandling = DeliveryHandlingType.own,
    this.assignedDeliveryIds = const [],
    this.orders = 0,
    this.followersUsers = const [],
    this.ratings = const [],
    this.visits = const [],
    this.allowFollow = true,
    this.allowLikes = true,
    this.allowReviews = true,
    this.allowOffers = false,
    this.isRecommended = false,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  BusinessModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
    String? ownerPhone,
    BusinessType? businessType,
    int? likes,
    ThemeAdmin? theme,
    LocalizationAdmin? localization,
    CurrencyStore? currency,
    List<SocialModel>? socials,
    List<PaymentMethodType>? paymentMethods,
    DeliveryHandlingType? deliveryHandling,
    List<String>? assignedDeliveryIds,
    int? orders,
    List<FollowersStore>? followersUsers,
    List<RatedUser>? ratings,
    List<BusinessVisitModel>? visits,
    bool? allowFollow,
    bool? allowLikes,
    bool? allowReviews,
    bool? allowOffers,
    bool? isRecommended,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      businessType: businessType ?? this.businessType,
      likes: likes ?? this.likes,
      theme: theme ?? this.theme,
      localization: localization ?? this.localization,
      currency: currency ?? this.currency,
      socials: socials ?? this.socials,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      deliveryHandling: deliveryHandling ?? this.deliveryHandling,
      assignedDeliveryIds: assignedDeliveryIds ?? this.assignedDeliveryIds,
      orders: orders ?? this.orders,
      followersUsers: followersUsers ?? this.followersUsers,
      ratings: ratings ?? this.ratings,
      visits: visits ?? this.visits,
      allowFollow: allowFollow ?? this.allowFollow,
      allowLikes: allowLikes ?? this.allowLikes,
      allowReviews: allowReviews ?? this.allowReviews,
      allowOffers: allowOffers ?? this.allowOffers,
      isRecommended: isRecommended ?? this.isRecommended,
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
  bool get hasOwner => ownerId != null && ownerId!.isNotEmpty;
  bool get hasName => _isValidLocalizedText(localization.name);
  bool get hasSlogan => _isValidLocalizedText(localization.slogan);
  bool get hasDescription => _isValidLocalizedText(localization.description);
  bool get hasFooterDescription => _isValidLocalizedText(localization.footerDescription);
  bool get hasAbout => _isValidLocalizedText(localization.aboutUs);
  bool get hasTerms => _isValidLocalizedText(localization.termsAndConditions);
  bool get hasPrivacy => _isValidLocalizedText(localization.privacyPolicy);
  
  // المنتجات والفئات
  bool get hasProducts => false; 
  bool get hasCategories => false; 

  bool get hasPaymentMethods => paymentMethods.isNotEmpty;

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

    // الدفع (15%)
    if (hasPaymentMethods) score += 15.0;

    // الهوية البصرية (20%)
    if (theme.logoUrl != null && theme.logoUrl!.isNotEmpty) score += 10.0;
    if (theme.coverBannerUrl != null && theme.coverBannerUrl!.isNotEmpty) score += 10.0;

    // التواصل (20%)
    if (socials.isNotEmpty) score += 20.0;

    return score.clamp(0.0, 100.0);
  }

  /// حالة الجاهزية كنص وتصنيف Enum
  ReadinessStatus get readinessStatus {
    final score = readinessPercentage;
    if (score >= 80.0) return ReadinessStatus.complete;
    if (score >= 50.0) return ReadinessStatus.good;
    return ReadinessStatus.needsAttention;
  }

  // ==========================================
  // 🌟 دوال مساعدة لحساب التقييمات
  // ==========================================

  int get totalRatingsCount => ratings.length;

  double get averageRating {
    if (ratings.isEmpty) return 0.0;
    final total = ratings.fold<double>(
      0.0,
      (sum, item) => sum + item.rating,
    );
    return total / ratings.length;
  }

  double get smartStoreScore {
    if (ratings.isEmpty) return 0.0;

    double engagementBonus = 0.0;
    if (followersUsers.isNotEmpty) {
      double followerRatio = followersUsers.length / 100.0;
      engagementBonus = (followerRatio * 0.5).clamp(0.0, 0.5);
    }

    return (averageRating + engagementBonus).clamp(0.0, 5.0);
  }

  // ==========================================
  // 🔄 Serialization (fromMap & toMap)
  // ==========================================

  factory BusinessModel.fromMap(Map<String, dynamic> map, String docId) {
    return BusinessModel(
      id: docId,
      ownerId: map['ownerId'] ?? map['owner']?['id'],
      ownerName: map['ownerName'] ?? map['owner']?['name'],
      ownerEmail: map['ownerEmail'] ?? map['owner']?['email'],
      ownerPhone: map['ownerPhone'] ?? (map['owner']?['phoneNumber']),
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
      paymentMethods: (map['paymentMethods'] as List<dynamic>?)
              ?.map((e) => PaymentMethodType.values.firstWhere(
                    (v) => v.name == e,
                    orElse: () => PaymentMethodType.cashOnDelivery,
                  ))
              .toList() ??
          [],
      deliveryHandling: DeliveryHandlingType.values.firstWhere(
        (e) => e.name == map['deliveryHandling'],
        orElse: () => DeliveryHandlingType.own,
      ),
      assignedDeliveryIds: List<String>.from(map['assignedDeliveryIds'] ?? []),
      orders: map['orders']?.toInt() ?? 0,
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
      allowFollow: map['allowFollow'] ?? true,
      allowLikes: map['allowLikes'] ?? true,
      allowReviews: map['allowReviews'] ?? true,
      allowOffers: map['allowOffers'] ?? false,
      isRecommended: map['isRecommended'] ?? false,
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
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'ownerPhone': ownerPhone,
      'businessType': businessType.name,
      'likes': likes,
      'theme': theme.toMap(),
      'localization': localization.toMap(),
      'currency': currency.toMap(),
      'socials': socials.map((e) => e.toMap()).toList(),
      'paymentMethods': paymentMethods.map((e) => e.name).toList(),
      'deliveryHandling': deliveryHandling.name,
      'assignedDeliveryIds': assignedDeliveryIds,
      'orders': orders,
      'followersUsers': followersUsers.map((e) => e.toMap()).toList(),
      'ratings': ratings.map((e) => e.toMap()).toList(),
      'visits': visits.map((e) => e.toMap()).toList(),
      'allowFollow': allowFollow,
      'allowLikes': allowLikes,
      'allowReviews': allowReviews,
      'allowOffers': allowOffers,
      'isRecommended': isRecommended,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// إنشاء كائن BusinessModel فارغ بقيم افتراضية
  factory BusinessModel.empty() {
    return BusinessModel(
      id: '',
      theme: ThemeAdmin.empty(),
      localization: LocalizationAdmin.empty(),
      currency: CurrencyStore.empty(),
    );
  }
}

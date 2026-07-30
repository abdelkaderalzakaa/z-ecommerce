import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/store/business_visit_model.dart';
import 'package:z_ecommerce/data/models/store/followers_store.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';
import '../auth/user_model.dart';
import 'currency_store.dart';
import 'localization_store.dart';
import 'theme_store.dart';

class BusinessModel {
  // 1. البيانات التعريفية للمالك والنشاط
  final UserModel owner;
  final BusinessType businessType;
  final List<AddressModel> addAddress;

  // 2. الهوية والإعدادات البصرية والمالية
  final StoreTheme theme;
  final LocalizationStore localization;
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
  final String? status; // 'مفعل من السوبر ادمن', 'غير مفعل', 'بانتظار التفعيل'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusinessModel({
    required this.owner,
    this.addAddress = const [],
    this.businessType = BusinessType.retailStore,
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
  String get id => owner.id;
  // ==========================================
  // 🧮 الحسابات الديناميكية (Dynamic Getters)
  // ==========================================

  /// إجمالي عدد الزيارات بناءً على القائمة
  int get visitorsCount => visits.length;

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
      owner: UserModel.fromMap(map['owner'] ?? {}),
      addAddress:
          (map['addAddress'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromMap(e))
              .toList() ??
          [],
      businessType: BusinessType.fromString(map['businessType']),
      theme: StoreTheme.fromMap(map['theme'] ?? {}),
      localization: LocalizationStore.fromMap(map['localization'] ?? {}),
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
      'owner': owner.toMap(),
      'addAddress': addAddress.map((e) => e.toMap()).toList(),
      'businessType': businessType.name,
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
}

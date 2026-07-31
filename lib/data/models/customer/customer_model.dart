import 'package:z_ecommerce/data/models/customer/activity_customer_inbusiness.dart';
import '../common/address_model.dart';
import '../auth/user_model.dart';

class CustomerModel {
  // 1. البيانات الأساسية
  final UserModel user;
  final List<AddressModel> addresses;

  // 2. المفضلة والأنشطة
  final List<String> wishlist; // معرّفات المنتجات المفضلة (Product IDs)
  final List<ActivityCustomerInBusiness> businessActivities;

  // 3. التواريخ
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    required this.user,
    this.addresses = const [],
    this.wishlist = const [],
    this.businessActivities = const [],
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // 🧮 Dynamic Getters & Helpers
  // ==========================================

  /// معرف العميل المباشر من UserModel
  String get id => user.id;

  /// الحصول على العنوان الافتراضي
  AddressModel? get defaultAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (addr) => addr.isDefault,
      orElse: () => addresses.first,
    );
  }

  /// حساب مجموع طلبات العميل في جميع البزنسات تلقائياً
  int get totalOrdersCount {
    if (businessActivities.isEmpty) return 0;
    return businessActivities.fold(0, (sum, item) => sum + item.ordersCount);
  }

  /// التحقق مما إذا كان المنتج موجد في المفضلة
  bool isInWishlist(String productId) {
    return wishlist.contains(productId);
  }

  /// البحث عن نشاط العميل لبزنس معين
  ActivityCustomerInBusiness? getActivityForBusiness(String businessId) {
    try {
      return businessActivities.firstWhere(
        (act) => act.businessId == businessId,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // 🔄 Serialization (fromMap, toMap & copyWith)
  // ==========================================

  factory CustomerModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CustomerModel(
      user: UserModel.fromMap(map['user'] ?? {}),
      addresses: (map['addresses'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromMap(e))
              .toList() ??
          [],
      wishlist: (map['wishlist'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      businessActivities: (map['businessActivities'] as List<dynamic>?)
              ?.map((e) => ActivityCustomerInBusiness.fromMap(e))
              .toList() ??
          [],
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
      'user': user.toMap(),
      'addresses': addresses.map((e) => e.toMap()).toList(),
      'wishlist': wishlist,
      'businessActivities': businessActivities.map((e) => e.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    UserModel? user,
    List<AddressModel>? addresses,
    List<String>? wishlist,
    List<ActivityCustomerInBusiness>? businessActivities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      user: user ?? this.user,
      addresses: addresses ?? this.addresses,
      wishlist: wishlist ?? this.wishlist,
      businessActivities: businessActivities ?? this.businessActivities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// إنشاء كائن CustomerModel فارغ بقيم افتراضية
  factory CustomerModel.empty() {
    return CustomerModel(
      user: UserModel.empty(),
      addresses: const [],
      wishlist: const [],
      businessActivities: const [],
    );
  }
}
import 'package:z_ecommerce/data/models/customer/activity_customer_inbusiness.dart';
import '../common/address_model.dart';

class CustomerModel {
  // 1. البيانات الأساسية الخفيفة
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final List<AddressModel> addresses;

  // 2. المفضلة والأنشطة
  final List<String> wishlist; // معرّفات المنتجات المفضلة (Product IDs)
  final List<ActivityCustomerInBusiness> businessActivities;

  // 3. التواريخ
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    required this.id,
    this.name = '',
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.addresses = const [],
    this.wishlist = const [],
    this.businessActivities = const [],
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // 🧮 Dynamic Getters & Helpers
  // ==========================================

  bool get isEmpty => id.isEmpty;

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
      id: docId ?? map['id'] ?? (map['user']?['id'] ?? ''),
      name: map['name'] ?? (map['user']?['name'] ?? ''),
      email: map['email'] ?? map['user']?['email'],
      phoneNumber: map['phoneNumber'] ?? map['user']?['phoneNumber'],
      avatarUrl: map['avatarUrl'] ?? map['user']?['avatarUrl'],
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
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'addresses': addresses.map((e) => e.toMap()).toList(),
      'wishlist': wishlist,
      'businessActivities': businessActivities.map((e) => e.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    List<AddressModel>? addresses,
    List<String>? wishlist,
    List<ActivityCustomerInBusiness>? businessActivities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
      id: '',
      name: '',
      addresses: const [],
      wishlist: const [],
      businessActivities: const [],
    );
  }
}
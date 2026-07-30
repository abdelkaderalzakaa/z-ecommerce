import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';

class ProductModel {
  // 1. المعرفات والروابط
  final String id;
  final String businessId; // معرف المتجر / الشركة المالك للمنتج
  final String categoryId; // معرف القسم/التصنيف
  final String? brandId; // معرف الماركة/البراند (إن وجد)

  // 2. البيانات الأساسية
  final String name; // اسم المنتج الأساسي
  final String description; // وصف المنتج
  final String category; // اسم التصنيف للعرض المباشر
  final String? brand; // اسم البراند للعرض المباشر

  // 3. الصور والمظهر
  final List<String> images; // قائمة روابط الصور
  final String? thumbnail; // الصورة المصغرة الرئيسية

  // 4. الأسعار والخصومات
  final double originalPrice; // السعر الأصلي قبل الخصم
  final int? discountPercent; // نسبة الخصم المئوية (مثل 15%)

  // 5. الخيارات والمتغيرات (Variants)
  final List<Color> colors; // الألوان المتاحة
  final List<String> sizes; // المقاسات المتاحة
  final List<String> attributes; // خصائص إضافية (مثل: ['128GB', 'Leather'])

  // 6. المخزون وحالة المنتج
  final int stock; // الكمية المتوفرة
  final bool isFeatured; // هل المنتج مميز؟
  final bool isTopSelling; // هل المنتج من الأكثر مبيعاً؟

  // 7. التقييمات والمراجعات
  final List<RatedUser> ratings; // قائمة التقييمات التفصيلية

  // 8. التواريخ
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.businessId,
    required this.categoryId,
    this.brandId,
    required this.name,
    required this.description,
    required this.category,
    this.brand,
    this.images = const [],
    this.thumbnail,
    required this.originalPrice,
    this.discountPercent,
    this.colors = const [],
    this.sizes = const [],
    this.attributes = const [],
    this.stock = 0,
    this.isFeatured = false,
    this.isTopSelling = false,
    this.ratings = const [],
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // 🧮 Dynamic Getters & Helpers
  // ==========================================

  /// الحصول على الصورة الرئيسية للعرض
  String get displayImage {
    if (thumbnail != null && thumbnail!.isNotEmpty) return thumbnail!;
    if (images.isNotEmpty) return images.first;
    return '';
  }

  /// هل يوجد خصم فعلي على المنتج؟
  bool get hasDiscount => discountPercent != null && discountPercent! > 0;

  /// حساب السعر النهائي بعد تطبيق الخصم تلقائياً
  double get price {
    if (!hasDiscount) return originalPrice;
    return originalPrice * (1 - (discountPercent! / 100));
  }

  /// هل المنتج متاح للبيع حالياً (بناءً على المخزون)
  bool get isAvailable => stock >= 0;

  /// هل المنتج وصل حديثاً؟ (إذا تم إنشاؤه خلال آخر 30 يوماً)
  bool get isNewArrival {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inDays <= 30;
  }

  /// متوسط التقييمات المحسوب ديناميكياً من مصفوفة ratings
  double get rating {
    if (ratings.isEmpty) return 0.0;
    final totalSum = ratings.fold<double>(0.0, (sum, item) => sum + item.rating);
    return double.parse((totalSum / ratings.length).toStringAsFixed(1));
  }

  /// إجمالي عدد التقييمات والمراجعات
  int get reviewsCount => ratings.length;

  // ==========================================
  // 🔄 Serialization (fromMap, toMap & JSON)
  // ==========================================

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ProductModel(
      id: docId ?? map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      brandId: map['brandId'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'],
      images: List<String>.from(map['images'] ?? []),
      thumbnail: map['thumbnail'],
      originalPrice: (map['originalPrice'] ?? 0.0).toDouble(),
      discountPercent: map['discountPercent'],
      colors: (map['colors'] as List?)
              ?.map((c) => Color(c is int ? c : int.parse(c.toString())))
              .toList() ??
          const [],
      sizes: List<String>.from(map['sizes'] ?? []),
      attributes: List<String>.from(map['attributes'] ?? []),
      stock: map['stock'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      isTopSelling: map['isTopSelling'] ?? false,
      ratings: (map['ratings'] as List<dynamic>?)
              ?.map((e) => RatedUser.fromMap(e))
              .toList() ??
          const [],
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
      'businessId': businessId,
      'categoryId': categoryId,
      'brandId': brandId,
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'images': images,
      'thumbnail': thumbnail,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'colors': colors.map((c) => c.value).toList(),
      'sizes': sizes,
      'attributes': attributes,
      'stock': stock,
      'isFeatured': isFeatured,
      'isTopSelling': isTopSelling,
      'ratings': ratings.map((r) => r.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      ProductModel.fromMap(json);

  // ==========================================
  // ✂️ CopyWith Function
  // ==========================================

  ProductModel copyWith({
    String? id,
    String? businessId,
    String? categoryId,
    String? brandId,
    String? name,
    String? description,
    String? category,
    String? brand,
    List<String>? images,
    String? thumbnail,
    double? originalPrice,
    int? discountPercent,
    List<Color>? colors,
    List<String>? sizes,
    List<String>? attributes,
    int? stock,
    bool? isFeatured,
    bool? isTopSelling,
    List<RatedUser>? ratings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      attributes: attributes ?? this.attributes,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      isTopSelling: isTopSelling ?? this.isTopSelling,
      ratings: ratings ?? this.ratings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
import 'package:z_ecommerce/data/models/product/product_variant.dart';
import 'package:z_ecommerce/data/models/product/discount_model.dart';
import 'package:z_ecommerce/data/models/product/product_offer_model.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';

/// Represents a product in the e-commerce store with dynamic variants.
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

  // 5. المتغيرات والخيارات الديناميكية (Variants)
  final List<ProductVariant> variants;

  // 5.2 الخصومات المحددة للمنتج
  final List<DiscountModel> discounts;

  // 5.3 العروض والاوفرات المحددة للمنتج
  final List<ProductOfferModel> offers;

  // 6. حالة المنتج والتفضيل
  final bool isActive; // هل المنتج نشط؟
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
    this.variants = const [],
    this.discounts = const [],
    this.offers = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.isTopSelling = false,
    this.ratings = const [],
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // 🧮 Dynamic Getters & Helpers
  // ==========================================

  /// الحصول على المتغير الافتراضي
  ProductVariant get defaultVariant {
    if (variants.isEmpty) {
      return const ProductVariant(isDefault: true, price: 0.0, stock: 0);
    }
    return variants.firstWhere((v) => v.isDefault, orElse: () => variants.first);
  }

  /// إجمالي مخزون المنتج المجمع من كافة المتغيرات
  int get totalStock {
    if (variants.isEmpty) return 0;
    return variants.fold<int>(0, (sum, variant) => sum + variant.stock);
  }

  /// هل المنتج متوفر (إجمالي المخزون أكبر من 0)
  bool get isAvailable => totalStock > 0;

  /// السعر الأساسي للمنتج بعد تطبيق الخصم (في حال عدم تحديد متغيّر)
  double get basePrice {
    final activeDisc = discounts.firstWhere((d) => d.isValid, orElse: () => const DiscountModel(id: '', name: '', type: '', value: 0, isActive: false));
    if (activeDisc.isActive && activeDisc.value > 0) {
      if (activeDisc.isPercentage) {
        return defaultVariant.price * (1 - (activeDisc.value / 100));
      } else {
        return (defaultVariant.price - activeDisc.value).clamp(0.0, double.infinity);
      }
    }
    return defaultVariant.price;
  }

  /// السعر الأصلي قبل الخصم
  double get originalPrice {
    return defaultVariant.originalPrice ?? defaultVariant.price;
  }

  /// نسبة الخصم المئوية (مثل 15%) المحسوبة ديناميكياً
  int? get discountPercent {
    final activeDisc = discounts.firstWhere((d) => d.isValid, orElse: () => const DiscountModel(id: '', name: '', type: '', value: 0, isActive: false));
    if (activeDisc.isActive && activeDisc.value > 0) {
      if (activeDisc.isPercentage) {
        return activeDisc.value.round();
      } else {
        final orig = originalPrice;
        if (orig > 0) {
          return ((activeDisc.value / orig) * 100).round();
        }
      }
    }
    final orig = originalPrice;
    final curr = basePrice;
    if (orig <= curr || orig == 0) return null;
    return (((orig - curr) / orig) * 100).round();
  }

  /// حساب السعر لمتغير محدد وتطبيق الخصم عليه إذا كان للمنتج خصم
  double getPriceForVariant(ProductVariant variant) {
    if (!hasDiscount) return variant.price;
    return variant.price * (1 - (discountPercent! / 100));
  }

  /// قائمة المتغيرات المتوفرة فقط (التي كميتها أكبر من 0)
  List<ProductVariant> get availableVariants {
    return variants.where((variant) => variant.stock > 0).toList();
  }

  /// الحصول على الصورة الرئيسية للعرض
  String get displayImage {
    if (thumbnail != null && thumbnail!.isNotEmpty) return thumbnail!;
    if (images.isNotEmpty) return images.first;
    return '';
  }

  /// هل يوجد خصم فعلي على المنتج؟
  bool get hasDiscount => discountPercent != null && discountPercent! > 0;

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
  // 🔄 Serialization (fromMap & toMap)
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
      variants: (map['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      discounts: (map['discounts'] as List<dynamic>?)
              ?.map((e) => DiscountModel.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      offers: (map['offers'] as List<dynamic>?)
              ?.map((e) => ProductOfferModel.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      isActive: map['isActive'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      isTopSelling: map['isTopSelling'] ?? false,
      ratings: (map['ratings'] as List<dynamic>?)
              ?.map((e) => RatedUser.fromMap(Map<String, dynamic>.from(e as Map)))
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
      'variants': variants.map((v) => v.toMap()).toList(),
      'discounts': discounts.map((d) => d.toMap()).toList(),
      'offers': offers.map((o) => o.toMap()).toList(),
      'isActive': isActive,
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
    List<ProductVariant>? variants,
    List<DiscountModel>? discounts,
    List<ProductOfferModel>? offers,
    bool? isActive,
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
      variants: variants ?? this.variants,
      discounts: discounts ?? this.discounts,
      offers: offers ?? this.offers,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isTopSelling: isTopSelling ?? this.isTopSelling,
      ratings: ratings ?? this.ratings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// إنشاء كائن ProductModel فارغ بقيم افتراضية
  factory ProductModel.empty() {
    return const ProductModel(
      id: '',
      businessId: '',
      categoryId: '',
      name: '',
      description: '',
      category: '',
    );
  }
}